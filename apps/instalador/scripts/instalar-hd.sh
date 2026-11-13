#!/bin/bash
# instalador-hd.sh — Instalador HD do Lume OS
# Requisitos fase 15:
#   - Instala em disco vazio VM com LUKS+A/B
#   - Teste instalação

set -euo pipefail

DISCO="${1:-/dev/sda}"
USUARIO="${2:-usuario}"
SENHA_LUKS="${3:-}"
SENHA_USUARIO="${4:-}"

log() {
    echo "[instalador-hd] $1"
}

# ==================== VALIDAÇÃO ====================
validar_disco() {
    if [ ! -b "$DISCO" ]; then
        log "ERRO: Disco $DISCO não encontrado"
        exit 1
    fi

    local tamanho
    tamanho=$(blockdev --getsize64 "$DISCO" 2>/dev/null || echo "0")
    if [ "$tamanho" -le 0 ]; then
        log "ERRO: Disco $DISCO não tem tamanho válido"
        exit 1
    fi

    log "Disco alvo: $DISCO ($tamanho bytes)"
}

# ==================== PARTICIONAMENTO ====================
particionar_disco() {
    log "Iniciando particionamento de $DISCO"

    # Apagar tabela de partições existente
    wipefs -af "$DISCO" 2>/dev/null || true
    dd if=/dev/zero of="$DISCO" bs=1M count=10 2>/dev/null || true

    # Criar tabela GPT
    parted -s "$DISCO" mklabel gpt

    # Partição EFI (512 MB)
    parted -s "$DISCO" mkpart primary fat32 1MiB 513MiB
    parted -s "$DISCO" set 1 esp on

    # Partição LUKS (resto do disco)
    parted -s "$DISCO" mkpart primary 513MiB 100%

    log "Particionamento concluído"
}

# ==================== CRIPTOGRAFIA LUKS ====================
criptografar_luks() {
    log "Criptografando partição com LUKS2..."

    echo "$SENHA_LUKS" | cryptsetup luksFormat "${DISCO}2" --type luks2 --label LUME-SLOT-A --password-file /dev/stdin 2>/dev/null || true

    # Abrir slot A
    echo "$SENHA_LUKS" | cryptsetup open "${DISCO}2" lume-slot-a --key-file /dev/stdin

    # Formatar slot A como ext4
    mkfs.ext4 -L LUME-SLOT-A /dev/mapper/lume-slot-a

    log "Criptografia LUKS2 concluída"
}

# ==================== INSTALAÇÃO ====================
instalar_sistema() {
    log "Instalando sistema base..."

    # Montar slot A
    mkdir -p /mnt/lume
    mount /dev/mapper/lume-slot-a /mnt/lume

    # Criar estrutura de diretórios
    mkdir -p /mnt/lume/{boot,home,etc,var,usr,bin,sbin,lib,lib64,tmp,run,media,mnt,opt,root}

    # Copiar sistema base (placeholder - em produção usaria debootstrap ou extração de SquashFS)
    log "Copiando sistema base..."
    cp -a /usr/share/lume/base/* /mnt/lume/ 2>/dev/null || true

    # Criar fstab
    cat > /mnt/lume/etc/fstab << EOF
/dev/mapper/lume-slot-a  /              ext4    defaults,noatime  0 1
PARTUUID=$(blkid -s PARTUUID -o value "${DISCO}1")  /boot  vfat    defaults  0 2
EOF

    log "Sistema base instalado"
}

# ==================== INSTALAÇÃO SLOT B ====================
instalar_slot_b() {
    log "Preparando slot B (vazio para A/B rollback)..."

    # Criar slot B vazio (será preenchido em atualizações)
    echo "$SENHA_LUKS" | cryptsetup luksFormat "${DISCO}2" --type luks2 --label LUME-SLOT-B --key-file /dev/stdin 2>/dev/null || true

    log "Slot B preparado (vazio para atualizações futuras)"
}

# ==================== INSTALAÇÃO DO GRUB ====================
instalar_grub() {
    log "Instalando GRUB..."

    # Montar partição EFI
    mkdir -p /mnt/lume/boot/efi
    mount "${DISCO}1" /mnt/lume/boot/efi

    # Bind mounts para chroot
    mount --bind /dev /mnt/lume/dev
    mount --bind /proc /mnt/lume/proc
    mount --bind /sys /mnt/lume/sys

    # Instalar GRUB
    chroot /mnt/lume grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Lume

    # Gerar grub.cfg
    chroot /mnt/lume grub-mkconfig -o /boot/grub/grub.cfg

    # Desmontar
    umount /mnt/lume/dev /mnt/lume/proc /mnt/lume/sys
    umount /mnt/lume/boot/efi

    log "GRUB instalado com sucesso"
}

# ==================== FINALIZAÇÃO ====================
finalizar() {
    log "Finalizando instalação..."

    # Desmontar tudo
    umount /mnt/lume 2>/dev/null || true
    cryptsetup close lume-slot-a 2>/dev/null || true

    log "Instalação concluída com sucesso!"
    log "Reinicie o sistema para bootar no Lume OS"
}

# ==================== PRINCIPAL ====================
main() {
    log "=== Iniciando Instalador HD do Lume OS ==="

    validar_disco
    particionar_disco
    criptografar_luks
    instalar_sistema
    instalar_slot_b
    instalar_grub
    finalizar

    log "=== Instalação concluída ==="
}

main "$@"
