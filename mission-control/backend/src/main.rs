use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::{Json, Sse},
    routing::{get, post},
    Router,
};
use axum::response::sse::{Event, KeepAlive};
use chrono::{Utc, DateTime};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::net::SocketAddr;
use std::sync::Arc;
use std::pin::Pin;
use std::task::{Context, Poll};
use tokio::sync::{broadcast, Mutex};
use tokio_stream::{wrappers::BroadcastStream, Stream};
use uuid::Uuid;

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
    tarefas: Vec<Tarefa>,
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

struct Backend {
    db: rusqlite::Connection,
    tx: broadcast::Sender<Evento>,
    sessao_atual: Sessao,
    fases: Vec<Fase>,
}

impl Backend {
    fn new() -> rusqlite::Result<Self> {
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
        let _pct_global = calcular_pct_global(&fases);

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
}

fn carregar_fases_roadmap() -> Vec<Fase> {
    vec![
        Fase {
            id: 0,
            nome: "fundacao-mission-control".into(),
            peso: 4,
            aceite: "painel :7777 com heartbeat + CI QEMU verde + PRD.md gerado".into(),
            gate: Gate {
                testes: vec!["backend-smoke".into(), "web-smoke".into(), "qemu-smoke".into()],
                blockers: 0,
                signoff: "pendente".into(),
            },
            tarefas: vec![
                Tarefa { id: "t0-1".into(), desc: "backend axum+SQLite+SSE :7777".into(), aceite: "API /api/state, /api/events, /api/control, heartbeat funcionando".into(), status: "feita".into(), retry: 0 },
                Tarefa { id: "t0-2".into(), desc: "web Svelte painel :7777".into(), aceite: "painel mostra fases, % global, tarefa atual, heartbeat, eventos, galeria shots".into(), status: "pendente".into(), retry: 0 },
                Tarefa { id: "t0-3".into(), desc: "tests/qemu/smoke.sh CI QEMU".into(), aceite: "boot QEMU <30s + screendump + ISO amd64/i386".into(), status: "pendente".into(), retry: 0 },
                Tarefa { id: "t0-4".into(), desc: "systemd timer 5h + heartbeat por tarefa".into(), aceite: "timer 5h ativo, heartbeat publica a cada tarefa e a cada 60s em ops longas".into(), status: "pendente".into(), retry: 0 },
            ],
            pct: 25.0,
        },
    ]
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

async fn get_state(State(state): State<AppState>) -> Json<Estado> {
    let b = state.lock().await;
    let pct_global = calcular_pct_global(&b.fases);
    let blockers_totais: u32 = b.fases.iter().map(|f| f.gate.blockers).sum();
    Json(Estado {
        sessoes: vec![b.sessao_atual.clone()],
        fases: b.fases.clone(),
        pct_global,
        blockers_totais,
        eta: Some(format!("{:.1} h", (100.0 - pct_global) * 0.1)),
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
    Sse::new(stream).keep_alive(KeepAlive::default().interval(std::time::Duration::from_secs(30)))
}

async fn post_event(
    State(state): State<AppState>,
    Json(payload): Json<PublishEvent>,
) -> Result<Json<Value>, StatusCode> {
    let mut b = state.lock().await;
    b.publicar(&payload.tipo, payload.fase, payload.tarefa.as_deref(), payload.payload);
    Ok(Json(serde_json::json!({"ok": true})))
}

async fn post_build(
    State(state): State<AppState>,
    Json(payload): Json<Value>,
) -> Result<Json<Value>, StatusCode> {
    let mut b = state.lock().await;
    b.publicar("build", None, None, payload);
    Ok(Json(serde_json::json!({"ok": true})))
}

async fn post_test(
    State(state): State<AppState>,
    Json(payload): Json<Value>,
) -> Result<Json<Value>, StatusCode> {
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
    State(state): State<AppState>,
    Json(payload): Json<Value>,
) -> Json<Value> {
    let mut b = state.lock().await;
    if let Some(p) = payload.get("pausada").and_then(|v| v.as_bool()) {
        b.sessao_atual.pausada = p;
        b.publicar("control", None, None, serde_json::json!({"pausada": p}));
    }
    Json(serde_json::json!({"pausada": b.sessao_atual.pausada}))
}

async fn post_heartbeat(
    State(state): State<AppState>,
    Json(payload): Json<Value>,
) -> Json<Value> {
    let mut b = state.lock().await;
    let tarefa = payload.get("tarefa").and_then(|v| v.as_str()).unwrap_or("desconhecida");
    let arquivo = payload.get("arquivo").and_then(|v| v.as_str()).unwrap_or("-");
    b.heartbeat(tarefa, arquivo);
    Json(serde_json::json!({"ok": true}))
}

async fn shots_handler(Path(_fase): Path<String>) -> Result<Json<Value>, StatusCode> {
    Ok(Json(serde_json::json!({"shots": []})))
}

#[tokio::main]
async fn main() {
    let mut backend = match Backend::new() {
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

    let app = Router::new()
        .route("/api/state", get(get_state))
        .route("/api/events", get(get_events))
        .route("/api/events", post(post_event))
        .route("/api/build", post(post_build))
        .route("/api/test", post(post_test))
        .route("/api/control", get(get_control))
        .route("/api/control", post(post_control))
        .route("/api/heartbeat", post(post_heartbeat))
        .route("/shots/*fase", get(shots_handler))
        .layer(tower_http::cors::CorsLayer::permissive())
        .with_state(state);

    let addr = SocketAddr::from(([0, 0, 0, 0], 7777));
    println!("Mission Control escutando em http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
