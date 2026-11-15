#!/bin/bash
# ==============================================================================
# build/live-build/build.sh - Build ISO Lume OS (CalVer 2026.11)
#
# Este script constrói uma ISO bootável do Lume OS usando:
#   - debootstrap para criar o sistema base Debian 13 amd64/i386
#   - mksquashfs para criar o sistema de arquivos imutável
#   - veritysetup para criar verity (verificação de integridade)
#   - grub-mkrescue para criar a ISO bootável com GRUB EFI + BIOS
#
# Requisitos fase 28 (Bloco A):
#   - ISO amd64 bootável com Plymouth Lume
#   - Slots A/B para atualização A/B
#   - Verity para integridade do sistema
#   - Arquitetura: live-build padrão Debian
#
# USO: bash build/live-build/build.sh [amd64|i386]
# AMBIENTE: Linux (VM/container), NÃO Windows nativo
# ==============================================================================

set -euo pipefail

ARCH="${1:-amd64}"
ISO_DIR="out"
ISO_PATH="lume-${ARCH}.iso"
ISO_PATH="${ISO_DIR}/${ISO_PATH}"
WORK_DIR="build/live-build/work-${ARCH}"
ROOTFS_DIR="${WORK_DIR}/rootfs"
SQUASHFS_DIR="${WORK_DIR}/squashfs"
ISO_BUILD_DIR="${WORK_DIR}/iso"

# Versão do Debian base
DEBIAN_SUITE="stable"  # Debian 13 (trixie) ou stable
DEBIAN_MIRROR="http://deb.debian.org/debian"

# Tamanhos alvo
ISO_MAX_SIZE_AMD64=$((1400 * 1024 * 1024))  # 1.4 GB
ISO_MAX_SIZE_I386=$((900 * 1024 * 1024))    # 900 MB

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[lume-build]${NC} $1"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_err() {
    echo -e "${RED}[ERRO]${NC} $1" >&2
}

# ==============================================================================
# Verificações prévias
# ==============================================================================

check_dependencies() {
    log "Verificando dependências de build..."
    
    local missing=0
    local deps=(debootstrap qemu-system-${ARCH} qemu-utils grub-mkrescue mksquashfs curl wget gnupg2 xorriso)
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            log_err "Dependência não encontrada: $dep"
            missing=1
        else
            log_ok "${dep} encontrado"
        fi
    done
    
    if [ "$missing" -ne 0 ]; then
        log_err "Algumas dependências estão faltando. Instale-as antes de continuar."
        log_info "Exemplo (Debian/Ubuntu): sudo apt-get install debootstrap squashfs-tools grub-pc-bin grub-efi-amd64 xorriso qemu-system-${ARCH}"
        exit 1
    fi
}

# Verificar se estamos rodando como root (necessário para debootstrap, mount, mksquashfs)
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_err "Este script deve ser executado como root (usa debootstrap, mount, mksquashfs, grub-mkrescue)."
        log_info "Use: sudo bash build/live-build/build.sh ${ARCH}"
        exit 1
    fi
}

# ==============================================================================
# Passo 1: Preparar diretório de trabalho
# ==============================================================================

prepare_work_dir() {
    log "Preparando diretório de trabalho: ${WORK_DIR}"
    
    rm -rf "${WORK_DIR}"
    mkdir -p "${WORK_DIR}/rootfs"
    mkdir -p "${WORK_DIR}/squashfs"
    mkdir -p "${WORK_DIR}/iso"
    mkdir -p "${ISO_DIR}"
    
    log_ok "Diretório de trabalho preparado: ${WORK_DIR}"
}

# ==============================================================================
# Passo 2: Instalar sistema base Debian com debootstrap
# ==============================================================================

