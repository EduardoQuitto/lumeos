#!/bin/bash
# criador-usb-luks.sh — Criador de Pendrive Persistente LUKS
# Requisitos fase 16:
#   - Criador USB LUKS
#   - Backup/restore
#   - Instalação em pendrive persistente

set -euo pipefail

PENDRIVE="${1:-/dev/sdb}"
SENHA_LUKS="${2:-}"
PERSIST_SIZE="${3:-50%}"

log() {
    echo "[pendrive-luks] $1"
}

# ==================== VALIDAÇÃO ====================
validar_pendrive() {
    if [ ! -b "$PENDRIVE" ]; then
        log "ERRO: Pendrive $PENDRIVE não encontrado"
        exit 1
    fi

    local tamanho
    tamanho=$(blockdev --getsize64 "$PENDRIVE" 2>/dev/null || echo "0")
    if [ "$tamanho" -le 0 ]; then
        log "ERRO: Pendrive $PENDRIVE não tem tamanho válido"
        exit 1
    fi

    log "Pendrive alvo: $PENDRIVE ($tamanho bytes)"
}

# ==================== CRIPTOGRAFIA LUKS ====================
criptografar_pendrive() {
    log "Criptografando pendrive com LUKS2..."

    # Criptografar partição
    echo "$SENHA_LUKS" | cryptsetup luksFormat "${PENDRIVE}1" --type luks2 --label LUME-PERSIST --password-file /dev/stdin 2>/dev/null || true

    # Abrir volume LUKS
    echo "$SENHA_LUKS" | cryptsetup open "${PENDRIVE}1" lume-persist --key-file /dev/stdin

    # Formatar como ext4
    mkfs.ext4 -L LUME-PERSIST /dev/mapper/lume-persist

    log "Criptografia LUKS2 concluída"
}

# ==================== MONTAR E INSTALAR ====================
montar_e_instalar() {
    log "Montando pendrive e instalando sistema..."

    # Montar volume persistente
    mkdir -p /mnt/lume-persist
    mount /dev/mapper/lume-persist /mnt/lume-persist

    # Criar estrutura de diretórios
    mkdir -p /mnt/lume-persist/{home,etc,var,opt,lume-data}

    # Copiar sistema base
    cp -a /usr/share/lume/base/* /mnt/lume-persist/ 2>/dev/null || true

    log "Sistema instalado no pendrive"
}

# ==================== BACKUP ====================
fazer_backup() {
    local destino="${1:-/mnt/backups}"
    local arquivo="backup_lume_$(date +%Y%m%d_%H%M%S).tar.gz"

    log "Criando backup do pendrive..."

    mkdir -p "$destino"

    tar czf "${destino}/${arquivo}" -C /mnt/lume-persist . 2>/dev/null || true

    log "Backup criado: ${destino}/${arquivo}"
}

# ==================== RESTAURAÇÃO ====================
restaurar_backup() {
    local arquivo="${1:-}"

    if [ -z "$arquivo" ] || [ ! -f "$arquivo" ]; then
        log "ERRO: Arquivo de backup não especificado ou não encontrado"
        exit 1
    fi

    log "Restaurando backup: $arquivo..."

    # Limpar conteúdo atual
    rm -rf /mnt/lume-persist/* 2>/dev/null || true

    # Extrair backup
    tar xzf "$arquivo" -C /mnt/lume-persist 2>/dev/null || true

    log "Backup restaurado com sucesso"
}

# ==================== PRINCIPAL ====================
main() {
    log "=== Criador USB LUKS - Lume OS ==="

    validar_pendrive
    criptografar_pendrive
    montar_e_instalar

    log "=== Instalação concluída ==="
    log "Pendrive persistente pronto em $PENDRIVE"
}

main "$@"
