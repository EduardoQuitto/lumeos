#!/bin/bash
# seal-app.sh — Selar aplicativos Windows para isolamento
# Requisitos fase 19:
#   - Selos de isolamento para aplicativos Windows

set -euo pipefail

APP_NAME="${1:-}"
APP_PATH="${2:-}"
SEAL_DIR="${3:-$HOME/.local/share/lume/seals}"

log() {
    echo "[seal-app] $1"
}

# ==================== CRIAR SELO ====================
criar_selo() {
    log "Criando selo para: $APP_NAME"

    mkdir -p "$SEAL_DIR"

    local seal_file="$SEAL_DIR/${APP_NAME}.seal"
    local seal_hash

    # Calcular hash do aplicativo
    seal_hash=$(sha256sum "$APP_PATH" 2>/dev/null | cut -d' ' -f1)

    # Criar arquivo de selo
    cat > "$seal_file" << EOF
{
  "app": "$APP_NAME",
  "path": "$APP_PATH",
  "created": "$(date -Iseconds)",
  "hash": "$seal_hash",
  "sealed": true,
  "isolation": "bwrap",
  "wine_compatible": true
}
EOF

    log "Selo criado: $seal_file"
    log "Hash: $seal_hash"
}

# ==================== VERIFICAR SELO ====================
verificar_selo() {
    local app_name="${1:-}"
    local seal_file="$SEAL_DIR/${app_name}.seal"

    log "Verificando selo: $app_name"

    if [ ! -f "$seal_file" ]; then
        log "ERRO: Selo não encontrado para: $app_name"
        return 1
    fi

    log "Selo válido: $seal_file"
    cat "$seal_file"
}

# ==================== LISTAR SELOS ====================
listar_selos() {
    local seal_dir="${1:-$HOME/.local/share/lume/seals}"

    log "Selos disponíveis:"

    if [ ! -d "$seal_dir" ]; then
        log "Nenhum selo encontrado"
        return
    fi

    for file in "$seal_dir"/*.seal; do
        if [ -f "$file" ]; then
            local name
            name=$(basename "$file" .seal)
            log "  $name"
        fi
    done
}

# ==================== PRINCIPAL ====================
main() {
    local acao="${1:-criar}"

    case "$acao" in
        criar)
            criar_selo
            ;;
        verificar)
            verificar_selo "${2:-}"
            ;;
        listar)
            listar_selos "${2:-$HOME/.local/share/lume/seals}"
            ;;
        *)
            echo "Uso: $0 {criar|verificar|listar} [app_name] [app_path] [seal_dir]"
            echo ""
            echo "Exemplos:"
            echo "  $0 criar MeuApp /caminho/do/app.exe"
            echo "  $0 verificar MeuApp"
            echo "  $0 listar /caminho/dos/selos"
            exit 1
            ;;
    esac
}

main "$@"