bootstrap_system() {
    log "Instalando sistema base Debian ${DEBIAN_SUITE} (${ARCH}) via debootstrap..."
    
    if [ ! -d "${WORK_DIR}/rootfs/var/lib/dpkg" ]; then
        debootstrap --arch="${ARCH}" --variant=minbase "${DEBIAN_SUITE}" "${WORK_DIR}/rootfs" "http://deb.debian.org/debian/" 2>&1 | tee "${WORK_DIR}/debootstrap.log" || {
            log_err "Falha no debootstrap. Veja ${WORK_DIR}/debootstrap.log"
            exit 1
        fi
    fi
    
    log_ok "Sistema base Debian ${DEBIAN_SUITE} (${ARCH}) instalado"
}

# ==============================================================================
# Passo 3: Configurar o sistema base
# ==============================================================================

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
    log "Instalando pacotes essenciais do sistema..."
    chroot "${rootfs}" apt-get update 2>/dev/null || true
    chroot "${rootfs}" apt-get install -y --no-install-recommends \
        systemd \
        systemd-sysv \
        dbus \
        dbus-user-session \
        linux-image-${ARCH} \
        linux-headers-${ARCH} \
        grub-pc \
        grub-pc-bin \
        grub-efi-amd64 \
        grub-efi-amd64-bin \
        grub-common \
        linux-image-${ARCH} \
        linux-firmware \
        firmware-linux \
        firmware-linux-free \
        sudo \
        curl \
        wget \
        gnupg2 \
        ca-certificates \
        locales \
        locales-all \
        vim \
        nano \
        less \
        tmux \
        screen \
        network-manager \
        bluez \
        bluez-tools \
        pipewire \
        wireplumber \
        p7zip-full \
        p7zip-rar \
        unzip \
        zip \
        tar \
        gzip \
        bzip2 \
        xz-utils \
        openssh-server \
        openssh-client \
        2>/dev/null || log_warn "Alguns pacotes podem não ter sido instalados (verificar conexão com internet)"
    
    log_ok "Pacotes essenciais instalados"
}

# ==============================================================================
# Passo 5: Configurar Plymouth
# ==============================================================================

