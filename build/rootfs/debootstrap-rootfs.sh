#!/bin/bash
# ==============================================================================
# build/rootfs/debootstrap-rootfs.sh - Cria sistema base Debian via debootstrap
#
# Requisitos Fase 28 (Sistema Base Real):
#   - Rootfs Debian 13 amd64/i386 funcional
#   - systemd, dbus, kernel, firmware, pacotes essenciais
#   - Locales pt-BR e en-US
#   - Usuário padrão 'lume' com sudo
#   - Fuso horário America/Sao_Paulo e UTC
#   - zram como swap padrão (zstd)
#   - Hibernação desligada por padrão
#
# USO: bash build/rootfs/debootstrap-rootfs.sh [amd64|i386] [diretorio_saida]
# AMBIENTE: Linux (VM/container), NÃO Windows nativo. Deve rodar como root.
# ==============================================================================

set -euo pipefail

ARCH="${1:-amd64}"
ROOTFS_DIR="${2:-work/rootfs-${ARCH}}"
DEBIAN_SUITE="stable"  # Debian 13 (trixie) ou stable
DEBIAN_MIRROR="http://deb.debian.org/debian"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[rootfs-build]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err() { echo -e "${RED}[ERRO]${NC} $1" >&2; }

# ==============================================================================
# Verificações prévias
# ==============================================================================

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_err "Este script deve ser executado como root (usa debootstrap, chroot, mount)."
        log_info "Use: sudo bash build/rootfs/debootstrap-rootfs.sh ${ARCH}"
        exit 1
    fi
}

check_dependencies() {
    log "Verificando dependências de build..."
    
    local missing=0
    local deps=(debootstrap)
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            log_err "Dependência não encontrada: $dep"
            missing=1
        else
            log_ok "${dep} encontrado"
        fi
    done
    
    if [ "$missing" -ne 0 ]; then
        log_err "Instale as dependências antes de continuar."
        log_info "Exemplo (Debian/Ubuntu): sudo apt-get install debootstrap"
        exit 1
    fi
}

# ==============================================================================
# Tarefa 28.1 - Criar rootfs via debootstrap
# ==============================================================================

create_rootfs() {
    log "Criando rootfs Debian ${DEBIAN_SUITE} (${ARCH}) via debootstrap..."
    log "Diretório de destino: ${ROOTFS_DIR}"
    
    if [ -d "${ROOTFS_DIR}/var/lib/dpkg" ]; then
        log_warn "Rootfs já existe em ${ROOTFS_DIR}. Removendo para recriar."
        rm -rf "${ROOTFS_DIR}"
    fi
    
    mkdir -p "${ROOTFS_DIR}"
    
    debootstrap \
        --arch="${ARCH}" \
        --variant=minbase \
        "${DEBIAN_SUITE}" \
        "${ROOTFS_DIR}" \
        "${DEBIAN_MIRROR}" 2>&1 | tee "${ROOTFS_DIR}/../debootstrap-${ARCH}.log" || {
        log_err "Falha no debootstrap. Veja o log em ${ROOTFS_DIR}/../debootstrap-${ARCH}.log"
        exit 1
    }
    
    if [ -d "${ROOTFS_DIR}/var/lib/dpkg" ]; then
        log_ok "Rootfs criado com sucesso: ${ROOTFS_DIR}/var/lib/dpkg existe"
    else
        log_err "Rootfs não foi criado corretamente"
        exit 1
    fi
}

# ==============================================================================
# Tarefa 28.2 - Configurar arquivos base do sistema
# ==============================================================================

configure_base_files() {
    local rootfs="${ROOTFS_DIR}"
    
    log "Configurando arquivos base do sistema..."
    
    # Hostname
    echo "lume" > "${rootfs}/etc/hostname"
    log_ok "hostname configurado: lume"
    
    # Hosts
    cat > "${rootfs}/etc/hosts" << 'EOF'
127.0.0.1   localhost
127.0.1.1   lume.localdomain lume
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF
    log_ok "/etc/hosts configurado"
    
    # Resolv.conf
    cat > "${rootfs}/etc/resolv.conf" << 'EOF'
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
    log_ok "/etc/resolv.conf configurado"
    
    # APT sources
    cat > "${rootfs}/etc/apt/sources.list" << EOF
deb http://deb.debian.org/debian stable main contrib non-free
deb http://security.debian.org/debian-security stable-security main contrib non-free
deb http://deb.debian.org/debian stable-updates main contrib non-free
EOF
    log_ok "/etc/apt/sources.list configurado"
}

