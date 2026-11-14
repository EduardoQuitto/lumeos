# Lume OS - Site Oficial

# Lume OS - SO Linux leve e premium

SO Linux leve, premium e imutável — construído para devolver vida a PCs fracos e rodar em pendrive persistente, RAM ou HD. Visual premium em 3 edições detectadas por hardware: **Lite (i386)**, **Core** e **Prime (amd64)**.

## 🎯 O que é o Lume OS

O **Lume OS** é um sistema operacional Linux leve, imutável na base e com visual premium (estrutura inspirada no Windows 11 com física e materiais macOS). Desenvolvido em **Rust** para os serviços do sistema e **Qt6/QML** para a interface, ele roda em computadores fracos, pendrives persistentes, RAM ou HD — com ~1/5 do consumo de RAM do Windows 11.

> **Versão:** CalVer 2026.11 (release 0.1)  
> **Status:** Beta release 0.1  
> **Idiomas:** pt-BR, en-US  
> **Licença:** MIT (código próprio), componentes upstream mantêm suas licenças

---

## 🖥️ Como o Lume OS se parece

A interface segue a filosofia **"Vidro calmo sobre luz"**: desktop limpo, uma barra pílula inferior, janelas de vidro flutuando, movimento de mola e nada gritando.

| Componente | Descrição |
|------------|-----------|
| **Barra pílula** | 48 px, margem 8 px, ícones 28 px, dot de notificação, hover lift, overflow com chevron |
| **Menu Iniciar** | 640×560, busca no topo, grid 6×3, recentes, rodapé usuário+energia |
| **Flyouts** | 4 painéis (redes, quick settings, volume, calendário+notificações), raio 16, vidro, abrem <150 ms |
| **Janelas** | Vidro + sidebar tingida, raio 12, titlebar 40 px com controles à direita, sombra 2 camadas, abrir com escala .96→1 (mola) |
| **Alt+Tab / Overview** | Thumbnails centralizados, 4 layouts de snap no hover do maximizar |
| **Greeter / Lock** | Wallpaper escurecido+blur, relógio grande, avatar central, senha em pílula |
| **OOBE** | Cartão central de vidro: idioma, teclado, rede, usuário, criptografia, tier, Essenciais |

> Todos os wallpapers são **originais** (pack Aurora Lume e variantes), sem uso de assets da Apple ou Microsoft.

---

## 🚀 Como usar / Como instalar

### 1. Baixar a ISO
Acesse a seção de **Releases** deste repositório e baixe a ISO adequada ao seu hardware:

| Edição | Arquitetura | Alvo | Tamanho |
|--------|-------------|------|---------|
| **Lite** | i386 (PAE) | P4, 1–2 GB, GPU 2004–2009 | ≤ 900 MB |
| **Core** | amd64 | <4 GB ou GPU sem GLES3.2/VA-API | ≤ 1,4 GB |
| **Prime** | amd64 | ≥4 GB + GLES3.2/VA-API | ≤ 1,4 GB |

### 2. Criar pendrive de instalação
Use **Rufus**, **Etcher** ou **Ventoy** para gravar a ISO em um pendrive (mínimo 8 GB, recomendado 16 GB+).

### 3. Instalar no computador
1. Inicie o computador pelo pendrive (ajuste a ordem de boot na BIOS/UEFI se necessário).
2. No **OOBE** (Primeira Execução), configure:
   - Idioma e teclado (ABNT2 automático para pt-BR)
   - Rede (Wi-Fi ou cabo)
   - Usuário e senha
   - Criptografia de disco (LUKS2 recomendada)
   - Tier (Lite/Core/Prime) — ou deixe a detecção automática escolher
   - Pacote Essenciais (1 clique)
3. O instalador (Calamares branded) fará:
   - Particionamento EFI (512 MB) + `LUME-BOOT` (slots A/B SquashFS+verity) + `LUME-DATA` (LUKS2 ext4)
   - Instalação do sistema base imutável
   - Configuração do GRUB assinado (shim) com A/B rollback
4. Reinicie e remova o pendrive.

> **Nota:** O Lume OS não usa `dd`, `parted` ou `mkfs` diretamente em discos reais do usuário durante o desenvolvimento; todas as operações de disco são feitas via imagens loop e QEMU em ambiente de desenvolvimento controlado.

---

## 🧠 O que tem no SO

### Sistema base
- Base imutável **SquashFS+verity** (slots A/B para atualização com rollback automático)
- Persistência **LUKS2** (`LUME-DATA`)
- Base Debian (12 i386 para Lite, 13 amd64 para Core/Prime)
- systemd, PipeWire/WirePlumber, NetworkManager, bluez, logind, power-profiles-daemon
- zram (swap com zstd), hibernação desligada por padrão

