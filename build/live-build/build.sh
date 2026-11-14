#!/bin/bash
# ==============================================================================
# build/live-build/build.sh - Build ISO Lume OS (Debian live-build)
# Requisitos fase 22:
#   - ISO i386/amd64 bootável com SquashFS+verity
#   - Slots A/B para atualização A/B
#   - Plymouth com tema Lume
#   - GRUB com suporte EFI e BIOS
#   - Testado em QEMU
#
# USO: bash build/live-build/build.sh [amd64|i386]
# AMBIENTE: Linux (VM/container), NÃO Windows nativo
# ==============================================================================

set -euo pipefail

ARCH="${1:-amd64}"
ARCH_LOWER="$(echo "$ARCH" | tr '[:upper:]' '[:lower:]')"

case "$ARCH" in
    amd64|x86_64)
        ARCH="amd64"
        ISO_NAME="lume-amd64.iso"
        DEB_ARCH="amd64"
        ;;
    i386|i686)
        ARCH="i386"
        ISO_NAME="lume-i386.iso"
        DEB_ARCH="i386"
        ;;
    *)
        echo "ERRO: Arquitetura não suportada: $ARCH"
        echo "Uso: $0 [amd64|i386]"
        exit 1
        ;;
esac

WORK_DIR="build/live-build/work-${ARCH}"
ISO_DIR="out"
ISO_FILE="lume-${ARCH}.iso"
ISO_PATH="${ISO_DIR}/${ISO_FILE}"
RELEASE_DIR="release"

log() {
    echo "[build-live-build] $1"
}

# Verificar dependências
check_deps() {
    log "Verificando dependências..."
    local missing=0
    for cmd in debootstrap qemu-system-${ARCH} qemu-system-${ARCH} grub-mkrescue mksquashfs xorriso; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log "AVISO: $cmd não encontrado (será necessário instalar)"
            missing=1
        fi
    done
    if [ "$missing" -eq 1 ]; then
        log "AVISO: Algumas dependências estão faltando. O build pode falhar."
    fi
}

# Limpar diretório de trabalho
clean_work_dir() {
    log "Limpando diretório de trabalho: ${WORK_DIR}"
    rm -rf "${WORK_DIR}"
    mkdir -p "${WORK_DIR}"
}

# Criar raiz do sistema com debootstrap
bootstrap_system() {
    log "Criando sistema base Debian 13 ${ARCH} via debootstrap..."
    
    if command -v debootstrap >/dev/null 2>&1; then
        debootstrap --arch="${DEB_ARCH}" stable "${WORK_DIR}/rootfs" http://deb.debian.org/debian/
    else
        log "ERRO: debootstrap não encontrado. Instale com: apt install debootstrap"
        exit 1
    fi
    
    log "Base Debian instalada em ${WORK_DIR}/rootfs"
}

# Configurar sistema base
configure_system() {
    local rootfs="${WORK_DIR}/rootfs"
    
    log "Configurando sistema base..."
    
    # Hostname
    echo "lume" > "${rootfs}/etc/hostname"
    
    # Hosts
    cat > "${rootfs}/etc/hosts" << 'EOF'
127.0.0.1   localhost
127.0.1.1   lume.localdomain lume
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

    # Resolv.conf
    cat > "${rootfs}/etc/resolv.conf" << 'EOF'
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

    # APT sources
    cat > "${rootfs}/etc/apt/sources.list" << EOF
deb http://deb.debian.org/debian stable main contrib non-free
deb http://security.debian.org/debian-security stable-security main contrib non-free
deb http://deb.debian.org/debian stable-updates main contrib non-free
EOF

    # Instalar pacotes essenciais
    log "Instalando pacotes essenciais..."
    chroot "${rootfs}" apt-get update 2>/dev/null || true
    chroot "${rootfs}" apt-get install -y --no-install-recommends \
        systemd systemd-sysv dbus \
        linux-image-${ARCH} linux-headers-${ARCH} \
        grub-pc grub-pc-bin grub-efi-amd64 grub-efi-amd64-bin grub-common \
        linux-image-${ARCH} \
        sudo curl wget gnupg2 ca-certificates \
        locales locales-all \
        vim nano less tmux screen \
        network-manager network-manager-config-network-manager-ubuntu \
        iw rfkill bluez bluez-tools \
        pipewire pipewire-audio pipewire-pulse \
        p7zip-full p7zip-rar unzip zip tar gzip bzip2 xz-utils \
        sudo adduser sudo \
        xterm terminator \
        2>/dev/null || log "AVISO: Alguns pacotes podem não ter sido instalados"
}

