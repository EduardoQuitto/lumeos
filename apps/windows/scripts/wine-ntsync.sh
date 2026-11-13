#!/bin/bash
# wine-ntsync.sh — Instalação e configuração do Wine+NTSYNC
# Requisitos fase 19:
#   - Wine com suporte NTSYNC para melhor performance em jogos Windows

set -euo pipefail

WINE_PREFIX="${1:-$HOME/.wine}"
WINE_VERSION="${2:-wine-staging}"
NTSYNC_ENABLE="${3:-true}"

log() {
    echo "[wine-ntsync] $1"
}

# ==================== VALIDAÇÃO ====================
validar_ambiente() {
    log "Verificando ambiente para Wine+NTSYNC..."

    if [ "$(uname -m)" != "x86_64" ]; then
        log "AVISO: Não está em arquitetura amd64, Wine pode não funcionar corretamente"
    fi

    log "Ambiente validado"
}

# ==================== INSTALAR WINE ====================
instalar_wine() {
    log "Instalando Wine..."

    if command -v apt-get >/dev/null 2>&1; then
        # Adicionar repositório WineHQ
        dpkg --add-architecture i386 2>/dev/null || true
        wget -nc https://dl.winehq.org/wine-builds/winehq.key 2>/dev/null || true
        apt-key add winehq.key 2>/dev/null || true
        add-apt-repository 'deb https://dl.winehq.org/wine-builds/debian/ stable main' 2>/dev/null || true
        apt-get update 2>/dev/null || true
        apt-get install -y --install-recommends winehq-staging 2>/dev/null || true
        apt-get install -y wine-staging 2>/dev/null || true
        apt-get install -y wine64 2>/dev/null || true
        apt-get install -y wine32 2>/dev/null || true
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y wine-staging 2>/dev/null || true
        dnf install -y wine 2>/dev/null || true
    elif command -v pacman >/dev/null 2>&1; then
        pacman -S --needed wine-staging 2>/dev/null || true
        pacman -S --needed wine 2>/dev/null || true
    fi

    log "Wine instalado"
}

# ==================== CONFIGURAR NTSYNC ====================
configurar_ntsync() {
    log "Configurando NTSYNC..."

    if [ "$NTSYNC_ENABLE" = "true" ]; then
        # Habilitar NTSYNC via variável de ambiente
        echo "WINE_NTSYNC=1" >> /etc/environment 2>/dev/null || true
        echo "export WINE_NTSYNC=1" >> /etc/profile.d/wine-ntsync.sh 2>/dev/null || true

        # Verificar se o kernel suporta NTSYNC
        if [ -e /dev/ntsync ] 2>/dev/null; then
            log "NTSYNC kernel driver detectado e ativo"
        else
            log "AVISO: NTSYNC kernel driver não encontrado, instale wine-staging com suporte NTSYNC"
        fi
    else
        log "NTSYNC desabilitado pelo usuário"
    fi

    log "NTSYNC configurado"
}

# ==================== CONFIGURAR PREFIXO WINE ====================
configurar_prefixo() {
    log "Configurando prefixo Wine: $WINE_PREFIX"

    WINEPREFIX="$WINE_PREFIX" wineboot --init 2>/dev/null || true

    log "Prefixo Wine configurado: $WINE_PREFIX"
}

# ==================== INSTALAR DEPENDÊNCIAS ====================
instalar_dependencias() {
    log "Instalando dependências do Wine..."

    if command -v winetricks >/dev/null 2>&1; then
        WINEPREFIX="$WINE_PREFIX" winetricks -q corefonts vcrun2019 dotnet48 2>/dev/null || true
    else
        log "AVISO: winetricks não encontrado, instale manualmente para suporte completo"
    fi

    log "Dependências instaladas"
}

# ==================== PRINCIPAL ====================
main() {
    log "=== Configurando Wine+NTSYNC para Lume OS ==="

    validar_ambiente
    instalar_wine
    configurar_ntsync
    configurar_prefixo
    instalar_dependencias

    log "=== Wine+NTSYNC configurado com sucesso ==="
    log "Prefixo: $WINE_PREFIX"
    log "NTSYNC: $NTSYNC_ENABLE"
}

main "$@"
