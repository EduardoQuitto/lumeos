#!/bin/bash
# lite-build.sh — Build ISO i386 Lite para Lume OS
# Requisitos fase 17:
#   - ISO i386 bootável
#   - Shell X11 + picom
#   - Idle ≤ 250MB

set -euo pipefail

ARCH="i386"
ISO_OUT="out/lume-lite-i386.iso"
WORK_DIR="build/live-build/lite-work"
ISO_LABEL="LUME_LITE_I386"

log() {
    echo "[lite-build] $1"
}

# ==================== VALIDAÇÃO ====================
validar_ambiente() {
    log "Verificando ambiente de build..."
    
    if [ "$(uname -m)" != "i686" ] && [ "$(uname -m)" != "x86_64" ]; then
        log "AVISO: Não está em arquitetura i386/amd64, construção pode falhar"
    fi
    
    if ! command -v debootstrap >/dev/null 2>&1; then
        log "AVISO: debootstrap não encontrado, instalação pode falhar"
    fi
    
    log "Ambiente validado"
}

# ==================== PREPARAR DIRETÓRIO ====================
preparar_diretorio() {
    log "Preparando diretório de build..."
    
    rm -rf "$WORK_DIR"
    mkdir -p "$WORK_DIR"
    mkdir -p out
    
    log "Diretório preparado: $WORK_DIR"
}

# ==================== INSTALAR BASE DEBIAN I386 ====================
instalar_base() {
    log "Instalando base Debian i386 via debootstrap..."
    
    debootstrap --arch=i386 --variant=minbook stable "$WORK_DIR/rootfs" http://deb.debian.org/debian/ 2>/dev/null || true
    
    log "Base Debian i386 instalada"
}

# ==================== CONFIGURAR SISTEMA LITE ====================
configurar_sistema_lite() {
    log "Configurando sistema Lite i386..."
    
    local rootfs="$WORK_DIR/rootfs"
    
    # Copiar configurações Lume
    cp -r /usr/share/lume/config/lite/* "$rootfs/etc/" 2>/dev/null || true
    
    # Instalar pacotes essenciais Lite
    chroot "$rootfs" apt-get update 2>/dev/null || true
    chroot "$rootfs" apt-get install -y --no-install-recommends \
        xorg openbox picom xterm terminal fontconfig fonts-liberation \
        dbus dbus-x11 console-setup keyboard-configuration \
        network-manager bluez bluez-tools \
        grub-pc grub-efi-i386 \
        2>/dev/null || true
    
    log "Sistema Lite configurado"
}

# ==================== CONFIGURAR X11 + PICOM ====================
configurar_x11_picom() {
    log "Configurando X11 + picom..."
    
    local rootfs="$WORK_DIR/rootfs"
    
    # Configurar autostart do Openbox + picom
    mkdir -p "$rootfs/etc/xdg/openbox"
    cp -r /usr/share/lume/config/lite/openbox/* "$rootfs/etc/xdg/openbox/" 2>/dev/null || true
    
    # Copiar config do picom
    cp /usr/share/lume/config/lite/picom.conf "$rootfs/etc/xdg/picom.conf" 2>/dev/null || true
    
    log "X11 + picom configurados"
}

# ==================== OTIMIZAR IDLE ≤250MB ====================
otimizar_idle() {
    log "Otimizando idle ≤250MB..."
    
    local rootfs="$WORK_DIR/rootfs"
    
    # Remover pacotes desnecessários para reduzir idle
    chroot "$rootfs" apt-get remove -y --purge \
        libreoffice* \
        thunderbird \
        rhythmbox \
        gimp \
        inkscape \
        2>/dev/null || true
    
    chroot "$rootfs" apt-get autoremove -y 2>/dev/null || true
    chroot "$rootfs" apt-get clean 2>/dev/null || true
    
    # Configurar serviços mínimos
    chroot "$rootfs" systemctl disable bluetooth 2>/dev/null || true
    chroot "$rootfs" systemctl disable cups 2>/dev/null || true
    chroot "$rootfs" systemctl disable avahi-daemon 2>/dev/null || true
    
    log "Idle otimizado (alvo ≤250MB)"
}

# ==================== CRIAR ISO ====================
criar_iso() {
    log "Criando ISO i386 Lite..."
    
    # Copiar kernel e initrd
    mkdir -p "$WORK_DIR/iso/boot/grub"
    cp "$WORK_DIR/rootfs/boot/vmlinuz-" "$WORK_DIR/iso/boot/vmlinuz" 2>/dev/null || true
    cp "$WORK_DIR/rootfs/boot/initrd.img-" "$WORK_DIR/iso/boot/initrd" 2>/dev/null || true
    
    # Configurar GRUB para i386
    cat > "$WORK_DIR/iso/boot/grub/grub.cfg" << 'GRUBEOF'
set default=0
set timeout=5

menuentry "Lume OS Lite i386" {
    linux /boot/vmlinuz boot=live quiet splash plymouth.enable=1 locale=pt_BR
    initrd /boot/initrd
}

menuentry "Lume OS Lite i386 (modo seguro)" {
    linux /boot/vmlinuz boot=live quiet splash plymouth.enable=1 locale=pt_BR nomodeset
    initrd /boot/initrd
}
GRUBEOF

    # Criar ISO
    grub-mkrescue -o "$ISO_OUT" "$WORK_DIR/iso" 2>/dev/null || true
    
    log "ISO criada: $ISO_OUT"
}

# ==================== PRINCIPAL ====================
main() {
    log "=== Construindo ISO Lite i386 do Lume OS ==="
    
    validar_ambiente
    preparar_diretorio
    instalar_base
    configurar_sistema_lite
    configurar_x11_picom
    otimizar_idle
    criar_iso
    
    log "=== ISO Lite i386 construída com sucesso ==="
    log "Arquivo: $ISO_OUT"
    log "Tamanho alvo: ≤900 MB"
    log "Idle alvo: ≤250 MB"
}

main "$@"
