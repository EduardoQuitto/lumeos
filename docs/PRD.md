# PRD — Lume OS
**Versão do documento:** 1.0 · **Versão do produto:** CalVer 2026.11 (release 0.1) · **Status:** aprovado para execução · **Fonte da verdade:** este PRD + `roadmap.yaml` · **Idiomas:** pt-BR, en-US · **Repo:** `lume-os` (monorepo)

---

## 1. Visão
SO Linux leve, imutável na base, visual premium (estrutura Windows 11 + física/materiais macOS), que devolve vida a PCs fracos e roda em pendrive persistente, RAM ou HD. Diferencial: mesma elegância em 3 tiers de hardware com ~1/5 da RAM do Windows 11.
**Objetivos:** idle ≤ 250–450 MB por tier · boot < 30 s · instalação em 5 min · update com rollback · segurança por isolamento em 3 níveis.
**Não-objetivos (limites honestos):** cloud gaming/Roblox/Cursor só tiers B/C (P4 não decodifica stream — física, não peso do SO) · apps macOS fora de escopo (Darling só CLI) · "todos os comandos" = repositório Debian via apt, não embutidos · "E2EE" = criptografia em repouso/trânsito/cofre, não de mensagens · Lite (i386) tem base Debian 12 com LTS até 06/2028 · ETA do painel é estimativa, não oráculo.

## 2. Edições e detecção
| Edição | Arq. | Alvo | Sessão | Materiais | Idle |
|---|---|---|---|---|---|
| Lite | i386 (PAE) | P4, 1–2 GB, GPU 2004–09 | Openbox + picom + host QML | Vidro-lite se GL≥2.1, senão Sólido | ≤250 MB |
| Core | amd64 | <4 GB ou GPU sem GLES3.2/VA-API | labwc + Quickshell | Névoa + Sólido + sombras | ≤350 MB |
| Prime | amd64 | ≥4 GB + GLES3.2 | Hyprland + Quickshell | Vidro + Névoa + Sólido | ≤450 MB |

`lume-detect` classifica no boot (CPU/RAM/GPU/VA-API/VM); VM→Core padrão; override via OOBE, `lume tier set`, `lume.session=`. Badge no splash, Sobre, loja, `lume-fetch`. ISOs: `lume-lite-i386.iso` (≤900 MB), `lume-amd64.iso` (≤1,4 GB); Rufus/Etcher/Ventoy; QEMU/VirtualBox/VMware; checksums assinados.

## 3. Arquitetura
`QML (shell/apps) ⇄ D-Bus ⇄ daemons Rust ⇄ systemd/Debian`. Rust: detect, updated, shield, filesd, stored, cli, mission-control. Qt6/QML: shell (Quickshell) + apps; Lite host QML X11 (Qt6 i386, fallback Qt5). C++ só upstream (Hyprland/labwc). greetd + lume-greeter (login+lock). PipeWire/WirePlumber, NetworkManager, bluez, logind+power-profiles-daemon (B/C), CUPS/IPP. Firmware non-free incluído; NVIDIA = pacote pós-instalação opcional (C). Swap só zram (zstd); hibernação off padrão (opcional swapfile HD B/C). Firefox ESR sem tema custom v1.
**Disco:** USB = ISO9660 (SquashFS+verity) + `LUME-DATA` LUKS2 ext4. HD = EFI 512 MB + `LUME-BOOT` ext4 (slotA.img/slotB.img SquashFS+verity, kernels por slot) + `LUME-DATA` LUKS2; GRUB assinado (shim) + grubenv de sucesso.
**Update:** GitHub Releases (stable/beta) → manifesto minisign → slot inativo → tela de reinício → boot B → health-check 2 boots → rollback automático se falhar; persistência intacta; deltas zsync/casync pós-fase 23.

