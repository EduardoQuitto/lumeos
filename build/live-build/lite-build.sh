#!/bin/bash
# build/live-build/lite-build.sh - Build ISO Lite i386 para Lume OS
# Fase 28 - Bloco A
set -euo pipefail

ARCH="i386"
ISO_DIR="out"
ISO_FILE="lume-i386.iso"
ISO_PATH="${ISO_DIR}/${ISO_FILE}"
WORK_DIR="build/live-build/lite-work"

log() {
    echo "[lite-build] $1"
}

log "=== Iniciando build ISO i386 Lite ==="

mkdir -p "$WORK_DIR" "$ISO_DIR"

if [ ! -f "build/live-build/build.sh" ]; then
    log "ERRO: build/live-build/build.sh não encontrado"
    exit 1
fi

bash build/live-build/build.sh i386

if [ $? -eq 0 ]; then
    log "ISO i386 Lite construída com sucesso"
else
    log "ERRO: Falha ao construir ISO Lite i386"
    exit 1
fi
