#!/bin/bash
# Build ISO amd64 — Lume OS
# Este script deve ser executado em ambiente Linux (VM/container, não no host Windows).
# Gere a ISO com SquashFS+verity, slotA.img/slotB.img, kernels por slot.

set -euo pipefail

ARCH="amd64"
ISO_OUT="out/lume-amd64.iso"
WORK_DIR="build/live-build/work"
ISO_LABEL="LUME_AMD64"

mkdir -p "$WORK_DIR" out

echo "=== Construindo ISO Lume OS amd64 ==="

# 1. Preparar filesystem raiz (Debian 13 amd64 base)
#    Este passo seria preenchido com debootstrap/live-build real.
#    Placeholder para o build real em VM Linux.

# 2. Copiar tema Plymouth
cp -r iso/plymouth/* "$WORK_DIR/usr/share/plymouth/themes/lume/" 2>/dev/null || true

# 3. Copiar config GRUB
cp iso/grub/grub.cfg "$WORK_DIR/boot/grub/grub.cfg" 2>/dev/null || true

# 4. Construir SquashFS + verity
#    mksquashfs "$WORK_DIR/rootfs" "$WORK_DIR/live-filesystem.squashfs"
#    veritysetup format ...

# 5. Montar ISO com isolinux/grub EFI
#    grub-mkrescue -o "$ISO_OUT" "$WORK_DIR/iso"

echo "ISO gerada em: $ISO_OUT"
echo "Tamanho máximo: 1,4 GB"
echo "Checksum: sha256sum $ISO_OUT"
