#!/bin/bash
# build/live-build/lite-build.sh - Build ISO i386 Lite para Lume OS
# Fase 28 - Bloco A
set -euo pipefail

ARCH="i386"
ISO_DIR="out"
ISO_FILE="lume-i386.iso"

log() {
    echo "[lite-build] $1"
}

log "=== Iniciando build ISO i386 Lite ==="

# Verificar se o build.sh existe
if [ ! -f "build/live-build/build.sh" ]; then
    log "ERRO: build/live-build/build.sh não encontrado"
    exit 1
fi

# Executar build principal para i386
bash build/live-build/build.sh i386

if [ $? -eq 0 ]; then
    log "ISO i386 Lite construída com sucesso"
else
    log "ERRO: Falha ao construir ISO i386 Lite"
    exit 1
fi
