#!/bin/bash
# backup-restore.sh — Backup e Restauração do Pendrive Persistente
# Requisitos fase 16:
#   - Backup de dados persistentes
#   - Restauração de backup

set -euo pipefail

PENDRIVE_MOUNT="${1:-/mnt/lume-persist}"
BACKUP_DIR="${2:-/mnt/backups}"
ACAO="${3:-backup}"

log() {
    echo "[backup-restore] $1"
}

# ==================== BACKUP ====================
fazer_backup() {
    local arquivo="backup_lume_persist_$(date +%Y%m%d_%H%M%S).tar.gz"

    log "Iniciando backup do pendrive persistente..."
    log "Origem: $PENDRIVE_MOUNT"
    log "Destino: $BACKUP_DIR/${arquivo}"

    mkdir -p "$BACKUP_DIR"

    # Criar backup com compressão
    tar czf "${BACKUP_DIR}/${arquivo}" -C "$PENDRIVE_MOUNT" . 2>/dev/null || true

    local tamanho
    tamanho=$(du -h "${BACKUP_DIR}/${arquivo}" 2>/dev/null | cut -f1)

    log "Backup concluído: ${BACKUP_DIR}/${arquivo} ($tamanho)"
    echo "${BACKUP_DIR}/${arquivo}"
}

# ==================== RESTAURAÇÃO ====================
restaurar_backup() {
    local arquivo="$1"

    if [ -z "$arquivo" ] || [ ! -f "$arquivo" ]; then
        log "ERRO: Arquivo de backup não especificado ou não encontrado: $arquivo"
        exit 1
    fi

    log "Iniciando restauração do backup..."
    log "Arquivo: $arquivo"
    log "Destino: $PENDRIVE_MOUNT"

    # Verificar se o pendrive está montado
    if ! mountpoint -q "$PENDRIVE_MOUNT"; then
        log "ERRO: Pendrive não está montado em $PENDRIVE_MOUNT"
        exit 1
    fi

    # Fazer backup do estado atual antes de sobrescrever
    if [ "$(ls -A "$PENDRIVE_MOUNT" 2>/dev/null)" ]; then
        log "Fazendo backup do estado atual antes da restauração..."
        fazer_backup "/mnt/backups/pre-restore"
    fi

    # Limpar conteúdo atual
    rm -rf "${PENDRIVE_MOUNT:?}/"* 2>/dev/null || true

    # Extrair backup
    tar xzf "$arquivo" -C "$PENDRIVE_MOUNT" 2>/dev/null || true

    log "Restauração concluída com sucesso!"
}

# ==================== LISTAR BACKUPS ====================
listar_backups() {
    log "Backups disponíveis em $BACKUP_DIR:"

    if [ ! -d "$BACKUP_DIR" ]; then
        log "Nenhum backup encontrado"
        return
    fi

    ls -lh "$BACKUP_DIR"/backup_lume_persist_*.tar.gz 2>/dev/null || \
        log "Nenhum backup encontrado"
}

# ==================== PRINCIPAL ====================
main() {
    case "$ACAO" in
        backup)
            fazer_backup
            ;;
        restore)
            restaurar_backup "${4:-}"
            ;;
        list)
            listar_backups
            ;;
        *)
            echo "Uso: $0 {backup|restore|list} [pendrive_mount] [backup_dir] [arquivo_backup]"
            echo ""
            echo "Exemplos:"
            echo "  $0 backup /mnt/lume-persist /mnt/backups"
            echo "  $0 restore /mnt/lume-persist /mnt/backups backup_lume_persist_20261112_100000.tar.gz"
            echo "  $0 list /mnt/lume-persist /mnt/backups"
            exit 1
            ;;
    esac
}

main "$@"
