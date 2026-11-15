use axum::{
    extract::{Path, Query, State},
    http::{header, HeaderMap, StatusCode},
    response::{Html, Json, Sse},
    routing::{get, get_service, post},
    Router,
};
use axum::response::sse::{Event, KeepAlive};
use chrono::{Utc, DateTime};
use clap::Parser;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::env;
use std::fs;
use std::net::SocketAddr;
use std::path::PathBuf;
use std::sync::Arc;
use std::time::Duration;
use tokio::net::TcpListener;
use tokio::sync::{broadcast, Mutex};
use tokio_stream::{wrappers::BroadcastStream, Stream};
use std::pin::Pin;
use std::task::{Context, Poll};
use uuid::Uuid;
use tower_http::services::ServeDir;

type AppState = Arc<Mutex<Backend>>;

#[derive(Clone, Debug, Serialize, Deserialize)]
struct Evento {
    id: String,
    ts: DateTime<Utc>,
    tipo: String,
    fase: Option<u32>,
    tarefa: Option<String>,
    payload: Value,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
struct Fase {
    id: u32,
    nome: String,
    peso: u32,
    aceite: String,
    gate: Gate,
    #[serde(default)]
    tarefas: Vec<Tarefa>,
    #[serde(default)]
    pct: f64,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
struct Gate {
    testes: Vec<String>,
    blockers: u32,
    signoff: String,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
struct Tarefa {
    id: String,
    desc: String,
    aceite: String,
    status: String,
    retry: u32,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
struct Estado {
    sessoes: Vec<Sessao>,
    fases: Vec<Fase>,
    pct_global: f64,
    blockers_totais: u32,
    eta: Option<String>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
struct Sessao {
    id: String,
    inicio: DateTime<Utc>,
    decorrido_s: u64,
    fase_atual: u32,
    pausada: bool,
}

#[derive(Deserialize)]
struct EventsQuery {
    since: Option<String>,
}

#[derive(Deserialize)]
struct PublishEvent {
    tipo: String,
    fase: Option<u32>,
    tarefa: Option<String>,
    payload: Value,
}

#[derive(Parser, Debug, Clone)]
#[command(author, version, about = "Lume OS Mission Control")]
struct Args {
    /// Porta para escutar (padrão 7777)
    #[arg(long, default_value = "7777")]
    port: u16,

    /// Escutar em 0.0.0.0 (LAN). Exige MC_TOKEN.
    #[arg(long)]
    lan: bool,

    /// Token de acesso para modo LAN (obrigatório se --lan)
    #[arg(long)]
    token: Option<String>,

    /// Diretório de arquivos estáticos do frontend
    #[arg(long, default_value = "web/dist")]
    web_dir: PathBuf,
}

struct Backend {
    db: rusqlite::Connection,
    tx: broadcast::Sender<Evento>,
    sessao_atual: Sessao,
    fases: Vec<Fase>,
    args: Args,
    lan_token: Option<String>,
}

impl Backend {
    fn new(args: Args) -> rusqlite::Result<Self> {
        let db = rusqlite::Connection::open("events.sqlite")?;
        db.execute_batch(
            "CREATE TABLE IF NOT EXISTS eventos (
                id TEXT PRIMARY KEY,
                ts TEXT NOT NULL,
                tipo TEXT NOT NULL,
                fase INTEGER,
                tarefa TEXT,
                payload TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS sessoes (
                id TEXT PRIMARY KEY,
                inicio TEXT NOT NULL,
                fase_atual INTEGER NOT NULL DEFAULT 0,
                pausada INTEGER NOT NULL DEFAULT 0
            );",
        )?;

        let (tx, _rx) = broadcast::channel::<Evento>(1024);

        let sessao_id = Uuid::new_v4().to_string();
        let inicio = Utc::now();
        db.execute(
            "INSERT INTO sessoes (id, inicio, fase_atual, pausada) VALUES (?1, ?2, 0, 0)",
            rusqlite::params![sessao_id, inicio.to_rfc3339()],
        )?;

        let fases = carregar_fases_roadmap();
        let lan_token = if args.lan {
            args.token.clone().or_else(|| env::var("MC_TOKEN").ok())
        } else {
            None
        };

        Ok(Self {
            db,
            tx,
            sessao_atual: Sessao {
                id: sessao_id,
                inicio,
                decorrido_s: 0,
                fase_atual: 0,
                pausada: false,
            },
            fases,
            args,
            lan_token,
        })
    }

    fn publicar(&mut self, tipo: &str, fase: Option<u32>, tarefa: Option<&str>, payload: Value) {
        let ev = Evento {
            id: Uuid::new_v4().to_string(),
            ts: Utc::now(),
            tipo: tipo.to_string(),
            fase,
            tarefa: tarefa.map(|s| s.to_string()),
            payload,
        };
        let _ = self.tx.send(ev.clone());
        let _ = self.db.execute(
            "INSERT INTO eventos (id, ts, tipo, fase, tarefa, payload) VALUES (?1, ?2, ?3, ?4, ?5, ?6)",
            rusqlite::params![
                ev.id,
                ev.ts.to_rfc3339(),
                ev.tipo,
                ev.fase.map(|f| f as i32),
                ev.tarefa,
                serde_json::to_string(&ev.payload).unwrap_or_default()
            ],
        );
    }