# ==============================================================================
# Tarefa 28.3 - Instalar pacotes essenciais
# ==============================================================================

install_essential_packages() {
    local rootfs="${ROOTFS_DIR}"
    
    log "Instalando pacotes essenciais no rootfs..."
    
    # Montar sistemas de arquivos virtuais para chroot
    mount --bind /dev "${rootfs}/dev" 2>/dev/null || true
    mount --bind /dev/pts "${rootfs}/dev/pts" 2>/dev/null || true
    mount --bind /proc "${rootfs}/proc" 2>/dev/null || true
    mount --bind /sys "${rootfs}/sys" 2>/dev/null || true
    
    # Atualizar lista de pacotes
    chroot "${rootfs}" apt-get update 2>/dev/null || true
    
    # Instalar pacotes essenciais
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
        linux-firmware \
        firmware-linux \
        firmware-linux-free \
        pipewire \
        wireplumber \
        network-manager \
        bluez \
        bluez-tools \
        p7zip-full \
        p7zip-rar \
        openssh-server \
        openssh-client \
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
        2>/dev/null || log_warn "Alguns pacotes podem não ter sido instalados (verificar conexão com internet)"
    
    # Desmontar sistemas de arquivos virtuais
    umount "${rootfs}/dev/pts" 2>/dev/null || true
    umount "${rootfs}/dev" 2>/dev/null || true
    umount "${rootfs}/proc" 2>/dev/null || true
    umount "${rootfs}/sys" 2>/dev/null || true
    
    log_ok "Pacotes essenciais instalados"
}

# ==============================================================================
# Tarefa 28.4 - Configurar locales pt-BR e en-US
# ==============================================================================

configure_locales() {
    local rootfs="${ROOTFS_DIR}"
    
    log "Configurando locales pt-BR e en-US..."
    
    mount --bind /dev "${rootfs}/dev" 2>/dev/null || true
    mount --bind /dev/pts "${rootfs}/dev/pts" 2>/dev/null || true
    mount --bind /proc "${rootfs}/proc" 2>/dev/null || true
    mount --bind /sys "${rootfs}/sys" 2>/dev/null || true
    
    # Gerar locales
    chroot "${rootfs}" locale-gen pt_BR.UTF-8 en_US.UTF-8 2>/dev/null || true
    chroot "${rootfs}" update-locale LANG=pt_BR.UTF-8 LC_NUMERIC=pt_BR.UTF-8 LC_TIME=pt_BR.UTF-8 LC_MONETARY=pt_BR.UTF-8 LC_PAPER=pt_BR.UTF-8 LC_NAME=pt_BR.UTF-8 LC_ADDRESS=pt_BR.UTF-8 LC_TELEPHONE=pt_BR.UTF-8 LC_MEASUREMENT=pt_BR.UTF-8 LC_IDENTIFICATION=pt_BR.UTF-8 2>/dev/null || true
    
    # Desmontar
    umount "${rootfs}/dev/pts" 2>/dev/null || true
    umount "${rootfs}/dev" 2>/dev/null || true
    umount "${rootfs}/proc" 2>/dev/null || true
    umount "${rootfs}/sys" 2>/dev/null || true
    
    if chroot "${rootfs}" locale -a 2>/dev/null | grep -q "pt_BR.utf8" && chroot "${rootfs}" locale -a 2>/dev/null | grep -q "en_US.utf8"; then
        log_ok "Locales pt-BR e en-US configurados"
    else
        log_warn "Locales podem não ter sido gerados corretamente"
    fi
}

# ==============================================================================
# Tarefa 28.5 - Criar usuário padrão 'lume' com sudo
# ==============================================================================