## 4. Marca e design system
**Logo:** conceito aprovado (L+pétala+arcos orbitais); redesenhar SVG geométrico; 6 variantes (cor escuro/claro, mono branco/tinta, acento, simplificada <24 px); glow só splash/marketing; clear space 25%; squircle 22% ícone app.
**Paleta:** `#45C8F5 #3E8EF7 #9D7BFA #F65A8E #FF8A5C`; **acento UI `#3E8EF7`** (gradiente completo só marca/splash/wallpaper); tinta `#0E1116`, papel `#F7F9FC`.
**Tokens:** raio janela 12 / flyout 16 / controle 8 / barra pílula; grid 4 pt; Inter 12/13/15/20/28/34; Inter Tight wordmark; JetBrains Mono terminal; sombra 2 camadas + borda interna 1 px; focus ring 2 px.
**Materiais:** Vidro = kawase 3 passes + ruído 2% + tint 60% + saturação +10%; Névoa = tint wallpaper 80%; Sólido fallback. Blur em painéis/flyouts sempre; janela inteira só Prime.
**Motion:** molas stiffness 320/damping 28; micro 120 ms ease-out; movimento reduzido → fade 100 ms; Lite subset picom.
**Assets:** ícones Fluent (MIT) + pastas/dispositivos próprios; cursor **Lume Arrow** (ponta suave, 24/32/48, variantes; espera = arcos do logo girando); wallpaper **Aurora Lume** procedural dessaturado claro/escuro (vivo opcional Prime 30 fps, pausa bateria/fullscreen); sons originais CC0 (notificação/volume/erro; startup off); Plymouth com arcos orbitais. **Proibido assets Apple/Microsoft** (wallpaper Big Sur, Edge, App Store do mockup = substituir).

