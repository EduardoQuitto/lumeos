<script>
  import { onMount } from 'svelte';

  let estado = null;
  let eventos = [];
  let pausada = false;
  let heartbeatTarefa = '';
  let heartbeatArquivo = '';
  let heartbeatStatus = '';
  let sse = null;
  let since = '';

  async function carregarEstado() {
    const r = await fetch('/api/state');
    estado = await r.json();
  }

  async function carregarControl() {
    const r = await fetch('/api/control');
    const c = await r.json();
    pausada = c.pausada || false;
  }

  async function abrirSSE() {
    if (sse) sse.close();
    const url = since ? `/api/events?since=${encodeURIComponent(since)}` : '/api/events';
    sse = new EventSource(url);
    sse.onmessage = (ev) => {
      try {
        const e = JSON.parse(ev.data);
        eventos = [e, ...eventos].slice(0, 200);
        since = e.ts;
      } catch (_) {}
    };
    sse.onerror = () => {
      setTimeout(abrirSSE, 3000);
    };
  }

  async function enviarHeartbeat() {
    const r = await fetch('/api/heartbeat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        tarefa: heartbeatTarefa || 'tarefa-atual',
        arquivo: heartbeatArquivo || '-',
      }),
    });
    heartbeatStatus = r.ok ? 'enviado' : 'erro';
    heartbeatTarefa = '';
    heartbeatArquivo = '';
    setTimeout(() => (heartbeatStatus = ''), 3000);
  }

  async function togglePause() {
    await fetch('/api/control', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ pausada: !pausada }),
    });
    await carregarControl();
  }

  function pctFase(f) {
    return Math.round(f.pct);
  }

  function pctGlobal() {
    return estado ? Math.round(estado.pct_global) : 0;
  }

  function corBlockers() {
    return estado && estado.blockers_totais > 0 ? '#C42B1C' : '#3E8EF7';
  }

  onMount(async () => {
    await carregarEstado();
    await carregarControl();
    abrirSSE();
    setInterval(carregarEstado, 5000);
  });
</script>

<div class="mc">
  <header>
    <h1>Mission Control — Lume OS</h1>
    <div class="status">
      <span class="indicador" style="background:{corBlockers()}"></span>
      <span>Fase {estado?.fases?.[0]?.id ?? '—'} | Global {pctGlobal()}% | Blockers {estado?.blockers_totais ?? 0}</span>
      <button onclick={togglePause}>{pausada ? 'Retomar' : 'Pausar'}</button>
    </div>
  </header>

  <main>
    <section class="fases">
      <h2>Fases</h2>
      {#each estado?.fases ?? [] as f}
        <div class="fase-card">
          <div class="fase-head">
            <strong>#{f.id} {f.nome}</strong>
            <span class="gate" style="color:{f.gate.blockers > 0 ? '#C42B1C' : '#3E8EF7'}">
              gate: testes {f.gate.testes.join(', ')} | blockers {f.gate.blockers} | signoff {f.gate.signoff}
            </span>
          </div>
          <div class="progresso">
            <div class="barra" style="width:{pctFase(f)}%; background:#3E8EF7"></div>
            <span>{pctFase(f)}%</span>
          </div>
          <ul>
            {#each f.tarefas as t}
              <li class:bloqueada={t.status === 'bloqueada'} class:feita={t.status === 'feita'}>
                {t.desc} — <em>{t.status}</em> (retry {t.retry})
              </li>
            {/each}
          </ul>
        </div>
      {/each}
    </section>

    <section class="heartbeat">
      <h2>Heartbeat</h2>
      <div class="hb-form">
        <input bind:value={heartbeatTarefa} placeholder="tarefa" />
        <input bind:value={heartbeatArquivo} placeholder="arquivo" />
        <button onclick={enviarHeartbeat} disabled={!heartbeatTarefa}>
          {heartbeatStatus || 'Enviar heartbeat'}
        </button>
      </div>
      <p class="hb-hint">Heartbeat a cada tarefa e a cada 60 s em ops longas. Stale > 10 min = alerta vermelho.</p>
    </section>

    <section class="eventos">
      <h2>Eventos (SSE)</h2>
      <ul class="evt-list">
        {#each eventos as e}
          <li class="evt" class:tipo={e.tipo}>
            <span class="ts">{new Date(e.ts).toLocaleTimeString('pt-BR')}</span>
            <span class="tipo">{e.tipo}</span>
            <span class="fase">{e.fase ?? '—'}</span>
            <span class="tarefa">{e.tarefa ?? '—'}</span>
            <span class="payload">{JSON.stringify(e.payload).slice(0, 120)}</span>
          </li>
        {/each}
      </ul>
    </section>

    <section class="shots">
      <h2>Galeria QMP (design/shots/<fase>/)</h2>
      <p>Capturas via QMP screendump a cada tarefa. Diff estrutural vs design/references/.</p>
    </section>
  </main>

  <footer>
    Lume OS · CalVer 2026.11 · Sessão 5 h · http://localhost:7777
  </footer>
</div>

<style>
  :global(body) { margin: 0; font-family: 'Inter', system-ui, sans-serif; background: #0E1116; color: #F7F9FC; }
  .mc { max-width: 1200px; margin: 0 auto; padding: 24px; }
  header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; border-bottom: 1px solid #334155; padding-bottom: 12px; }
  h1 { margin: 0; font-size: 20px; color: #3E8EF7; }
  .status { display: flex; gap: 12px; align-items: center; }
  .indicador { width: 10px; height: 10px; border-radius: 50%; }
  main { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
  section { background: #101418; border-radius: 12px; padding: 16px; border: 1px solid #1e293b; }
  h2 { margin-top: 0; font-size: 16px; color: #94A3B8; }
  .fase-card { margin-bottom: 12px; }
  .fase-head { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 14px; }
  .gate { font-size: 12px; color: #64748B; }
  .progresso { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
  .barra { height: 6px; border-radius: 3px; background: #1e293b; flex: 1; }
  ul { margin: 0; padding-left: 18px; list-style: none; }
  li { font-size: 13px; margin: 4px 0; color: #CBD5E1; }
  li.bloqueada { color: #C42B1C; }
  li.feita { color: #4ADE80; }
  .hb-form { display: flex; gap: 8px; margin-bottom: 8px; flex-wrap: wrap; }
  .hb-form input { background: #0E1116; border: 1px solid #334155; color: #F7F9FC; padding: 6px 10px; border-radius: 8px; }
  .hb-form button { background: #3E8EF7; border: none; color: #0E1116; padding: 6px 14px; border-radius: 8px; cursor: pointer; font-weight: 600; }
  .hb-form button:disabled { opacity: 0.5; cursor: not-allowed; }
  .hb-hint { font-size: 12px; color: #94A3B8; margin: 0; }
  .evt-list { max-height: 300px; overflow-y: auto; font-size: 12px; font-family: 'JetBrains Mono', monospace; }
  .evt { padding: 4px 6px; border-bottom: 1px solid #1e293b; display: flex; gap: 8px; }
  .ts { color: #94A3B8; width: 70px; }
  .tipo { color: #3E8EF7; width: 110px; font-weight: 600; }
  .fase { color: #9D7BFA; width: 40px; }
  .tarefa { color: #F65A8E; width: 130px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .payload { color: #CBD5E1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  footer { margin-top: 24px; font-size: 12px; color: #64748B; text-align: center; }
  button { background: #334155; border: none; color: #F7F9FC; padding: 6px 14px; border-radius: 8px; cursor: pointer; }
  button:hover { background: #475569; }
</style>