### Shell e interface
- **Shell Quickshell** (Qt6/QML) com barra pílula, menu iniciar, flyouts, toasts, overview, alt-tab, snap
- **Lite host** (X11 + picom) para hardware fraco
- **libdecor Lume** para janelas terceiras (CSD QML, titlebar 40 px, cantos arredondados, sombra 2 camadas)
- Atalhos completos: Super (menu), Super+E (files), Super+I (settings), Super+L (lock), Super+D (desktop), Super+Tab (overview), Alt+Tab, Print, Ctrl+Alt+T (terminal), Super+` (quake terminal)

### Aplicativos do sistema
| App | Função |
|-----|--------|
| **Files** | toolbar, breadcrumb editável, abas, busca rg, grade/lista, sidebar lugares/dispositivos/lixo, drag-drop, extração p7zip, propriedades, udisks2 |
| **Settings** | 16 páginas espelhando Win11; Sobre com badge edição/tier/hardware/versão/canal |
| **Store** | 8 categorias (Essenciais, Internet, Estudo&Office, Programação, Jogos, Windows, Segurança/Lab, Sistema), badges tier, fila, updates separado sistema/apps, aba garrafas, curadoria bilíngue |
| **Terminal** | foot (Wayland)/xfce4-terminal (Lite); bash+starship+fzf+zoxide; abas, quake, perfis, command-not-found, man+tldr |
| **Task Manager** | árvore /proc, gráficos CPU/RAM/GPU (Prime), startup, matar |
| **Security Center** | checklist Shield, toggle firewall, inspetor sandbox, launcher Cofre (C), aviso modo live |
| **Updates** | canal, checar, progresso, reiniciar agora/depois, rollback, histórico |
| **Editor / Viewer / PDF / Calc** | leves, QML, MIME defaults |
| **Screenshot** | tela/região/janela + gravação (Prime) |
| **Welcome / Backup / Bottles** | tour; backup LUKS; garrafas bwrap com pasta única compartilhada |
| **Greeter/Lock** | greetd+QML, prompt LUKS via Plymouth antes |

### Pré-instalados
Lista acima + Firefox ESR + VLC + p7zip.  
**Pacote Essenciais (OOBE 1 clique):** OnlyOffice, WhatsApp PWA, Spotify/Discord/Zoom/Steam por tier, Teams PWA, Brave opcional.  
PWAs = Firefox modo app + .desktop + ícone.  
Essenciais terminal: ls cp mv rm mkdir grep sed awk find cat less head tail chmod ps kill htop df du free ip ping ss curl wget git ssh tar nano vim tmux journalctl systemctl apt dmesg lsblk mount sudo man tldr.

---

## 🛡️ Diferenças e diferenciais

| Recurso | Lume OS | Windows 11 | Linux típico |
|---------|---------|------------|--------------|
| **Idle RAM** | 250–450 MB | 2–4 GB | 500 MB–1 GB |
| **Base imutável** | ✅ SquashFS+verity | ❌ | ❌ (geralmente) |
| **Update A/B com rollback** | ✅ | ⚠️ Limitado | ❌ (geralmente) |
| **Persistência LUKS2 em pendrive** | ✅ | ❌ | ⚠️ Limitado |
| **3 edições por hardware** | ✅ (Lite/Core/Prime) | ❌ | ❌ |
| **Sem telemetria** | ✅ | ❌ | ✅ (geralmente) |
| **Isolamento (loja/garrafas/cofre)** | ✅ 3 níveis | ❌ | ⚠️ Parcial |
| **Visual premium** | ✅ | ⚠️ Parcial | ❌ |

### Isolamento em 3 níveis
1. **Loja:** Flatpak presets por categoria
2. **Windows:** Garrafas bwrap com pasta única compartilhada
3. **Modo Cofre:** microVM cloud-hypervisor descartável (só C ≥8 GB)

### Segurança — Lume Shield
- LUKS2 padrão (USB+HD)
- verity nos slots
- Secure Boot+lockdown=integrity+módulos assinados (B/C)
- AppArmor enforce
- seccomp nos daemons
- nftables default-deny entrada
- zero telemetria (crash local opt-in)
- sudo live passwordless avisado / instalado com senha
- TPM2 opcional off

---

## 🏗️ Arquitetura técnica

```
QML (shell/apps) ⇄ D-Bus ⇄ daemons Rust ⇄ systemd/Debian
```

### Serviços Rust
| Serviço | Função |
|---------|--------|
| `lume-detect` | classifica no boot (CPU/RAM/GPU/VA-API/VM); VM→Core padrão; override via OOBE, `lume tier set`, `lume.session=` |
| `lume-updated` | update A/B com rollback; GitHub Releases (stable/beta) → manifesto minisign → slot inativo → tela de reinício → boot B → health-check 2 boots → rollback automático se falhar |
| `lume-shield` | LUKS2 padrão; verity nos slots; Secure Boot+lockdown; AppArmor enforce; seccomp nos daemons; nftables default-deny entrada; zero telemetria; TPM2 opcional off |
| `lume-filesd` | detect, updated, shield, filesd, stored, cli — Rust; Qt6/QML: shell (Quickshell) + apps; Lite host QML X11 (Qt6 i386, fallback Qt5). C++ só upstream (Hyprland/labwc). |
| `lume-stored` | LUKS2 padrão (USB+HD) · verity nos slots · Secure Boot+lockdown=integrity+módulos assinados (B/C); Lite BIOS compensa com verity+LUKS |

### CLI `lume`
```bash
lume update        # update, shield, tier, store, fetch, session
lume shield        # checklist Shield, toggle firewall, inspetor sandbox, launcher Cofre (C), aviso modo live
lume tier          # classifica no boot (CPU/RAM/GPU/VA-API/VM); VM→Core padrão; override via OOBE, `lume tier set`, `lume.session=`
lume store         # 8 categorias, badges tier, fila, updates separado sistema/apps, aba garrafas
lume fetch         # classify no boot (CPU/RAM/GPU/VA-API/VM); VM→Core padrão; override via OOBE, `lume tier set`, `lume.session=`
lume session       # update, shield, tier, store, fetch, session
```

### CLI `lume` — comandos não encontrados
O `command-not-found` sugere pacotes para instalar via Flatpak quando você digita um comando não encontrado.

---

## 📊 Roadmap (28 fases)

O projeto segue 28 fases sequenciais com gates de erro (testes + blockers 0 + sign-off visual). Fases concluídas:

| Fase | Nome | Status |
|------|------|--------|
| 0 | Fundação + Mission Control | ✅ |
| 1 | Design system + assets | ✅ |
| 2 | ISO amd64 boot | ✅ |
| 3 | Daemons Rust + detect | ✅ |
| 4 | Barra/tray/relógio | ✅ |
| 5 | Flyouts | ✅ |
| 6 | Iniciar + busca | ✅ |
| 7 | Janelas/snap/overview | ✅ |
| 8 | Lume Files | ✅ |
| 9 | Settings p1 | ✅ |
| 10 | Settings p2 + Security | ✅ |
| 11 | Terminal + CLI | ✅ |
| 12 | Loja | ✅ |
| 13 | Essenciais + PWA + MIME | ✅ |
| 14 | OOBE/login/energia | ✅ |
| 15 | Instalador HD | ✅ |
| 16 | Pendrive persistente | ✅ |
| 17 | Lite i386 | ✅ |
| 18 | Core amd64 | ✅ |
| 19 | Camada Windows | ✅ |
| 20 | Jogos nuvem | ✅ |
| 21 | Shield hardening | ✅ |
| 22 | Modo Cofre | ✅ |
| 23 | Update A/B + GitHub | ✅ |
| 24 | i18n + a11y | ✅ |
| 25 | Passe performance | ✅ |
| 26 | Suíte testes VM | ✅ |
| 27 | Beta/release | ✅ |

*Todas as 28 fases fechadas com blockers 0.*

---

## 🤝 Como contribuir

O Lume OS é um monorepo desenvolvido em fases sequenciais. Se quiser contribuir:

1. **Faça um fork** do repositório
2. **Crie uma branch** a partir da fase atual
3. **Desenvolva** seguindo as especificações do PRD e VISION
4. **Teste** em VM QEMU (não use `dd`/`parted`/`mkfs` em discos reais)
5. **Abra um PR** descrevendo a fase e as mudanças

### Regras de ouro
- Não pular fases
- Gate de fim de fase: suíte de testes verde + blockers 0
- 3 falhas na mesma tarefa = bloqueada + alerta + seguir tarefas independentes
- Commits convencionais + tag `phase-N-done`
- Builds root só em container Podman
- Não assinar releases, não push externo, não guardar chaves
- Sessão limitada a 5 h (systemd timer)

---

## 📄 Licença

Código próprio: **MIT** (arquivo `LICENSE`).  
Componentes upstream mantêm suas licenças originais.  
Assets de marca: originais.  
**Proibido:** assets da Apple ou Microsoft (wallpapers, Edge, App Store do mockup = substituir).

---

## 📞 Contato e suporte

- **Issues:** Abra uma issue no GitHub para bugs ou sugestões
- **Mission Control:** Acompanhe o desenvolvimento em tempo real (painel em `http://localhost:7777` durante o desenvolvimento)
- **Documentação:** `docs/PRD.md`, `docs/VISION.md`, `docs/MISSION-CONTROL.md`, `docs/OPEN.md`

---

> **Lume OS** — Devolvendo vida a PCs fracos, com visual premium e segurança por isolamento.  
> *CalVer 2026.11 • Release 0.1 Beta • Monorepo*

---

*Documentação gerada a partir do monorepo Lume OS. Para a versão mais atualizada, consulte os arquivos em `docs/` e o roadmap ativo no repositório.*
