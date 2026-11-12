# PROJECT.md — Lume OS · leia primeiro

## O que é
Sistema operacional Linux leve, base imutável, visual premium (estrutura Windows 11 +
física/materiais macOS), em 3 edições detectadas por hardware: Lite (i386), Core e Prime
(amd64). Roda em pendrive persistente, RAM ou HD. Rust nos serviços, Qt6/QML na interface,
D-Bus como ponte. Base Debian (12 i386 / 13 amd64). Versão CalVer 2026.11, canal stable.

## Contexto do dono
Dono = tech lead e decisor visual. Executor = opencode, 5 h/dia, máquina i5-14400/32 GB/
NVMe/iGPU. Uso real do dono: estudo, jogos leves, programação, hacking ético autorizado.
Idiomas pt-BR e en-US. O dono acompanha tudo pelo Mission Control e dá sign-off visual.

## Missão do agente
Executar roadmap.yaml da fase 0 à 27, sequencialmente, com gates de erro. Construir tudo
que o PRD especifica, na aparência que o VISION descreve. Manter o Mission Control ao vivo
(% por fase, tarefa atual, erros, screenshots, início/decorrido/ETA). Nunca inventar escopo.
Dúvida de produto: registrar em docs/OPEN.md, aplicar o padrão do PRD e seguir — não parar.

## Mapa de leitura (ordem)
1. PROJECT.md (este)  2. AGENTS.md  3. roadmap.yaml  4. docs/PRD.md
5. docs/VISION.md     6. design/wallpapers.yaml + design/references/ + design/brand/
Precedência: PRD (função/segurança/performance) > VISION (estética) > referências (pixels)
> gosto do agente (nunca). Conflito: registrar em OPEN.md e pedir sign-off ao dono.

## Comece por
Fase 0: árvore do repo, Mission Control (:7777), CI QEMU, timer de 5 h, heartbeat.
Depois siga o roadmap sem pular fases.

## Regras inegociáveis (detalhe em AGENTS.md)
- Nunca dd/parted/mkfs em disco real; só imagens loop e QEMU. Builds root só em Podman.
- Gate de fim de fase: suíte de testes + blockers 0. Varredura de backlog nas fases 5/10/15/20/25.
- 3 falhas na mesma tarefa → bloqueada + alerta + seguir tarefas independentes.
- Nunca assinar releases, nunca push externo, nunca guardar chaves.
- Heartbeat + status + screenshot QMP a cada tarefa; commit convencional; tag phase-N-done.
- Assets 100% originais ou licenciados (Fluent MIT, fontes OFL). Proibido Apple/Microsoft.

## Definição de pronto
PRD §19 + checklist visual do VISION + release 0.1 assinada pelo dono.

## Ações só do dono
Registrar marca/domínio/org · guardar chave minisign e assinar · QA em hardware real ·
sign-off visual por fase.

## Estado
Fase atual: 0 · blockers: 0 · próxima entrega: Mission Control no ar.