#!/usr/bin/env bash
# install-essentials.sh — Instala o Pacote Essenciais no OOBE (1 clique)
# Requisitos fase 13:
#   - OnlyOffice, WhatsApp PWA, Spotify/Discord/Zoom/Steam por tier
#   - Teams PWA, Brave opcional
#   - PWAs via Firefox modo app + .desktop + ícone
#   - MIME defaults configurados

set -euo pipefail

LUME_TIER="${LUME_TIER:-prime}"
ESS_DIR="/usr/share/lume/essentials"
DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/usr/share/icons/hicolor/48x48/apps"
MIME_DIR="/usr/share/applications"

log() {
    echo "[essentials] $1"
}

# ==================== PACOTE ESSENCIAIS ====================
install_essentials() {
    log "Iniciando instalação do Pacote Essenciais (tier: ${LUME_TIER})"

    local apps=()

    # Apps base (todos os tiers)
    apps+=("onlyoffice")
    apps+=("whatsapp-pwa")
    apps+=("teams-pwa")

    # Apps por tier
    case "$LUME_TIER" in
        prime)
            apps+=("spotify" "discord" "zoom" "steam" "brave")
            ;;
        core)
            apps+=("spotify" "discord" "zoom")
            ;;
        lite)
            apps+=("spotify")
            ;;
    esac

    for app in "${apps[@]}"; do
        log "Instalando: $app"
        case "$app" in
            onlyoffice)
                flatpak install -y flathub org.onlyoffice.desktopeditors || true
                ;;
            whatsapp-pwa)
                create_pwa "WhatsApp" "https://web.whatsapp.com" "whatsapp"
                ;;
            teams-pwa)
                create_pwa "Teams" "https://teams.microsoft.com" "teams"
                ;;
            spotify)
                flatpak install -y flathub com.spotify.Client || true
                ;;
            discord)
                flatpak install -y flathub com.discordapp.Discord || true
                ;;
            zoom)
                flatpak install -y flathub us.zoom.Zoom || true
                ;;
            steam)
                flatpak install -y flathub com.valvesoftware.Steam || true
                ;;
            brave)
                flatpak install -y flathub com.brave.Browser || true
                ;;
        esac
        log "Concluído: $app"
    done

    log "Pacote Essenciais instalado com sucesso!"
}

# ==================== CRIAR PWA ====================
create_pwa() {
    local nome="$1"
    local url="$2"
    local id="$3"
    local desktop_file="${DESKTOP_DIR}/${id}.desktop"
    local icon_file="${ICON_DIR}/${id}.png"

    log "Criando PWA: $nome ($url)"

    # Criar ícone simples se não existir
    if [ ! -f "$icon_file" ]; then
        # Criar um placeholder SVG convertido para PNG ou usar SVG diretamente
        cat > "${ICON_DIR}/${id}.svg" << EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <rect width="48" height="48" rx="12" fill="#3E8EF7"/>
  <text x="24" y="28" font-family="sans-serif" font-size="20" text-anchor="middle" fill="#FFFFFF">${id:0:1}</text>
</svg>
EOF
        # Converter para PNG se imagem estiver disponível, senão manter SVG
        if command -v convert >/dev/null 2>&1; then
            convert "${ICON_DIR}/${id}.svg" "$icon_file" 2>/dev/null || true
        fi
    fi

    # Criar arquivo .desktop para o PWA
    cat > "$desktop_file" << EOF
[Desktop Entry]
Name=$nome
Comment=Acessar $nome via PWA (Firefox modo app)
Exec=firefox --app=$url --name="$nome" --class="$id"
Icon=${ICON_DIR}/${id}.svg
Terminal=false
Type=Application
Categories=Network;WebBrowser;
StartupNotify=true
MimeType=x-scheme-handler/http;x-scheme-handler/https;
EOF

    chmod +x "$desktop_file"
    log "PWA criado: $desktop_file"
}

# ==================== CONFIGURAR MIME DEFAULTS ====================
configure_mime() {
    log "Configurando MIME defaults"

    local mime_file="${MIME_DIR}/mimeapps.list"

    # OnlyOffice
    cat >> "$mime_file" << EOF

[Default Applications]
application/vnd.oasis.opendocument.text=org.onlyoffice.desktopeditors.writer.desktop
application/vnd.oasis.opendocument.spreadsheet=org.onlyoffice.desktopeditors.calc.desktop
application/vnd.oasis.opendocument.presentation=org.onlyoffice.desktopeditors.impress.desktop
application/vnd.openxmlformats-officedocument.wordprocessingml.document=org.onlyoffice.desktopeditors.writer.desktop
application/vnd.openxmlformats-officedocument.spreadsheetml.sheet=org.onlyoffice.desktopeditors.calc.desktop
application/vnd.openxmlformats-officedocument.presentationml.presentation=org.onlyoffice.desktopeditors.impress.desktop
application/pdf=org.onlyoffice.desktopeditors.viewer.desktop
image/jpeg=org.onlyoffice.desktopeditors.viewer.desktop
image/png=org.onlyoffice.desktopeditors.viewer.desktop
EOF

    # WhatsApp PWA
    cat >> "$mime_file" << EOF
x-scheme-handler/whatsapp=whatsapp.desktop
EOF

    # Teams PWA
    cat >> "$mime_file" << EOF
x-scheme-handler/msteams=teams.desktop
EOF

    # Spotify
    cat >> "$mime_file" << EOF
audio/x-spotify=com.spotify.Client.desktop
EOF

    # Discord
    cat >> "$mime_file" << EOF
x-scheme-handler/discord=com.discordapp.Discord.desktop
EOF

    # Zoom
    cat >> "$mime_file" << EOF
x-scheme-handler/zoommtg=us.zoom.Zoom.desktop
EOF

    # Steam
    cat >> "$mime_file" << EOF
x-scheme-handler/steam=com.valvesoftware.Steam.desktop
EOF

    log "MIME defaults configurados com sucesso!"
}

# ==================== PRINCIPAL ====================
main() {
    log "=== Instalação do Pacote Essenciais Lume OS ==="
    log "Tier: ${LUME_TIER}"

    install_essentials
    configure_mime

    log ""
    log "=== Instalação concluída com sucesso! ==="
    log "Reinicie a sessão para aplicar todas as alterações."
}

main "$@"