    fn heartbeat(&mut self, tarefa: &str, arquivo: &str) {
        self.publicar(
            "heartbeat",
            Some(self.fase_atual()),
            Some(tarefa),
            serde_json::json!({
                "tarefa": tarefa,
                "arquivo": arquivo,
                "ts": Utc::now().to_rfc3339(),
                "sessao": self.sessao_atual.id,
            }),
        );
    }

    fn fase_atual(&self) -> u32 {
        self.sessao_atual.fase_atual
    }

    fn lan_autorizado(&self, headers: &HeaderMap) -> bool {
        if !self.args.lan {
            return true;
        }
        let token = match self.lan_token.as_ref() {
            Some(t) => t,
            None => return false,
        };
        headers
            .get(header::AUTHORIZATION)
            .and_then(|v| v.to_str().ok())
            .map(|v| v == format!("Bearer {}", token))
            .unwrap_or(false)
    }
}

#[derive(Deserialize)]
struct Roadmap {
    fases: Vec<Fase>,
}

fn carregar_fases_roadmap() -> Vec<Fase> {
    let conteudo = fs::read_to_string("roadmap.yaml").expect("roadmap.yaml não encontrado");
    let roadmap: Roadmap = serde_yaml::from_str(&conteudo).expect("falha ao fazer parse do roadmap.yaml");
    roadmap.fases
}

fn calcular_pct_global(fases: &[Fase]) -> f64 {
    if fases.is_empty() { return 0.0; }
    let total_peso: u32 = fases.iter().map(|f| f.peso).sum();
    if total_peso == 0 { return 0.0; }
    let ponderado: f64 = fases.iter().map(|f| f.peso as f64 * f.pct / 100.0).sum();
    ponderado / total_peso as f64 * 100.0
}

struct EventStream {
    inner: BroadcastStream<Evento>,
    since: Option<DateTime<Utc>>,
}

impl EventStream {
    fn new(rx: broadcast::Receiver<Evento>, since: Option<String>) -> Self {
        let since_dt = since.as_deref().and_then(|s| DateTime::parse_from_rfc3339(s).ok()).map(|d| d.with_timezone(&Utc));
        Self { inner: BroadcastStream::new(rx), since: since_dt }
    }
}

impl Stream for EventStream {
    type Item = Result<Event, axum::Error>;

