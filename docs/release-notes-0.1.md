# Release Notes — Lume OS CalVer 2026.11 (Release 0.1 Beta)

## Visão Geral

Este é o **primeiro release beta** do Lume OS, um SO Linux leve, premium e imutável desenvolvido para devolver vida a PCs fracos e rodar em pendrive persistente, RAM ou HD.

## Novidades nesta Release

### Sistema Base
- Base imutável SquashFS+verity com update A/B e rollback automático
- Persistência LUKS2 em pendrive persistente (`LUME-DATA`)
- Base Debian 12 (i386) / Debian 13 (amd64)
- systemd, PipeWire/WirePlumber, NetworkManager, bluez, logind, power-profiles-daemon
- zram (swap com zstd), hibernação desligada por padrão

### Shell e Interface (Qt6/QML)
- Barra pílula (48 px, margem 8 px, ícones 28 px, dot de notificação)
- Menu Iniciar 640×560 com busca no topo, grid 6×3, recentes, rodapé usuário+energia
- Flyouts: redes, quick settings, volume, calendário+notificações (abrem <150 ms)
- Janelas com CSD QML (titlebar 40 px, controles à direita, sombra 2 camadas, raio 12 px)
- Alt+Tab, Super+Tab (overview), snap de janelas (4 layouts)
- Toasts, desktop ícones off por padrão, decorações CSD QML

### Aplicativos do Sistema
| App | Função |
|-----|--------|
| Files | toolbar, breadcrumb editável, abas, busca rg, grade/lista, sidebar, drag-drop, extração p7zip |
| Settings | 16 páginas espelhando Win11; Sobre com badge edição/tier/hardware/versão/canal |
| Store | 8 categorias, badges tier, fila, updates separado sistema/apps, aba garrafas |
| Terminal | foot (Wayland)/xfce4-terminal (Lite); bash+starship+fzf+zoxide; abas, quake |
| Task Manager | árvore /proc, gráficos CPU/RAM/GPU (Prime), startup, matar |
| Security Center | checklist Shield, toggle firewall, inspetor sandbox, launcher Cofre (C), aviso modo live |
| Updates | canal, checar, progresso, reiniciar agora/depois, rollback, histórico |
| Editor / Viewer / PDF / Calc | leves, QML, MIME defaults |
| Screenshot | tela/região/janela + gravação (Prime) |
| Welcome / Backup / Bottles | tour; backup LUKS; garrafas bwrap |
| Greeter/Lock | greetd+QML, prompt LUKS via Plymouth antes |

### Pré-instalados
Lista acima + Firefox ESR + VLC + p7zip.

**Pacote Essenciais (OOBE 1 clique):** OnlyOffice, WhatsApp PWA, Spotify/Discord/Zoom/Steam por tier, Teams PWA, Brave opcional.

PWAs = Firefox modo app + .desktop + ícone.

Essenciais terminal: ls cp mv rm mkdir grep sed awk find cat less head tail chmod ps kill htop df du free ip ping ss curl wget git ssh tar nano vim tmux journalctl systemctl apt dmesg lsblk mount sudo man tldr.

### Segurança — Lume Shield
- LUKS2 padrão (USB+HD)
- Verity nos slots
- Secure Boot+lockdown=integrity+módulos assinados (B/C)
- Lite BIOS compensa com verity+LUKS
- AppArmor enforce
- seccomp nos daemons
- nftables default-deny entrada
- zero telemetria (crash local opt-in)
- sudo live passwordless avisado / instalado com senha
- TPM2 opcional off

### Isolamento em 3 Níveis
1. **loja:** Flatpak presets por categoria
2. **Windows:** Garrafas bwrap com pasta única compartilhada
3. **Modo Cofre:** microVM cloud-hypervisor descartável (só C ≥8 GB)

Lab pentest isolado + aviso legal (uso autorizado apenas).

### Sessão e Ciclo
Splash Plymouth → (LUKS) → OOBE (idioma/teclado/rede/usuário/criptografia/tier/Essenciais) → greeter → sessão → lock (idle/suspend) → telas Plymouth de desligar/reiniciar/"Instalando atualização, não desligue" → suspensão por tier.

Instalador HD = Calamares branded (EFI+LUKS+A/B); criador de pendrive persistente com LUKS + backup/restore.

### Release e CI
CalVer; GitHub Actions builda 2 ISOs (nightly + tag); checksums; assinatura minisign offline pelo usuário; agente nunca assina/push externo. Site de download + docs + guia de instalação.

### i18n / a11y
pt-BR padrão (ABNT2 auto) + en-US 100%; Qt .ts + gettext Rust; formatos por locale (24 h pt). Orca, lupa (Prime), alto contraste, texto 1.25×, teclas aderência, movimento reduzido, navegação teclado total.

### Budgets e Testes
| Métrica | Meta |
|---------|------|
| Boot até greeter | <20 s VM Prime / <30 s real B |
| Idle | 450/350/250 MB (Prime/Core/Lite) |
| Flyout | ≤150 ms |
| ISO | ≤1,4 GB amd64 / ≤900 MB i386 |
| Animações | 60 fps Prime na UHD 730 |

Matriz QEMU: virtio-gpu+GL (Prime), qxl (Core), i386 VGA (Lite). Testes: boot, instalação disco vazio 20 GB, update+rollback, tamper verity, escape sandbox, screenshot diff por build. Instalação VM obrigatória fases 15/16/23/26.

---

## Como Instalar

1. Baixe a ISO da edição desejada
2. Grave em um pendrive com Rufus, Etcher ou Ventoy
3. Inicie pelo pendrive (ajuste a ordem de boot na BIOS/UEFI se necessário)
4. No OOBE (Primeira Execução), configure idioma, teclado, rede, usuário, criptografia, tier/Essenciais
5. O instalador (Calamares branded) fará: EFI 512 MB + `LUME-BOOT` ext4 (slotA.img/slotB.img SquashFS+verity) + `LUME-DATA` LUKS2; GRUB assinado (shim) + grubenv de sucesso
6. Reinicie e remova o pendrive

---

## Suporte

- **Issues:** Abra uma issue no GitHub para bugs ou sugestões
- **Mission Control:** Acompanhe o desenvolvimento em tempo real (painel em `http://localhost:7777` durante o desenvolvimento)
- **Documentação:** `docs/PRD.md`, `docs/VISION.md`, `docs/MISSION-CONTROL.md`, `docs/OPEN.md`

---

> **Lume OS** — Devolvendo vida a PCs fracos, com visual premium e segurança por isolamento.  
> *CalVer 2026.11 • Release 0.1 Beta • Monorepo*

---

*Documentação gerada a partir do monorepo Lume OS. Para a versão mais atualizada, consulte os arquivos em `docs/` e o roadmap ativo no repositório.*
