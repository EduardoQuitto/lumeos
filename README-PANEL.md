# README-PANEL — Mission Control (Windows 11 nativo)

Painel de acompanhamento do Lume OS, rodando no host Windows 11 sem WSL, sem Docker obrigatório e sem privilégios de administrador.

## Endereço

- Local: http://localhost:7777 (bind padrão 127.0.0.1)
- LAN: http://<ip-da-maquina>:7777 com `--lan` + `MC_TOKEN` (header `Authorization: Bearer <token>`)

## Como ligar (1 comando)

```powershell
.\tools\start-panel.ps1
```

O script:
1. Verifica se o binário release existe (`mission-control/backend/target/release/lume-mission-control.exe`)
2. Inicia o backend em `127.0.0.1:7777`
3. Aguarda o `/api/state` responder
4. Abre o navegador padrão em `localhost:7777`
5. Salva o PID em `.panel.pid` (usado pelo `stop-panel.ps1`)

Modo LAN (outro dispositivo na rede):

```powershell
$env:MC_TOKEN="seu-token-aqui"
.\tools\start-panel.ps1 -Lan
```

## Como parar

```powershell
.\tools\stop-panel.ps1
```

## Iniciar automaticamente no logon (sem admin)

```powershell
.\tools\install-panel-task.ps1
```

Opcional com LAN:

```powershell
$env:MC_TOKEN="seu-token-aqui"
.\tools\install-panel-task.ps1 -Lan -Token "seu-token-aqui"
```

Remover:

```powershell
schtasks /delete /tn "LumeMissionControl" /f
```

## API (contrato de docs/MISSION-CONTROL.md)

| Método | Caminho | Descrição | Auth LAN |
|--------|---------|-----------|----------|
| GET | `/api/state` | Fases, % global, sessão, ETA, blockers | Não |
| GET | `/api/events?since=` | Feed de eventos via SSE | Não |
| POST | `/api/events` | Publica evento (phase_start, task_start, task_done, task_blocked, error, build, test, heartbeat, report_daily) | Sim |
| POST | `/api/build` | Registra build (iso, sha256, shots[]) | Sim |
| POST | `/api/test` | Registra teste (nome, tier, resultado, log) | Sim |
| GET | `/api/control` | Consulta pause/resume | Não |
| POST | `/api/control` | Envia `{ "pausada": true\|false }` | Sim |
| POST | `/api/heartbeat` | Envia `{ "tarefa": "...", "arquivo": "..." }` | Sim |
| GET | `/shots/<fase>` | Galeria de screenshots QMP | Não |

## Eventos que o agente publica

- `phase_start` — início de fase
- `task_start` / `task_done` — início/término de tarefa
- `task_blocked{retry}` — tarefa bloqueada
- `error{traceback,retry}` — erro com rastreio
- `build` — ISO/build concluído
- `test` — resultado de teste VM
- `heartbeat{task,file,ts}` — a cada tarefa e a cada 60 s (stale > 10 min = alerta)
- `report_daily` — relatório diário

## Exemplo de publicação via PowerShell

```powershell
Invoke-RestMethod -Method Post -Uri "http://localhost:7777/api/heartbeat` 
  -ContentType "application/json" -Body '{"tarefa":"fase-1-design","arquivo":"design/tokens.json"}'
```

Exemplo de evento de teste:

```powershell
Invoke-RestMethod -Method Post -Uri "http://localhost:7777/api/events" `
  -ContentType "application/json" `
  -Body '{"tipo":"task_done","fase":1,"tarefa":"t1-1","payload":{"ok":true}}'
```

## Painel mostra

- % por fase e global (pesos do roadmap.yaml)
- Tarefa atual com status (pendente/fazendo/feita/bloqueada) e retry
- Sessão: início, decorrido, ETA (EWMA; baixa confiança nas 2 primeiras sessões)
- Blockers por fase (alerta vermelho se > 0)
- Feed de eventos SSE (atualiza < 2 s)
- Botões Pausar / Retomar (`/api/control`)
- Formulário de heartbeat
- Galeria de screenshots (`design/shots/<fase>/`)
- Link para relatório diário (`docs/reports/AAAA-MM-DD.md`)

## Solução de problemas

**Porta 7777 em uso**
```
netstat -ano | findstr :7777
taskkill /PID <PID> /F
```

**Firewall bloqueando LAN**
No Windows, permite a porta 7777:
```
netsh advfirewall firewall add rule name="Lume MC" dir=in action=allow protocol=TCP localport=7777
```
Requer administrador apenas para a regra de firewall.

**Navegador não abre**
Acesse manualmente: http://localhost:7777

**Sem WSL / sem Docker**
Não são necessários. Tudo roda em PowerShell nativo + binário Rust release.

## Build do backend

```powershell
cd mission-control\backend
cargo build --release
```

O binário fica em `target/release/lume-mission-control.exe`.

## Tags

Release desta entrega: `panel-win-v1`
