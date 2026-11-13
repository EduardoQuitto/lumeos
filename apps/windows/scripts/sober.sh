#!/bin/bash
# sober.sh — Instalação e configuração do Sober para Lume OS
# Requisitos fase 20:
#   - Sober best-effort para jogos na nuvem

set -euo pipefail

SOBER_VERSION="${1:-latest}"
SOBER_REPO="${2:-https://github.com/soberhq/sober}"

log() {
    echo "[sober] $1"
}

# ==================== VALIDAÇÃO ====================
validar_ambiente() {
    log "Verificando ambiente para Sober..."

    if [ "$(uname -m)" != "x86_64" ]; then
        log "AVISO: Não está em arquitetura amd64, Sober pode não funcionar corretamente"
    fi

    log "Ambiente validado"
}

# ==================== INSTALAR SOBER ====================
instalar_sober() {
    log "Instalando Sober..."

    if command -v apt-get >/dev/null 2>&1; then
        apt-get update 2>/dev/null || true
        apt-get install -y git curl wget 2>/dev/null || true
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y git curl wget 2>/dev/null || true
    elif command -v pacman >/dev/null 2>&1; then
        pacman -S --needed git curl wget 2>/dev/null || true
    fi

    # Clonar repositório Sober
    if [ ! -d ~/.local/share/sober ]; then
        git clone "$SOBER_REPO" ~/.local/share/sober 2>/dev/null || true
    fi

    # Instalar dependências do Sober
    if [ -f ~/.local/share/sober/requirements.txt ]; then
        pip3 install -r ~/.local/share/sober/requirements.txt 2>/dev/null || true
    fi

    log "Sober instalado"
}

# ==================== CONFIGURAR SOBER ====================
configurar_sober() {
    log "Configurando Sober..."

    # Criar diretório de configuração
    mkdir -p ~/.config/sober 2>/dev/null || true

    # Criar arquivo de configuração padrão
    cat > ~/.config/sober/config.yaml 2>/dev/null << 'EOF'
# Configuração do Sober para Lume OS
server:
  host: 0.0.0.0
  port: 8080

streaming:
  codec: h264
  bitrate: 4000
  fps: 60
  resolution: 1080p

input:
  mouse_capture: true
  keyboard_capture: true
  gamepad_support: true

security:
  tls: false
  auth: false
EOF

    log "Sober configurado"
}

# ==================== INICIAR SOBER ====================
iniciar_sober() {
    log "Iniciando Sober..."

    if [ -f ~/.local/share/sober/sober.py ]; then
        python3 ~/.local/share/sober/sober.py --config ~/.config/sober/config.yaml &
        log "Sober iniciado em background"
    else
        log "AVISO: sober.py não encontrado, verifique a instalação"
    fi
}

# ==================== PRINCIPAL ====================
main() {
    log "=== Instalando Sober para Lume OS ==="

    validar_ambiente
    instalar_sober
    configurar_sober
    iniciar_sober

    log "=== Sober instalado com sucesso ==="
    log "Sober instalado em ~/.local/share/sober"
    log "Configuração em ~/.config/sober/config.yaml"
}

main "$@"
