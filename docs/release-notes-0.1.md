# Lume OS - Release 0.1 (Beta)

## Visão Geral

Lume OS CalVer 2026.11 - Release 0.1 (Beta)

Este é o primeiro release beta do Lume OS, um SO Linux leve, premium e imutável desenvolvido para devolver vida a computadores fracos.

## Novidades nesta Release

### Sistema Base
- Base imutável SquashFS+verity com update A/B
- Persistência LUKS2 em pendrive
- Base Debian 12 (i386) / Debian 13 (amd64)
- systemd, PipeWire, NetworkManager, bluez

### Shell e Interface
- Barra pílula com ícones, tray e relógio
- Menu Iniciar 640×560 com busca universal
- Flyouts: redes, quick settings, volume, calendário
- Janelas CSD QML com raio 12 px e sombra 2 camadas
- Alt+Tab, Super+Tab (overview), snap de janelas

### Aplicativos
- Lume Files (gerenciador de arquivos)
- Lume Settings (configurações do sistema)
- Lume Terminal (foot/xfce4-terminal)
- Lume Store (loja de aplicativos)
- Firefox ESR, VLC, p7zip
- Pacote Essenciais (OOBE 1 clique)

### Segurança (Lume Shield)
- LUKS2 criptografia em repouso
- Verify (verificação de integridade slots)
- AppArmor enforce
- seccomp nos daemons
- nftables default-deny entrada
- Modo Cofre (microVM descartável)

### Edições
- **Lite (i386):** P4, 1-2 GB RAM, GPU 2004-2009, idle ≤250 MB
- **Core (amd64):** <4 GB RAM, idle ≤350 MB
- **Prime (amd64):** ≥4 GB RAM, idle ≤450 MB

## Instalação

1. Baixe a ISO da edição desejada
2. Grave em pendrive com Rufus, Etcher ou Ventoy
3. Inicie pelo pendrive
4. Siga o OOBE (Primeira Execução)
5. Aproveite o Lume OS!

## Problemas Conhecidos

- Alguns aplicativos Windows podem não funcionar perfeitamente em garrafas bwrap
- Blur de vidro pode ser lento em VMs sem aceleração 3D
- Atualizações A/B requerem reinicialização

## Suporte

- [Issues](https://github.com/EduardoQuitto/lumeos/issues)
- [Discussões](https://github.com/EduardoQuitto/lumeos/discussions)

---

*Lume OS - CalVer 2026.11 • Release 0.1 Beta*