    fn poll_next(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>> {
        loop {
            match Pin::new(&mut self.inner).poll_next(cx) {
                Poll::Ready(Some(Ok(ev))) => {
                    if let Some(ref since) = self.since {
                        if ev.ts <= *since {
                            continue;
                        }
                    }
                    let data = serde_json::to_string(&ev).unwrap_or_default();
                    return Poll::Ready(Some(Ok(Event::default().data(data))));
                }
                Poll::Ready(Some(Err(_))) => continue,
                Poll::Ready(None) => return Poll::Ready(None),
                Poll::Pending => return Poll::Pending,
            }
        }
    }
}

async fn require_lan_auth(
    headers: HeaderMap,
    State(state): State<AppState>,
) -> Result<(), StatusCode> {
    let b = state.lock().await;
    if b.lan_autorizado(&headers) {
        Ok(())
    } else {
        Err(StatusCode::UNAUTHORIZED)
    }
}

async fn get_state(State(state): State<AppState>) -> Json<Estado> {
    let b = state.lock().await;
    let pct_global = calcular_pct_global(&b.fases);
    let blockers_totais: u32 = b.fases.iter().map(|f| f.gate.blockers).sum();
    let decorrido = Utc::now().signed_duration_since(b.sessao_atual.inicio).num_seconds() as u64;
    let sessao = Sessao {
        id: b.sessao_atual.id.clone(),
        inicio: b.sessao_atual.inicio,
        decorrido_s: decorrido,
        fase_atual: b.sessao_atual.fase_atual,
        pausada: b.sessao_atual.pausada,
    };
    Json(Estado {
        sessoes: vec![sessao],
        fases: b.fases.clone(),
        pct_global,
        blockers_totais,
        eta: Some(format!("{:.1} h (baixa confiança)", (100.0 - pct_global) * 0.1)),
    })
}

async fn get_events(
    Query(q): Query<EventsQuery>,
    State(state): State<AppState>,
) -> Sse<EventStream> {
    let b = state.lock().await;
    let rx = b.tx.subscribe();
    drop(b);
    let stream = EventStream::new(rx, q.since);
    Sse::new(stream).keep_alive(KeepAlive::default().interval(Duration::from_secs(30)))
}

async fn post_event(
    headers: HeaderMap,
    State(state): State<AppState>,
    Json(payload): Json<PublishEvent>,
) -> Result<Json<Value>, StatusCode> {
    require_lan_auth(headers, State(state.clone())).await?;
    let mut b = state.lock().await;
    b.publicar(&payload.tipo, payload.fase, payload.tarefa.as_deref(), payload.payload);
    Ok(Json(serde_json::json!({"ok": true})))
}

async fn post_build(
    headers: HeaderMap,
    State(state): State<AppState>,
    Json(payload): Json<Value>,
) -> Result<Json<Value>, StatusCode> {
    require_lan_auth(headers, State(state.clone())).await?;
    let mut b = state.lock().await;
    b.publicar("build", None, None, payload);
    Ok(Json(serde_json::json!({"ok": true})))
}

async fn post_test(
    headers: HeaderMap,
    State(state): State<AppState>,
    Json(payload): Json<Value>,
) -> Result<Json<Value>, StatusCode> {
    require_lan_auth(headers, State(state.clone())).await?;
    let mut b = state.lock().await;
    b.publicar("test", None, None, payload);
    Ok(Json(serde_json::json!({"ok": true})))
}

async fn get_control(State(state): State<AppState>) -> Json<Value> {
    let b = state.lock().await;
    Json(serde_json::json!({
        "pausada": b.sessao_atual.pausada,
        "fase": b.sessao_atual.fase_atual,
    }))
}

async fn post_control(
    headers: HeaderMap,
    State(state): State<AppState>,
    Json(payload): Json<Value>,
) -> Result<Json<Value>, StatusCode> {
    require_lan_auth(headers, State(state.clone())).await?;
    let mut b = state.lock().await;
    if let Some(p) = payload.get("pausada").and_then(|v| v.as_bool()) {
        b.sessao_atual.pausada = p;
        b.publicar("control", None, None, serde_json::json!({"pausada": p}));
    }
    Ok(Json(serde_json::json!({"pausada": b.sessao_atual.pausada})))
}

async fn post_heartbeat(
    headers: HeaderMap,
    State(state): State<AppState>,
    Json(payload): Json<Value>,
) -> Result<Json<Value>, StatusCode> {
    require_lan_auth(headers, State(state.clone())).await?;
    let mut b = state.lock().await;
    let tarefa = payload.get("tarefa").and_then(|v| v.as_str()).unwrap_or("desconhecida");
    let arquivo = payload.get("arquivo").and_then(|v| v.as_str()).unwrap_or("-");
    b.heartbeat(tarefa, arquivo);
    Ok(Json(serde_json::json!({"ok": true})))
}

async fn shots_handler(Path(fase): Path<String>) -> Result<Json<Value>, StatusCode> {
    let shots_dir = format!("design/shots/{}", fase);
    let mut shots: Vec<String> = Vec::new();
    if let Ok(entries) = fs::read_dir(&shots_dir) {
        for entry in entries.flatten() {
            if let Some(nome) = entry.file_name().to_str() {
                shots.push(format!("{}/{}", shots_dir, nome));
            }
        }
    }
    shots.sort();
    Ok(Json(serde_json::json!({"shots": shots})))
}

async fn index_html(State(state): State<AppState>) -> Result<Html<String>, StatusCode> {
    let index_path = state.lock().await.args.web_dir.join("index.html");
    match tokio::fs::read_to_string(&index_path).await {
        Ok(content) => Ok(Html(content)),
        Err(_) => Err(StatusCode::NOT_FOUND),
    }
}

#[tokio::main]
async fn main() {
    let args = Args::parse();

    if args.lan && args.token.is_none() && env::var("MC_TOKEN").is_err() {
        eprintln!("ERRO: --lan exige --token (ou variável MC_TOKEN)");
        std::process::exit(1);
    }

    let mut backend = match Backend::new(args.clone()) {
        Ok(b) => b,
        Err(e) => {
            eprintln!("Falha ao iniciar backend: {}", e);
            std::process::exit(1);
        }
    };

    // Evento inicial phase_start
    backend.publicar("phase_start", Some(0), None, serde_json::json!({
        "fase": 0,
        "nome": "fundacao-mission-control",
        "aceite": "painel :7777 com heartbeat + CI QEMU verde + PRD.md gerado",
    }));

    let state: AppState = Arc::new(Mutex::new(backend));

    let api = Router::new()
        .route("/api/state", get(get_state))
        .route("/api/events", get(get_events))
        .route("/api/events", post(post_event))
        .route("/api/build", post(post_build))
        .route("/api/test", post(post_test))
        .route("/api/control", get(get_control))
        .route("/api/control", post(post_control))
        .route("/api/heartbeat", post(post_heartbeat))
        .route("/shots/*fase", get(shots_handler));

    let app = Router::new()
        .merge(api)
        .route("/", get(index_html))
        .route("/index.html", get(index_html))
        .fallback_service(get_service(ServeDir::new(&args.web_dir)))
        .layer(tower_http::cors::CorsLayer::permissive())
        .with_state(state);

    let bind_addr = if args.lan { "0.0.0.0" } else { "127.0.0.1" };
    let addr: SocketAddr = format!("{}:{}", bind_addr, args.port).parse().expect("endereço inválido");

    println!("Mission Control escutando em http://{}", addr);
    if args.lan {
        println!("Modo LAN ativo. Token exigido no header Authorization: Bearer <token>");
    }

    let listener = TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