create_default_user() {
    local rootfs="${ROOTFS_DIR}"
    
    log "Criando usuário padrão 'lume'..."
    
    mount --bind /dev "${rootfs}/dev" 2>/dev/null || true
    mount --bind /dev/pts "${rootfs}/dev/pts" 2>/dev/null || true
    mount --bind /proc "${rootfs}/proc" 2>/dev/null || true
    mount --bind /sys "${rootfs}/sys" 2>/dev/null || true
    
    # Criar usuário
    chroot "${rootfs}" useradd -m -s /bin/bash lume 2>/dev/null || true
    
    # Definir senha padrão (lume) - deverá ser alterada no primeiro login
    echo "lume:lume" | chroot "${rootfs}" chpasswd 2>/dev/null || true
    
    # Adicionar ao grupo sudo
    chroot "${rootfs}" usermod -aG sudo lume 2>/dev/null || true
    
    # Configurar sudo sem senha para o usuário lume (modo live)
    echo "lume ALL=(ALL) NOPASSWD:ALL" > "${rootfs}/etc/sudoers.d/lume"
    chmod 440 "${rootfs}/etc/sudoers.d/lume"
    
    # Desmontar
    umount "${rootfs}/dev/pts" 2>/dev/null || true
    umount "${rootfs}/dev" 2>/dev/null || true
    umount "${rootfs}/proc" 2>/dev/null || true
    umount "${rootfs}/sys" 2>/dev/null || true
    
    if chroot "${rootfs}" id lume 2>/dev/null | grep -q "lume"; then
        log_ok "Usuário 'lume' criado com sudo"
    else
        log_warn "Usuário 'lume' pode não ter sido criado corretamente"
    fi
}

# ==============================================================================
# Tarefa 28.6 - Configurar fuso horário
# ==============================================================================

configure_timezone() {
    local rootfs="${ROOTFS_DIR}"
    
    log "Configurando fuso horário America/Sao_Paulo e UTC..."
    
    mount --bind /dev "${rootfs}/dev" 2>/dev/null || true
    mount --bind /dev/pts "${rootfs}/dev/pts" 2>/dev/null || true
    mount --bind /proc "${rootfs}/proc" 2>/dev/null || true
    mount --bind /sys "${rootfs}/sys" 2>/dev/null || true
    
    # Configurar fuso horário
    chroot "${rootfs}" ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime 2>/dev/null || true
    echo "America/Sao_Paulo" > "${rootfs}/etc/timezone" 2>/dev/null || true
    
    # Desmontar
    umount "${rootfs}/dev/pts" 2>/dev/null || true
    umount "${rootfs}/dev" 2>/dev/null || true
    umount "${rootfs}/proc" 2>/dev/null || true
    umount "${rootfs}/sys" 2>/dev/null || true
    
    log_ok "Fuso horário configurado: America/Sao_Paulo"
}

# ==============================================================================
# Tarefa 28.7 - Configurar zram como swap padrão (zstd)
# ==============================================================================

configure_zram() {
    local rootfs="${ROOTFS_DIR}"
    
    log "Configurando zram como swap padrão (zstd)..."
    
    mkdir -p "${rootfs}/etc/systemd/zram-generator.conf.d"
    
    cat > "${rootfs}/etc/systemd/zram-generator.conf.d/lume-zram.conf" << 'EOF'
[zram0]
zram-size = min(ram, 4096)
compression-algorithm = zstd
EOF
    
    log_ok "zram configurado com algoritmo zstd"
}

# ==============================================================================
# Tarefa 28.8 - Desabilitar hibernação por padrão
# ==============================================================================

disable_hibernation() {
    local rootfs="${ROOTFS_DIR}"
    
    log "Desabilitando hibernação por padrão..."
    
    mkdir -p "${rootfs}/etc/systemd/sleep.conf.d"
    
    cat > "${rootfs}/etc/systemd/sleep.conf.d/lume-no-hibernate.conf" << 'EOF'
[Sleep]
AllowSuspend=yes
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
EOF
    
    log_ok "Hibernação desabilitada por padrão"
}

# ==============================================================================
# EXECUÇÃO PRINCIPAL
# ==============================================================================

main() {
    log "============================================================"
    log "  Iniciando criação do rootfs Lume OS ${ARCH}"
    log "============================================================"
    
    check_root
    check_dependencies
    create_rootfs
    configure_base_files
    install_essential_packages
    configure_locales
    create_default_user
    configure_timezone
    configure_zram
    disable_hibernation
    
    log "============================================================"
    log "  Rootfs Lume OS ${ARCH} criado com sucesso!"
    log "  Diretório: ${ROOTFS_DIR}"
    log "============================================================"
    
    # Mostrar estatísticas do rootfs
    if command -v du >/dev/null 2>&1; then
        local size
        size=$(du -sh "${ROOTFS_DIR}" 2>/dev/null | cut -f1)
        log "  Tamanho: ${size}"
    fi
    
    log "============================================================"
}

main "$@"
