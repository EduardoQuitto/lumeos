# Mission Control — especificação (fase 0)
Backend Rust (axum) + SQLite + SSE em :7777; web Svelte. LAN opcional com MC_TOKEN.

## Schema do roadmap.yaml (fonte da verdade)
fases[]: {id, nome, peso, aceite, gate:{testes[], blockers, signoff},
          tarefas[]: {id, desc, aceite, status: pendente|fazendo|feita|bloqueada, retry}}
tarefas[] é preenchido pelo agente no phase_start (mín. 3 por fase); pesos de tarefa iguais.

## API
GET  /api/state            → fases, % por fase, % global, sessão, ETA, blockers
GET  /api/events?since     → histórico
POST /api/events           → agente publica eventos (abaixo)
POST /api/build            → {iso, sha256, shots[]}
POST /api/test             → {nome, tier, resultado, log}
GET  /api/control          → agente consulta antes de CADA tarefa (pause/resume)
POST /api/control          → dono pausa/retoma
GET  /shots/<fase>/...     → galeria estática

## Eventos do agente
phase_start, task_start, task_done, task_blocked{retry}, error{traceback,retry},
build, test, phase_done{tag}, sweep, report_daily, heartbeat{task,file,ts}
Heartbeat a cada tarefa e a cada 60 s em ops longas; stale > 10 min = alerta vermelho.

## Cálculos
% fase = tarefas feitas / total; % global = Σ(peso × % fase)/100.
ETA = peso restante / velocidade (EWMA α=0.3 de peso/hora por sessão);
nas 2 primeiras sessões mostrar "estimativa de baixa confiança".

## Gates exibidos por fase
suíte de testes verde + blockers 0 + sign-off visual do dono (botão) → fase fechada.
Screenshots: QMP screendump → design/shots/<fase>/<superficie>-<tema>.png;
diff estrutural vs design/references/ (tolerância no manifest).
Relatório diário: docs/reports/AAAA-MM-DD.md, linkado no painel.
Pausa: agente em loop de heartbeat "paused" até /api/control liberar.