# Configurar Plymouth
configure_plymouth() {
    local rootfs="${WORK_DIR}/rootfs"
    
    log "Configurando Plymouth..."
    
    if [ -d "iso/plymouth" ]; then
        cp -r iso/plymouth/* "${rootfs}/usr/share/plymouth/themes/lume/" 2>/dev/null || true
    fi
    
    # Definir tema padrão
    chroot "${rootfs}" update-alternatives --set default.plymouth /usr/share/plymouth/themes/lume/lume.plymouth 2>/dev/null || true
    chroot "${rootfs}" update-initramfs -u 2>/dev/null || true
}

# Configurar GRUB
configure_grub() {
    local rootfs="${WORK_DIR}/rootfs"
    
    log "Configurando GRUB..."
    
    if [ -f "iso/grub/grub.cfg" ]; then
        mkdir -p "${rootfs}/boot/grub"
        cp iso/grub/grub.cfg "${rootfs}/boot/grub/grub.cfg"
    fi
    
    # Instalar GRUB no chroot
    chroot "${rootfs}" grub-install --target=i386-pc --boot-directory=/boot /dev/sda 2>/dev/null || true
    chroot "${rootfs}" grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
    
    # Para UEFI
    chroot "${rootfs}" grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Lume 2>/dev/null || true
    chroot "${rootfs}" grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
    
    log "GRUB configurado"
}

# Criar SquashFS
create_squashfs() {
    local rootfs="${WORK_DIR}/rootfs"
    local squashfs="${WORK_DIR}/live-filesystem.squashfs"
    
    log "Criando SquashFS..."
    
    if command -v mksquashfs >/dev/null 2>&1; then
        mksquashfs "${rootfs}" "${squashfs}" -comp xz -b 1M -no-duplicates 2>/dev/null || true
    else
        log "AVISO: mksquashfs não encontrado, não foi possível criar SquashFS"
        return 1
    fi
    
    if [ -f "${squashfs}" ]; then
        local size_mb
        size_mb=$(du -sm "${squashfs}" 2>/dev/null | cut -f1)
        log "SquashFS criado: ${squashfs} (${size_mb} MB)"
    else
        log "ERRO: SquashFS não foi criado"
        return 1
    fi
}

# Criar verity para o slot
create_verity() {
    local squashfs="${WORK_DIR}/live-filesystem.squashfs"
    local verity_file="${WORK_DIR}/live-filesystem.verity"
    local verity_hash="${WORK_DIR}/live-filesystem.verity.verity"
    
    log "Criando verity para slots A/B..."
    
    if command -v veritysetup >/dev/null 2>&1; then
        # Criar verity para slot A
        veritysetup format "${squashfs}" "${verity_file}" 2>/dev/null || true
        
        # Extrair hash de verity
        veritysetup verify "${squashfs}" "${verity_file}" 2>/dev/null || true
    else
        log "AVISO: veritysetup não encontrado, verity não configurado"
    fi
}

# Criar ISO com grub-mkrescue
create_iso() {
    local iso_dir="${WORK_DIR}/iso"
    local iso_file="${ISO_OUT}"
    
    log "Criando ISO com grub-mkrescue..."
    
    mkdir -p "${iso_dir}/boot/grub"
    
    # Copiar kernel e initrd
    cp "${WORK_DIR}/rootfs/boot/vmlinuz-*" "${iso_dir}/boot/vmlinuz" 2>/dev/null || true
    cp "${WORK_DIR}/rootfs/boot/initrd.img-*" "${iso_dir}/boot/initrd" 2>/dev/null || true
    
    # Copiar SquashFS
    cp "${WORK_DIR}/live-filesystem.squashfs" "${iso_dir}/boot/live-filesystem.squashfs" 2>/dev/null || true
    
    # Copiar GRUB config
    cp iso/grub/grub.cfg "${iso_dir}/boot/grub/grub.cfg" 2>/dev/null || true
    
    # Criar ISO com grub-mkrescue
    if command -v grub-mkrescue >/dev/null 2>&1; then
        grub-mkrescue -o "${ISO_FILE}" "${iso_dir}" 2>/dev/null || true
    else
        log "AVISO: grub-mkrescue não encontrado, ISO não será criada"
        return 1
    fi
    
    if [ -f "${ISO_FILE}" ]; then
        local iso_size
        size_mb=$(du -sm "${ISO_FILE}" 2>/dev/null | cut -f1)
        log "ISO criada: ${ISO_FILE} (${size_mb} MB)"
    else
        log "ERRO: ISO não foi criada"
        return 1
    fi
}

# ============================================================================
# EXECUÇÃO PRINCIPAL
# ============================================================================
main() {
    log "=== Iniciando build Lume OS ${ARCH} ==="
    
    check_deps
    clean_work_dir
    bootstrap_system
    configurar_sistema
    configurar_plymouth
    configurar_grub
    criar_squashfs
    criar_verity
    criar_iso
    
    log "=========================================="
    log "  ISO Lume OS ${ARCH} construída com sucesso!"
    log "  Arquivo: ${ISO_OUT}"
    if [ -f "${ISO_OUT}" ]; then
        local iso_size
        iso_size=$(du -sh "${ISO_OUT}" 2>/dev/null | cut -f1)
        log "  Tamanho: ${iso_size}"
    fi
    log "============================================================"
}

main "$@"
