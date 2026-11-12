# Lume OS
SO Linux leve e premium em 3 edições detectadas por hardware (Lite i386 / Core / Prime).
Base imutável SquashFS+verity, persistência LUKS2, update A/B com rollback via GitHub Releases.
Rust nos serviços · Qt6/QML na interface · D-Bus como ponte. CalVer 2026.11.

## Documentos (ordem de leitura)
PROJECT.md → AGENTS.md → roadmap.yaml → docs/PRD.md → docs/VISION.md →
docs/MISSION-CONTROL.md → design/tokens.json → design/wallpapers.yaml

## Execução
Agente: opencode, 5 h/dia, fases sequenciais com gates. Acompanhamento: Mission Control
em http://localhost:7777. Releases assinadas offline pelo dono (minisign).

## Licenças
Código próprio: MIT (LICENSE). Componentes upstream mantêm suas licenças; inventário
completo gerado na fase 27 (NOTICE.md). Assets de marca: originais. Proibido Apple/Microsoft.

## Estado
Fase 0 · ver Mission Control para % ao vivo, erros e screenshots.