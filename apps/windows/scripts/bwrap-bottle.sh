#!/bin/bash
# bwrap-bottle.sh — Gerenciador de garrafas bwrap para Lume OS
# Requisitos fase 19:
#   - Garrafas bwrap com selos de isolamento
#   - Isolamento de aplicativos Windows

set -euo pipefail

BOTTLE_NAME="${1:-default}"
BOTTLE_DIR="${2:-$HOME/.local/share/lume/bottles/$BOTTLE_NAME}"
WINE_PREFIX="${3:-$HOME/.wine}"

log() {
    echo "[bwrap-bottle] $1"
}

# ==================== CRIAR GARRAFA ====================
criar_garrafa() {
    log "Criando garrafa bwrap: $BOTTLE_NAME"

    mkdir -p "$BOTTLE_DIR"
    mkdir -p "$BOTTLE_DIR/home"
    mkdir -p "$BOTTLE_DIR/drive_c"
    mkdir -p "$BOTTLE_DIR/seals"

    # Copiar prefixo Wine para a garrafa
    if [ -d "$WINE_PREFIX" ]; then
        cp -r "$WINE_PREFIX"/* "$BOTTLE_DIR/drive_c/" 2>/dev/null || true
    fi

    log "Garrafa criada: $BOTTLE_DIR"
}

# ==================== SELAR GARRAFA ====================
selar_garrafa() {
    log "Selando garrafa: $BOTTLE_NAME"

    local seal_file="$BOTTLE_DIR/seals/seal.sig"
    local seal_hash

    # Calcular hash da garrafa para selo
    seal_hash=$(find "$BOTTLE_DIR" -type f -exec sha256sum {} \; 2>/dev/null | sha256sum | cut -d' ' -f1)

    # Criar arquivo de selo
    cat > "$seal_file" << EOF
{
  "bottle": "$BOTTLE_NAME",
  "created": "$(date -Iseconds)",
  "hash": "$seal_hash",
  "sealed": true,
  "isolation": "bwrap",
  "wine_prefix": "$WINE_PREFIX"
}
EOF

    log "Garrafa selada: $seal_file"
}

# ==================== EXECUTAR NA GARRAFA ====================
executar_garrafa() {
    local app_cmd="${1:-wine}"
    local app_args="${2:-}"

    log "Executando na garrafa: $BOTTLE_NAME"

    # Verificar se a garrafa existe
    if [ ! -d "$BOTTLE_DIR" ]; then
        log "ERRO: Garrafa não encontrada: $BOTTLE_DIR"
        exit 1
    fi

    # Executar com bwrap (isolamento)
    bwrap \
        --ro-bind /usr /usr \
        --ro-bind /lib /lib \
        --ro-bind /lib64 /lib64 \
        --proc /proc \
        --dev /dev \
        --tmpfs /tmp \
        --bind "$BOTTLE_DIR/drive_c" "$WINE_PREFIX" \
        --bind "$BOTTLE_DIR/home" "$HOME" \
        --setenv WINEPREFIX "$WINE_PREFIX" \
        --setenv WINEDEBUG=-all \
        --unshare-all \
        --share-net \
        wine "$app_cmd" "$app_args" 2>/dev/null || true

    log "Execução concluída"
}

# ==================== LISTAR GARRAFAS ====================
listar_garrafas() {
    local bottle_dir="${1:-$HOME/.local/share/lume/bottles}"

    log "Garrafas disponíveis:"

    if [ ! -d "$bottle_dir" ]; then
        log "Nenhuma garrafa encontrada"
        return
    fi

    for dir in "$bottle_dir"/*/; do
        if [ -d "$dir" ]; then
            local name
            name=$(basename "$dir")
            local sealed="não"
            if [ -f "$dir/seals/seal.sig" ]; then
                sealed="sim"
            fi
            log "  $name (selo: $sealed)"
        fi
    done
}

# ==================== PRINCIPAL ====================
main() {
    local acao="${1:-criar}"

    case "$acao" in
        criar)
            criar_garrafa
            selar_garrafa
            ;;
        selar)
            selar_garrafa
            ;;
        executar)
            executar_garrafa "${2:-wine}" "${3:-}"
            ;;
        listar)
            listar_garrafas "${2:-$HOME/.local/share/lume/bottles}"
            ;;
        *)
            echo "Uso: $0 {criar|selar|executar|listar} [garrafa] [comando] [argumentos]"
            echo ""
            echo "Exemplos:"
            echo "  $0 criar meu-app /caminho/do/prefixo"
            echo "  $0 selar meu-app"
            echo "  $0 executar meu-app wine notepad.exe"
            echo "  $0 listar /caminho/das/garrafas"
            exit 1
            ;;
    esac
}

main "$@"
