#!/usr/bin/env bash
# create-pwa.sh — Cria PWA via Firefox modo app + .desktop + ícone
# Requisitos fase 13:
#   - PWAs: Firefox modo app + .desktop + ícone (WhatsApp, Teams, Brave opcional)

set -euo pipefail

NOME="$1"
URL="$2"
ID="$3"
ICONE="${4:-}"

DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/usr/share/icons/hicolor/48x48/apps"

log() {
    echo "[pwa] $1"
}

# Validar parâmetros
if [ -z "$NOME" ] || [ -z "$URL" ] || [ -z "$ID" ]; then
    echo "Uso: $0 <nome> <url> <id> [icone.svg]"
    echo "Exemplo: $0 WhatsApp https://web.whatsapp.com whatsapp"
    exit 1
fi

log "Criando PWA: $NOME ($URL)"

# Criar ícone se não fornecido
if [ -z "$ICONE" ] || [ ! -f "$ICON" ]; then
    ICONE="${ICON_DIR}/${id}.svg"
    if [ ! -f "$ICON" ]; then
        cat > "$ICON" << EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <rect width="48" height="48" rx="12" fill="#3E8EF7"/>
  <text x="24" y="28" font-family="sans-serif" font-size="20" text-anchor="middle" fill="#FFFFFF">${id:0:1}</text>
</svg>
EOF
        # Tentar converter para PNG
        if command -v convert >/dev/null 2>&1; then
            convert "$ICON" "${ICON_DIR}/${id}.png" 2>/dev/null || true
        fi
    fi
else
    cp "$ICON" "${ICON_DIR}/${id}.svg"
fi

# Criar arquivo .desktop para o PWA
DESKTOP_FILE="${DESKTOP_DIR}/${id}.desktop"
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=$NOME
Comment=Acessar $NOME via PWA (Firefox modo app)
Exec=firefox --app=$URL --name="$NOME" --class="$id"
Icon=${ICON_DIR}/${id}.svg
Terminal=false
Type=Application
Categories=Network;WebBrowser;
StartupNotify=true
MimeType=x-scheme-handler/http;x-scheme-handler/https;
EOF

chmod +x "$DESKTOP_FILE"

log "PWA criado com sucesso!"
log "  Nome: $NOME"
log "  URL: $URL"
log "  ID: $id"
log "  Desktop: $DESKTOP_FILE"
log "  Ícone: ${ICON_DIR}/${id}.svg"