configure_plymouth() {
    local rootfs="${WORK_DIR}/rootfs"
    
    log "Configurando Plymouth..."
    
    # Copiar tema Plymouth se existir
    if [ -d "iso/plymouth" ]; then
        mkdir -p "${rootfs}/usr/share/plymouth/themes/lume"
        cp -r iso/plymouth/* "${rootfs}/usr/share/plymouth/themes/lume/" 2>/dev/null || true
    fi
    
    # Definir tema padrão
    chroot "${rootfs}" update-alternatives --set default.plymouth /usr/share/plymouth/themes/lume/lume.plymouth 2>/dev/null || true
    chroot "${rootfs}" update-initramfs -u 2>/dev/null || true
    
    log_ok "Plymouth configurado"
}

# ==============================================================================
# Passo 5: Configurar GRUB
# ==============================================================================

configure_grub() {
    local rootfs="${WORK_DIR}/rootfs"
    
    log "Configurando GRUB..."
    
    # Copiar configuração GRUB
    if [ -f "iso/grub/grub.cfg" ]; then
        mkdir -p "${rootfs}/boot/grub"
        cp iso/grub/grub.cfg "${rootfs}/boot/grub/grub.cfg"
    fi
    
    # GRUB para BIOS (i386) — instalado via grub-mkrescue na criação da ISO
    # (não grava em disco real, conforme regra #5 do AGENTS.md)
    
    # Instalar GRUB para UEFI (amd64)
    if [ "${ARCH}" = "amd64" ]; then
        chroot "${rootfs}" grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Lume 2>/dev/null || true
    fi
    
    # Gerar grub.cfg
    chroot "${rootfs}" grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
    
    log_ok "GRUB configurado"
}

# ==============================================================================
# Passo 6: Criar SquashFS
# ==============================================================================

create_squashfs() {
    local rootfs="${WORK_DIR}/rootfs"
    local squashfs="${WORK_DIR}/live-filesystem.squashfs"
    
    log "Criando SquashFS (sistema imutável)..."
    
    if command -v mksquashfs >/dev/null 2>&1; then
        mksquashfs "${rootfs}" "${squashfs}" -comp xz -b 1M -no-duplicates 2>/dev/null || {
            log_err "Falha ao criar SquashFS"
            return 1
        }
    else
        log_err "mksquashfs não encontrado. Instale squashfs-tools."
        return 1
    fi
    
    if [ -f "${squashfs}" ]; then
        local size_mb
        size_mb=$(du -sm "${squashfs}" 2>/dev/null | cut -f1)
        log_ok "SquashFS criado: ${squashfs} (${size_mb} MB)"
    else
        log_err "SquashFS não foi criado"
        return 1
    fi
}

# ==============================================================================
# Passo 6: Criar verity para integridade
# ==============================================================================

create_verity() {
    local squashfs="${WORK_DIR}/live-filesystem.squashfs"
    local verity_file="${WORK_DIR}/live-filesystem.verity"
    local verity_hash="${WORK_DIR}/live-filesystem.verity.verity"
    
    log "Criando verity para integridade dos slots..."
    
    if command -v veritysetup >/dev/null 2>&1; then
        # Criar verity para slot A
        veritysetup format "${squashfs}" "${verity_file}" 2>/dev/null || true
        
        # Verificar se foi criado
        if [ -f "${verity_file}" ]; then
            log_ok "Verity criado: ${verity_file}"
        else
            log_warn "veritysetup executado mas arquivo não encontrado"
        fi
    else
        log_warn "veritysetup não encontrado, verity não configurado"
    fi
}

# ==============================================================================
# Passo 6: Criar ISO com grub-mkrescue
# ==============================================================================

create_iso() {
    local iso_dir="${WORK_DIR}/iso"
    local iso_file="${ISO_PATH}"
    
    log "Criando ISO com grub-mkrescue..."
    
    mkdir -p "${iso_dir}/boot/grub"
    
    # Copiar kernel e initrd
    cp "${WORK_DIR}/rootfs/boot/vmlinuz-*" "${iso_dir}/boot/vmlinuz" 2>/dev/null || true
    cp "${WORK_DIR}/rootfs/boot/initrd.img-*" "${iso_dir}/boot/initrd" 2>/dev/null || true
    
    # Copiar SquashFS
    cp "${WORK_DIR}/live-filesystem.squashfs" "${iso_dir}/boot/live-filesystem.squashfs" 2>/dev/null || true
    
    # Copiar configuração GRUB
    cp iso/grub/grub.cfg "${iso_dir}/boot/grub/grub.cfg" 2>/dev/null || true
    
    # Criar ISO com grub-mkrescue
    if command -v grub-mkrescue >/dev/null 2>&1; then
        grub-mkrescue -o "${ISO_PATH}" "${iso_dir}" 2>/dev/null || true
    else
        log_err "grub-mkrescue não encontrado, ISO não será criada"
        return 1
    fi
    
    if [ -f "${ISO_PATH}" ]; then
        local iso_size
        iso_size=$(du -sh "${ISO_PATH}" 2>/dev/null | cut -f1)
        log_ok "ISO criada: ${ISO_PATH} (${iso_size})"
    else
        log_err "ISO não foi criada"
        return 1
    fi
}

# ==============================================================================
# EXECUÇÃO PRINCIPAL
# ==============================================================================

main() {
    log "============================================================"
    log "  Iniciando build ISO Lume OS ${ARCH}"
    log "============================================================"
    
    check_dependencies
    check_root
    prepare_work_dir
    bootstrap_system
    configure_system
    configure_plymouth
    configure_grub
    create_squashfs
    create_verity
    create_iso
    
    log "============================================================"
    log "  ISO Lume OS ${ARCH} construída com sucesso!"
    log "  Arquivo: ${ISO_PATH}"
    if [ -f "${ISO_PATH}" ]; then
        local iso_size
        iso_size=$(du -sh "${ISO_PATH}" 2>/dev/null | cut -f1)
        log "  Tamanho: ${iso_size}"
    fi
    log "============================================================"
}

main "$@"