## 5. Shell
Barra 48 px, margem 8, pílula, ícones 28, dot 3 px, hover lift 2 px, overflow chevron; tray: Wi-Fi→painel redes; cluster volume/bateria→quick settings; relógio 2 linhas por locale→calendário+notificações; bateria só se existir.
Menu iniciar 640×560: busca topo, grid 6×3 fixados, recentes, rodapé usuário+energia. Busca universal: apps/arquivos/configs/cálculo (web off padrão).
Flyouts 360–400 px raio 16 Vidro, slide 12 px mola: quick settings (6 toggles + 2 sliders + bateria + editar), redes (lista/senha/oculta/WireGuard), volume (dispositivos), calendário+notificações (mês + lista + limpar).
Toasts topo-direita 360 px stack 3, 2 ações, 5 s (crítico persiste), DND. Alt+Tab switch; Super+Tab overview; snap bordas/cantos + Super+setas + 4 layouts hover maximizar; context menus raio 8 com ícones 16; desktop ícones off padrão + menu direito completo; decorações CSD QML (titlebar 40 px, fechar hover `#C42B1C`) + plugin libdecor Lume para terceiros + tema Openbox equivalente.
**Atalhos:** Super menu · Super+E files · Super+I settings · Super+L lock · Super+D desktop · Super+Tab overview · Alt+Tab · Print captura · Super+Shift+S região · Ctrl+Alt+T terminal · Super+` quake · Super+V clipboard. Touchpad natural ON toggle; 3 dedos cima overview, lat. workspaces.

## 6. Apps do sistema
| App | Requisito mínimo |
|---|---|
| Files | toolbar, breadcrumb editável, abas, busca rg, grade/lista, sidebar lugares/dispositivos/lixo, drag-drop, extração p7zip, propriedades, udisks2 |
| Settings | 16 páginas espelhando Win11; Sobre com badge edição/tier/hardware/versão/canal |
| Store | 8 categorias (Essenciais, Internet, Estudo&Office, Programação, Jogos, Windows, Segurança/Lab, Sistema), badges tier, fila, updates separado sistema/apps, aba garrafas, curadoria bilíngue, sem reviews v1 |
| Terminal | foot (Wayland)/xfce4-terminal (Lite); bash+starship+fzf+zoxide; abas, quake, perfis, command-not-found, man+tldr |
| Task Manager | árvore /proc, gráficos CPU/RAM/GPU (Prime), startup, matar |
| Security Center | checklist Shield, toggle firewall, inspetor sandbox, launcher Cofre (C), aviso modo live |
| Updates | canal, checar, progresso, reiniciar agora/depois, rollback, histórico |
| Editor / Viewer / PDF / Calc | leves, QML, MIME defaults |
| Screenshot | tela/região/janela + gravação (Prime) |
| Welcome / Backup / Bottles | tour; backup LUKS; garrafas bwrap com pasta única compartilhada |
| Greeter/Lock | greetd+QML, prompt LUKS via Plymouth antes |
| CLI `lume` | update, shield, tier, store, fetch, session |

**Pré-instalados:** lista acima + Firefox ESR + VLC + p7zip. **Pacote Essenciais (OOBE 1 clique):** OnlyOffice, WhatsApp PWA, Spotify/Discord/Zoom/Steam por tier, Teams PWA, Brave opcional. PWAs = Firefox modo app + .desktop + ícone. Essenciais terminal: ls cp mv rm mkdir grep sed awk find cat less head tail chmod ps kill htop df du free ip ping ss curl wget git ssh tar nano vim tmux journalctl systemctl apt dmesg lsblk mount sudo man tldr.

## 7. Segurança — Lume Shield
LUKS2 padrão (USB+HD) · verity nos slots · Secure Boot+lockdown=integrity+módulos assinados (B/C); Lite BIOS compensa com verity+LUKS · AppArmor enforce · seccomp nos daemons · nftables default-deny entrada · zero telemetria (crash local opt-in) · sudo live passwordless avisado / instalado com senha · TPM2 opcional off.
**Isolamento 3 níveis:** (1) loja = Flatpak presets por categoria; (2) Windows = garrafas bwrap; (3) **Modo Cofre** = microVM cloud-hypervisor descartável, só C ≥8 GB. Lab pentest isolado + aviso legal (uso autorizado apenas).

## 8. Sessão e ciclo
Splash Plymouth → (LUKS) → OOBE (idioma/teclado/rede/usuário/criptografia/tier/Essenciais) → greeter → sessão → lock (idle/suspend) → telas Plymouth de desligar/reiniciar/"Instalando atualização, não desligue" → suspensão por tier. Instalador HD = Calamares branded (EFI+LUKS+A/B); criador de pendrive persistente com LUKS + backup/restore.

## 9. Release e CI
CalVer; GitHub Actions builda 2 ISOs (nightly + tag); checksums; **assinatura minisign offline pelo usuário**; agente nunca assina/push externo. Site de download + docs + guia de instalação.

## 10. i18n / a11y
pt-BR padrão (ABNT2 auto) + en-US 100%; Qt .ts + gettext Rust; formatos por locale (24 h pt). Orca, lupa (Prime), alto contraste, texto 1.25×, teclas aderência, movimento reduzido, navegação teclado total.

## 11. Budgets e testes
| Métrica | Meta |
|---|---|
| Boot até greeter | <20 s VM Prime / <30 s real B |
| Idle | 450/350/250 MB (Prime/Core/Lite) |
| Flyout | ≤150 ms |
| ISO | ≤1,4 GB amd64 / ≤900 MB i386 |
| Animações | 60 fps Prime na UHD 730 |

Matriz QEMU: virtio-gpu+GL (Prime), qxl (Core), i386 VGA (Lite). Testes: boot, instalação disco vazio 20 GB, update+rollback, tamper verity, escape sandbox, screenshot diff por build. Instalação VM obrigatória fases 15/16/23/26.

## 12. Mission Control (fase 0)
axum+SQLite+SSE (:7777) + web Svelte; LAN opcional com token. Mostra: % por fase e global (pesos), tarefa atual+arquivo, início da sessão/decorrido, ETA por velocidade (EWMA), erros+traceback+retry, galeria screenshots por build, matriz de testes VM, heartbeat (stale>10 min alerta), pausar/retomar, relatório diário, backlog. Fontes: roadmap.yaml + events.sqlite + git + CI.

## 13. Execução do agente
Fases sequenciais; gate de fim de fase = suíte + blockers 0; não-blockers→backlog com varredura nas fases 5/10/15/20/25; 3 falhas→bloqueada+alerta+segue independentes; commits convencionais por tarefa, tag `phase-N-done`; rustfmt/clippy -D warnings/qmllint; builds root só Podman; **proibido dd/parted/mkfs em disco real** (só loop+QEMU); sudo whitelist; sessão 5 h (systemd timer), CPUQuota 60%; heartbeat+screenshots QMP por tarefa; nunca assinar/push externo. Dev: i5-14400/32 GB/NVMe/iGPU; 5 h/dia; semana 1 = fases 0–2 + início da 3 (expectativa, não promessa).

## 14. Roadmap (28 fases · pesos somam 100)
| # | Fase | Aceite (gate) | Peso |
|---|---|---|---|
| 0 | Fundação + Mission Control | painel :7777 + heartbeat + CI QEMU verde | 4 |
| 1 | Design system + assets | tokens + logo 6 variantes + cursor + wallpapers + sons | 4 |
| 2 | ISO amd64 boot | boot <20 s + Plymouth + screenshot | 4 |
| 3 | Daemons Rust + detect | tiers + D-Bus + lume-fetch | 3 |
| 4 | Barra/tray/relógio | pílula + indicadores + locale | 4 |
| 5 | Flyouts | 4 painéis <150 ms | 4 |
| 6 | Iniciar + busca | menu + 4 provedores | 3 |
| 7 | Janelas/snap/overview | libdecor + 4 layouts + alt-tab | 4 |
| 8 | Files | toolbar+abas+busca+lixo+montagem | 4 |
| 9 | Settings p1 | 8 páginas | 4 |
| 10 | Settings p2 + Security | 8 páginas + checklist Shield | 4 |
| 11 | Terminal + CLI | quake+command-not-found+CLI completa | 3 |
| 12 | Loja | 8 categorias + badges + flatpak | 4 |
| 13 | Essenciais/PWA/MIME | OOBE 1 clique + PWAs + defaults | 3 |
| 14 | OOBE/login/energia | greeter+lock+telas Plymouth | 4 |
| 15 | Instalador HD | disco vazio VM + LUKS + A/B | 4 |
| 16 | Pendrive persistente | criador LUKS + backup/restore | 3 |
| 17 | Lite i386 | boot + X11 + picom + idle ≤250 MB | 4 |
| 18 | Core | labwc + materiais + idle ≤350 MB | 3 |
| 19 | Camada Windows | Wine+NTSYNC+garrafas+selos+3 apps | 4 |
| 20 | Jogos/nuvem | Steam/Proton + Sober best-effort + PWAs por tier | 3 |
| 21 | Shield hardening | verity+lockdown+AppArmor+seccomp+nftables+tamper | 4 |
| 22 | Modo Cofre | microVM descartável sem resíduo | 3 |
| 23 | Update A/B + GitHub | manifesto+slot B+rollback + teste | 4 |
| 24 | i18n + a11y | pt/en 100% + Orca+contraste+movimento | 3 |
| 25 | Performance | budgets nos 3 tiers | 3 |
| 26 | Suíte VM | matriz+instalação+update+segurança+diff | 3 |
| 27 | Beta/release | QA real + docs + site + 0.1 assinada | 3 |

## 15. Repositório
`docs/ design/ shell/{quickshell,lite-host,greeter,libdecor-lume} apps/{16 apps} services/{detect,updated,shield,filesd,stored,cli} build/{live-build,packages,podman} iso/{plymouth,calamares,grub,hooks} mission-control/{backend,web} tests/{qemu,smoke,screenshots,security} .github/workflows` + `AGENTS.md roadmap.yaml README LICENSE`.

## 16. Riscos
| Risco | Mitigação |
|---|---|
| i386 sem upstream pós-2028 | congelar base + backports próprios; plano de aposentadoria do Lite |
| Sober quebrado por anti-cheat | best-effort, selo na loja, nunca promessa |
| Qt6 i386 ausente | fallback Qt5 no Lite |
| Blur lento em VM | teste de fluidez só em hardware real |
| Update ~1 GB | deltas zsync/casync pós-23 |
| Agente em loop | 3-strike + blockers + heartbeat + pause |
| Marca "Lume" ocupada | checagem INPI/domínios na fase 0; nome de trabalho até registrar |

## 17. Fora de escopo v1
Apps macOS · reviews na loja · deltas de update · NVIDIA na ISO · hibernação padrão · telemetria · tema custom no Firefox · contas/nuvem · Wayland no Lite.

## 18. Ações humanas (não delegáveis)
Registrar marca/domínio/org · guardar chave minisign e assinar releases · QA em hardware real · sign-off visual por fase.

## 19. Definição de pronto (v0.1)
28 fases fechadas com blockers 0 · budgets atingidos nos 3 tiers · instalação/update/rollback provados em VM · pt/en completos · assets 100% originais/licenciados · release assinada pelo usuário · Mission Control com histórico completo.

---