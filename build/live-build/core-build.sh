#!/bin/bash
# build/live-build/core-build.sh - Build ISO Core amd64 para Lume OS
# Fase 28 - Bloco A
set -euo pipefail

ARCH="amd64"
ISO_DIR="out"
ISO_FILE="lume-core-amd64.iso"
ISO_PATH="${ISO_DIR}/${ISO_FILE}"
WORK_DIR="build/live-build/core-work"

log() {
    echo "[core-build] $1"
}

log "=== Iniciando build ISO Core amd64 ==="

mkdir -p "$WORK_DIR" "$ISO_DIR"

# Copiar rootfs base do build principal
if [ -d "build/live-build/work/rootfs" ]; then
    cp -r "build/live-build/work/rootfs" "$WORK_DIR/rootfs"
    log "Base do sistema copiada do build amd64"
else
    log "AVISO: base do sistema não encontrada. Execute build.sh primeiro."
    exit 1
fi

# Copiar configurações específicas do Core
mkdir -p "$WORK_DIR/boot/grub"
cp iso/grub/grub.cfg "${WORK_DIR}/boot/grub/grub.cfg" 2>/dev/null || true

# Criar ISO
if command -v grub-mkrescue >/dev/null 2>&1; then
    grub-mkrescue -o "$ISO_PATH" "$WORK_DIR/iso" 2>/dev/null || true
else
    log_err "grub-mkrescue não encontrado"
    exit 1
fi

if [ -f "$ISO_PATH" ]; then
    iso_size=$(du -sh "$ISO_PATH" 2>/dev/null | cut -f1)
    log "ISO Core amd64 criada: ${ISO_PATH} (${iso_size})"
else
    log_err "ISO não foi criada"
    exit 1
fi
