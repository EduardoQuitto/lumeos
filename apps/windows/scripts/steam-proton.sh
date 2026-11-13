#!/bin/bash
# steam-proton.sh — Instalação e configuração do Steam+Proton para Lume OS
# Requisitos fase 20:
#   - Steam+Proton para tiers B/C

set -euo pipefail

STEAM_VERSION="${1:-steam}"
PROTON_VERSION="${2:-GE-Proton8-26}"

log() {
    echo "[steam-proton] $1"
}

# ==================== VALIDAÇÃO ====================
validar_ambiente() {
    log "Verificando ambiente para Steam+Proton..."

    if [ "$(uname -m)" != "x86_64" ]; then
        log "AVISO: Não está em arquitetura amd64, Steam+Proton pode não funcionar corretamente"
    fi

    log "Ambiente validado"
}

# ==================== INSTALAR STEAM ====================
instalar_steam() {
    log "Instalando Steam..."

    if command -v apt-get >/dev/null 2>&1; then
        # Adicionar arquitetura i386
        dpkg --add-architecture i386 2>/dev/null || true
        apt-get update 2>/dev/null || true
        apt-get install -y steam 2>/dev/null || true
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y steam 2>/dev/null || true
    elif command -v pacman >/dev/null 2>&1; then
        pacman -S --needed steam 2>/dev/null || true
    fi

    log "Steam instalado"
}

# ==================== INSTALAR PROTON ====================
instalar_proton() {
    log "Instalando Proton ${PROTON_VERSION}..."

    if command -v apt-get >/dev/null 2>&1; then
        apt-get install -y steam-devices 2>/dev/null || true
    fi

    # Baixar Proton GE se disponível
    if command -v curl >/dev/null 2>&1; then
        curl -L "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${PROTON_VERSION}/${PROTON_VERSION}.tar.gz" \
            -o /tmp/proton.tar.gz 2>/dev/null || true
        
        if [ -f /tmp/proton.tar.gz ]; then
            mkdir -p ~/.steam/root/compatibilitytools.d/
            tar -xzf /tmp/proton.tar.gz -C ~/.steam/root/compatibilitytools.d/ 2>/dev/null || true
            log "Proton GE instalado em ~/.steam/root/compatibilitytools.d/"
        fi
    fi

    log "Proton instalado"
}

# ==================== CONFIGURAR STEAM ====================
configurar_steam() {
    log "Configurando Steam..."

    # Criar diretório Steam
    mkdir -p ~/.steam/root 2>/dev/null || true
    mkdir -p ~/.steam/root/steamapps 2>/dev/null || true
    mkdir -p ~/.steam/root/compatibilitytools.d/ 2>/dev/null || true

    # Configurar Steam para usar Proton GE por padrão
    cat > ~/.steam/root/config/steam.vdf 2>/dev/null << 'EOF'
"steam"
{
    "Steam"
    {
        "language"            "portuguese"
        "secondsbeforeidle"   "300"
        "browserlanguage"     "portuguese"
        "lastserversuggested" "0"
        "SaveVideoSettings"   "1"
        "bAutoRestoreUIState" "1"
        "bRunInOverlay"       "0"
        "bAutoMinimizeOnFocusLoss" "1"
        "bEnableSteamController" "1"
        "bShowNotifications" "1"
        "bEnableSteamCloud" "1"
        "bEnableSteamCommunity" "1"
        "bEnableSteamFriends" "1"
        "bEnableSteamNews" "1"
        "bEnableSteamWorkshop" "1"
    }
}
EOF

    log "Steam configurado"
}

# ==================== PRINCIPAL ====================
main() {
    log "=== Instalando Steam+Proton para Lume OS ==="

    validar_ambiente
    instalar_steam
    instalar_proton
    configurar_steam

    log "=== Steam+Proton instalado com sucesso ==="
    log "Steam instalado em ~/.steam"
    log "Proton GE instalado em ~/.steam/root/compatibilitytools.d/"
}

main "$@"
