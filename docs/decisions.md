# OPEN.md — dúvidas e conflitos (agente escreve, dono resolve)
Formato: | data | fase | questão | padrão aplicado (PRD/VISION) | status | decisão do dono |
|---|---|---|---|---|---|
| 2026-11-13 | 0 | exemplo: nome de domínio livre? | seguir com lume-os como nome de trabalho | aberto | — |
| 2026-11-12 | 0 | CI QEMU (qemu-smoke) não executável no host Windows nativo (sem WSL/Docker). tests/qemu/smoke.sh criado como artefato para rodar em VM Linux/QEMU portátil. | aplicar padrão PRD: entregar pipeline como artefato, não exigir WSL do dono | aberto | — |
| 2026-11-13 | P0 | services/detect, shield, stored, updated não compilam (campos inexistentes, struct duplicada, hex 0.13 inválido, serde_json_derive inexistente) | corrigir código e Cargo.toml de cada serviço | resolvido | — |
| 2026-11-13 | P1 | Vários arquivos exigidos pelos smoke tests não existem (configs lite/core, i18n, a11y, performance, update-manifest, CoreShell.qml, web/dist/index.html, fase26.ps1) | criar placeholders válidos | resolvido | — |
| 2026-11-13 | P2 | build.sh usa ${ISO_OUT} inexistente, pacote NVIDIA inválido, grub-install /dev/sda (disco real proibido) | corrigir variável para ${ISO_PATH}, remover NVIDIA, pipewire/wireplumber minúsculos, remover grub-install /dev/sda | resolvido | — |
| 2026-11-13 | P2 | Não há workspace Cargo na raiz → CI lint falha | criar Cargo.toml workspace com todos os serviços Rust | resolvido | — |
| 2026-11-13 | P3 | Mission Control hardcoda as 28 fases em vez de ler roadmap.yaml | usar serde_yaml para fazer parse do roadmap.yaml | resolvido | — |
| 2026-11-13 | P3 | shots_handler retorna [] vazio | ler arquivos reais de design/shots/<fase>/ | resolvido | — |
| 2026-11-13 | P4 | Shell.qml é mock visual que não corresponde à expectativa_do_projeto.jpg | reescrever Shell.qml com wallpaper Aurora Peaks, barra pílula inferior, janela Lume Files, sidebar, grade, tray | resolvido | — |
| 2026-11-13 | P4 | Ícones da barra são emoji/texto temporários; design/icons/ está vazio | substituir por ícones SVG/PNG reais quando disponíveis | aberto | — |
| 2026-11-13 | P4 | Snap.qml e AltTab.qml referenciam janelaLume que não existe no escopo | passar janela alvo via property/contexto | aberto | — |
| 2026-11-13 | P5 | fase29.ps1, fase25.ps1, fase28.ps1 usam variável $f24 no lugar da correta | corrigir para $f29, $f25, $f28 | resolvido | — |
| 2026-11-13 | P6 | docs/decisions.md está vazio (0 linhas) | preencher com decisões tomadas | resolvido | — |
| 2026-11-13 | P6 | roadmap.yaml tem fases 28 e 29 anexadas, quebrando sequência 0-27 do PRD §14 | remover fases 28/29 ou manter apenas 0-27 | aberto | — |
| 2026-11-13 | P6 | Tarefas t0-3 e t0-4 estão pendente mas signoff da fase 0 diz concluído | alinhar status das tarefas com signoff da fase 0 | aberto | — |
| 2026-11-13 | P6 | Fases 17, 18, 27 (t27-2 docs) com status pendente | revisar status conforme implementação feita | aberto | — |

Regra: nunca parar por dúvida. Aplicar o padrão do PRD, registrar aqui, seguir.
Conflito estética×função: PRD vence em função/segurança/perf; referência vence em estética; sign-off do dono.
