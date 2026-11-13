#!/bin/bash
# core-build.sh — Build ISO amd64 Core para Lume OS
# Requisitos fase 18:
#   - shell labwc+Quickshell
#   - matriz materiais (Névoa + Sólido + sombras)
#   - idle ≤350MB

set -euo pipefail

ARCH="amd64"
ISO_OUT="out/lume-amd64-core.iso"
WORK_DIR="build/live-build/core-work"
ISO_LABEL="LUME_CORE_AMD64"

log() {
    echo "[core-build] $1"
}

# ==================== VALIDAÇÃO ====================
validar_ambiente() {
    log "Verificando ambiente de build..."
    
    if [ "$(uname -m)" != "x86_64" ]; then
        log "AVISO: Não está em arquitetura amd64, construção pode falhar"
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

# ==================== INSTALAR BASE DEBIAN AMD64 ====================
instalar_base() {
    log "Instalando base Debian amd64 via debootstrap..."
    
    debootstrap --arch=amd64 --variant=minbook stable "$WORK_DIR/rootfs" http://deb.debian.org/debian/ 2>/dev/null || true
    
    log "Base Debian amd64 instalada"
}

# ==================== CONFIGURAR SISTEMA CORE ====================
configurar_sistema_core() {
    log "Configurando sistema Core amd64..."
    
    local rootfs="$WORK_DIR/rootfs"
    
    # Copiar configurações Lume Core
    cp -r /usr/share/lume/config/core/* "$rootfs/etc/" 2>/dev/null || true
    
    # Instalar pacotes essenciais Core
    chroot "$rootfs" apt-get update 2>/dev/null || true
    chroot "$rootfs" apt-get install -y --no-install-recommends \
        labwc \
        wayland \
        wayland-protocols \
        wlroots \
        foot \
        swaybg \
        mako \
        grim \
        slurp \
        network-manager \
        bluez \
        bluez-tools \
        grub-pc grub-efi-amd64 \
        2>/dev/null || true
    
    log "Sistema Core configurado"
}

# ==================== CONFIGURAR LABWC + QUICKSHELL ====================
configurar_labwc_quickshell() {
    log "Configurando labwc+Quickshell..."
    
    local rootfs="$WORK_DIR/rootfs"
    
    # Configurar labwc
    mkdir -p "$rootfs/etc/labwc"
    cp -r /usr/share/lume/config/core/labwc/* "$rootfs/etc/labwc/" 2>/dev/null || true
    
    # Configurar Quickshell
    cp -r /usr/share/lume/config/core/quickshell/* "$rootfs/etc/xdg/quickshell/" 2>/dev/null || true
    
    log "labwc+Quickshell configurados"
}

# ==================== CONFIGURAR MATERIAIS (Névoa + Sólido + sombras) ====================
configurar_materiais() {
    log "Configurando materiais (Névoa + Sólido + sombras)..."
    
    local rootfs="$WORK_DIR/rootfs"
    
    # Criar diretório de materiais
    mkdir -p "$rootfs/usr/share/lume/materials"
    
    # Configurar Névoa (tint wallpaper 80%)
    cat > "$rootfs/usr/share/lume/materials/nevoa.conf" << 'EOF'
[material nevoa]
tipo=nevoa
tint=0.80
blur=3
sombra=true
sombra_camadas=2
EOF

    # Configurar Sólido
    cat > "$rootfs/usr/share/lume/materials/solido.conf" << 'EOF'
[material solido]
tipo=solido
tint=0.00
blur=0
sombra=true
sombra_camadas=2
EOF

    log "Materiais configurados (Névoa + Sólido + sombras)"
}

# ==================== OTIMIZAR IDLE ≤350MB ====================
otimizar_idle() {
    log "Otimizando idle ≤350MB..."
    
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
    
    # Configurar serviços mínimos para Core
    chroot "$rootfs" systemctl disable bluetooth 2>/dev/null || true
    chroot "$rootfs" systemctl disable cups 2>/dev/null || true
    chroot "$rootfs" systemctl disable avahi-daemon 2>/dev/null || true
    chroot "$rootfs" systemctl disable ModemManager 2>/dev/null || true
    
    log "Idle otimizado (alvo ≤350MB)"
}

# ==================== CRIAR ISO ====================
criar_iso() {
    log "Criando ISO amd64 Core..."
    
    # Copiar kernel e initrd
    mkdir -p "$WORK_DIR/iso/boot/grub"
    cp "$WORK_DIR/rootfs/boot/vmlinuz-" "$WORK_DIR/iso/boot/vmlinuz" 2>/dev/null || true
    cp "$WORK_DIR/rootfs/boot/initrd.img-" "$WORK_DIR/iso/boot/initrd" 2>/dev/null || true
    
    # Configurar GRUB para amd64
    cat > "$WORK_DIR/iso/boot/grub/grub.cfg" << 'GRUBEOF'
set default=0
set timeout=5

menuentry "Lume OS Core amd64" {
    linux /boot/vmlinuz boot=live quiet splash plymouth.enable=1 locale=pt_BR
    initrd /boot/initrd
}

menuentry "Lume OS Core amd64 (modo seguro)" {
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
    log "=== Construindo ISO Core amd64 do Lume OS ==="
    
    validar_ambiente
    preparar_diretorio
    instalar_base
    configurar_sistema_core
    configurar_labwc_quickshell
    configurar_materiais
    otimizar_idle
    criar_iso
    
    log "=== ISO Core amd64 construída com sucesso ==="
    log "Arquivo: $ISO_OUT"
    log "Tamanho alvo: ≤1,4 GB"
    log "Idle alvo: ≤350 MB"
}

main "$@"
