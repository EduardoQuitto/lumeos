#!/bin/bash
# build/live-build/core-build.sh - Build ISO amd64 Core para Lume OS
# Baseado em build.sh com configurações específicas para edição Core

set -euo pipefail

ARCH="amd64"
ISO_DIR="out"
ISO_FILE="lume-amd64.iso"
ISO_PATH="${ISO_DIR}/${ISO_FILE}"

log() {
    echo "[core-build] $1"
}

log "=== Iniciando build ISO amd64 Core ==="

# Verificar se o build.sh existe
if [ ! -f "build/live-build/build.sh" ]; then
    log "ERRO: build/live-build/build.sh não encontrado"
    exit 1
fi

# Executar build principal para amd64
bash build/live-build/build.sh amd64

if [ $? -eq 0 ]; then
    log "ISO amd64 Core construída com sucesso"
else
    log "ERRO: Falha ao construir ISO amd64 Core"
    exit 1
fi
