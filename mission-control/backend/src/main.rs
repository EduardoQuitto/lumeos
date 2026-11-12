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
                Tarefa { id: "t0-2".into(), desc: "web Svelte painel :7777".into(), aceite: "painel mostra fases, % global, tarefa atual, heartbeat, eventos, galeria shots".into(), status: "feita".into(), retry: 0 },
                Tarefa { id: "t0-3".into(), desc: "tests/qemu/smoke.sh CI QEMU".into(), aceite: "boot QEMU <30s + screendump + ISO amd64/i386".into(), status: "pendente".into(), retry: 0 },
                Tarefa { id: "t0-4".into(), desc: "systemd timer 5h + heartbeat por tarefa".into(), aceite: "timer 5h ativo, heartbeat publica a cada tarefa e a cada 60s em ops longas".into(), status: "pendente".into(), retry: 0 },
            ],
            pct: 50.0,
        },
        Fase { id: 1, nome: "design-system-assets".into(), peso: 4, aceite: "tokens + logo 6 variantes + cursor + wallpapers + sons".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 2, nome: "iso-amd64-boot".into(), peso: 4, aceite: "boot <20s + Plymouth + screenshot".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 3, nome: "daemons-rust-detect".into(), peso: 3, aceite: "tiers + D-Bus + lume-fetch".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 4, nome: "barra-tray-relogio".into(), peso: 4, aceite: "barra pílula + indicadores + locale".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 5, nome: "flyouts".into(), peso: 4, aceite: "4 painéis <150 ms".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 6, nome: "iniciar-busca".into(), peso: 3, aceite: "menu 640x560 + busca apps/arquivos/configs/cálculo".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 7, nome: "janelas-snap-overview".into(), peso: 4, aceite: "libdecor + 4 layouts + alt-tab + overview".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 8, nome: "lume-files".into(), peso: 4, aceite: "toolbar+breadcrumb+abas+busca+lixo+montagem+extração".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 9, nome: "settings-parte1".into(), peso: 4, aceite: "8 páginas: sistema/tela/som/rede/bt/personalização/apps/contas".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 10, nome: "settings-parte2-security".into(), peso: 4, aceite: "8 páginas + Central de Segurança com checklist Shield".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 11, nome: "terminal-cli".into(), peso: 3, aceite: "foot+starship+quake+command-not-found+CLI lume completa".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 12, nome: "loja".into(), peso: 4, aceite: "8 categorias + badges tier + fila + flatpak install/remove".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 13, nome: "essenciais-pwa-mime".into(), peso: 3, aceite: "OOBE 1-clique instala pacote + PWAs + MIME defaults".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 14, nome: "oobe-login-energia".into(), peso: 4, aceite: "OOBE+greeter+lock+telas desligar/reiniciar/atualizar".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 15, nome: "instalador-hd".into(), peso: 4, aceite: "instala em disco vazio VM com LUKS+A/B + teste instalação".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 16, nome: "pendrive-persistente".into(), peso: 3, aceite: "criador USB LUKS + backup/restore + teste instalação".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 17, nome: "edicao-lite-i386".into(), peso: 4, aceite: "ISO i386 boot + shell X11 + picom + idle ≤250MB".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 18, nome: "edicao-core".into(), peso: 3, aceite: "labwc+Quickshell + matriz materiais + idle ≤350MB".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 19, nome: "camada-windows".into(), peso: 4, aceite: "Wine+NTSYNC+garrafas bwrap + selos + 3 apps da lista rodando".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 20, nome: "jogos-nuvem".into(), peso: 3, aceite: "Steam/Proton B/C + Sober best-effort + PWAs nuvem por tier".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 21, nome: "shield-hardening".into(), peso: 4, aceite: "verity+lockdown+AppArmor+seccomp+nftables + testes tamper".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 22, nome: "modo-cofre".into(), peso: 3, aceite: "microVM descartável abre app de risco e销毁 sem resíduo".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 23, nome: "update-ab-github".into(), peso: 4, aceite: "manifesto assinado+slot B+rollback automático + teste update".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 24, nome: "i18n-a11y".into(), peso: 3, aceite: "pt/en 100% + Orca+alto contraste+movimento reduzido".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 25, nome: "passe-performance".into(), peso: 3, aceite: "budgets de boot/idle/flyout/ISO atingidos nos 3 tiers".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 26, nome: "suite-testes-vm".into(), peso: 3, aceite: "matriz QEMU + instalação + update + segurança + diff visual".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
        Fase { id: 27, nome: "beta-release".into(), peso: 3, aceite: "QA hardware real + docs + site + release 0.1 assinada por você".into(), gate: Gate { testes: vec![], blockers: 0, signoff: "pendente".into() }, tarefas: vec![], pct: 0.0 },
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

async fn shots_handler(Path(_fase): Path<String>) -> Result<Json<Value>, StatusCode> {
    Ok(Json(serde_json::json!({"shots": []})))
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
