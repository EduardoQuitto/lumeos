import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Store — Loja de aplicativos
// Requisitos fase 12:
//   - 8 categorias (Essenciais, Internet, Estudo&Office, Programação, Jogos, Windows, Segurança/Lab, Sistema)
//   - Badges tier (prime/core/lite)
//   - Fila de instalação
//   - Flatpak install/remove
//   - Updates separado sistema/apps
//   - Aba garrafas (Windows bottles)
ApplicationWindow {
    id: root
    visible: true
    width: 1000
    height: 700
    title: "Lume Store"
    color: "#0E1116"

    property string abaAtiva: "categorias"
    property string busca: ""

    // ==================== TOOLBAR SUPERIOR ====================
    ToolBar {
        id: toolbar
        width: parent.width
        padding: 8
        spacing: 8

        Button {
            text: "Lume Store"
            font.pointSize: 16
            font.bold: true
            color: "#3E8EF7"
            enabled: false
            background: Rectangle { color: "transparent" }
        }

        Item { Layout.fillWidth: true }

        TextField {
            id: campoBusca
            placeholderText: "Buscar aplicativos..."
            font.pointSize: 12
            width: 250
            onTextChanged: root.busca = text
        }

        Button {
            text: "Buscar"
            font.pointSize: 12
            onClicked: console.log("Buscar: " + campoBusca.text)
        }

        Separator { }

        Button {
            text: "Atualizar"
            font.pointSize: 12
            background: Rectangle { color: "#3E8EF7"; radius: 6 }
            onClicked: console.log("Verificar atualizações")
        }

        Button {
            text: "Sair"
            font.pointSize: 12
            color: "#C42B1C"
            background: Rectangle { color: "transparent"; radius: 6 }
            onClicked: root.close()
        }
    }

    // ==================== CONTEÚDO PRINCIPAL ====================
    Row {
        id: conteudo
        anchors.fill: parent
        anchors.topMargin: toolbar.height
        spacing: 0

        // ==================== SIDEBAR: CATEGORIAS (8) ====================
        Rectangle {
            id: sidebar
            width: 240
            color: "#101418"
            border.color: "#1e293b"
            border.width: 1

            Column {
                anchors.fill: parent
                spacing: 0

                Text {
                    text: "Categorias"
                    font.pointSize: 16
                    font.bold: true
                    color: "#F7F9FC"
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.top: parent.top
                    anchors.topMargin: 16
                }

                ListView {
                    id: listaCategorias
                    anchors.top: parent.top
                    anchors.topMargin: 48
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 2
                    model: [
                        { id: "essenciais",    icone: "📦", nome: "Essenciais",    apps: 12 },
                        { id: "internet",      icone: "🌐", nome: "Internet",      apps: 8 },
                        { id: "estudo",        icone: "📚", nome: "Estudo&Office", apps: 10 },
                        { id: "programacao",   icone: "💻", nome: "Programação",   apps: 15 },
                        { id: "jogos",         icone: "🎮", nome: "Jogos",         apps: 20 },
                        { id: "windows",       icone: "🪟", nome: "Windows",       apps: 6 },
                        { id: "seguranca",     icone: "🛡", nome: "Segurança/Lab", apps: 7 },
                        { id: "sistema",       icone: "⚙",  nome: "Sistema",       apps: 9 }
                    ]
                    delegate: Rectangle {
                        width: listaCategorias.width
                        height: 48
                        color: listaCategorias.currentIndex === index ? "#3E8EF7" : "transparent"
                        radius: listaCategorias.currentIndex === index ? 8 : 0
                        border.color: listaCategorias.currentIndex === index ? "#45C8F5" : "transparent"
                        border.width: 2

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                text: modelo.icone
                                font.pointSize: 16
                                color: listaCategorias.currentIndex === index ? "#FFFFFF" : "#94A3B8"
                            }

                            ColumnLayout {
                                spacing: 1
                                Text {
                                    text: modelo.nome
                                    font.pointSize: 13
                                    color: listaCategorias.currentIndex === index ? "#FFFFFF" : "#CBD5E1"
                                    elide: Text.ElideRight
                                    width: 120
                                }
                                Text {
                                    text: modelo.apps + " apps"
                                    font.pointSize: 10
                                    color: "#64748B"
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: modelo.apps
                                font.pointSize: 11
                                color: "#3E8EF7"
                                font.bold: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                listaCategorias.currentIndex = index
                                root.abaAtiva = modelo.id
                                pilhaCategorias.currentIndex = index
                            }
                        }
                    }
                    currentIndex: 0
                }
            }
        }

        Separator { }

        // ==================== ÁREA PRINCIPAL: APPS + FILA ====================
        Column {
            id: areaPrincipal
            width: parent.width - 241
            height: parent.height

            // Tabs: Categorias | Garrafas | Updates
            TabBar {
                id: tabs
                width: parent.width
                currentIndex: 0
                model: ["Categorias", "Garrafas", "Updates"]
                onCurrentIndexChanged: {
                    if (index === 0) root.abaAtiva = "categorias"
                    else if (index === 1) root.abaAtiva = "garrafas"
                    else root.abaAtiva = "updates"
                }
                TabButton {
                    text: "Novos"
                    font.pointSize: 11
                    onClicked: console.log("Novos lançamentos")
                }
            }

            // Stack de abas
            Stack {
                id: pilhaAbas
                width: parent.width
                height: parent.height - tabs.height

                // --- Aba: Categorias (8 categorias com apps) ---
                Rectangle {
                    id: paginaCategorias
                    color: "#F7F9FC"
                    visible: root.abaAtiva === "categorias"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        // Título da categoria atual
                        Text {
                            text: listaCategorias.currentItem ? listaCategorias.currentItem.nome : "Essenciais"
                            font.pointSize: 18
                            font.bold: true
                            color: "#0E1116"
                        }

                        // Grid de apps (6 colunas)
                        GridView {
                            id: gridApps
                            width: parent.width
                            height: parent.height
                            cellWidth: 200
                            cellHeight: 260
                            spacing: 16
                            model: [
                                { nome: "OnlyOffice", icone: "📄", categoria: "Estudo&Office", tier: "prime", desc: "Suíte de escritório completa", instalado: false },
                                { nome: "WhatsApp PWA", icone: "💬", categoria: "Internet", tier: "core", desc: "Mensageiro multiplataforma", instalado: false },
                                { nome: "Spotify", icone: "🎵", categoria: "Internet", tier: "prime", desc: "Música e podcasts", instalado: false },
                                { nome: "Discord", icone: "🎮", categoria: "Internet", tier: "core", desc: "Chat para comunidades", instalado: false },
                                { nome: "Zoom", icone: "📹", categoria: "Internet", tier: "prime", desc: "Videoconferência", instalado: false },
                                { nome: "Steam", icone: "🎮", categoria: "Jogos", tier: "prime", desc: "Plataforma de jogos", instalado: false },
                                { nome: "VS Code", icone: "💻", categoria: "Programação", tier: "prime", desc: "Editor de código", instalado: false },
                                { nome: "Firefox ESR", icone: "🦊", categoria: "Internet", tier: "core", desc: "Navegador da web", instalado: true },
                                { nome: "VLC", icone: "🎬", categoria: "Internet", tier: "lite", desc: "Reprodutor de mídia", instalado: true },
                                { nome: "GIMP", icone: "🎨", categoria: "Estudo&Office", tier: "core", desc: "Edição de imagens", instalado: false },
                                { nome: "Blender", icone: "🧊", categoria: "Estudo&Office", tier: "prime", desc: "Modelagem 3D", instalado: false },
                                { nome: "ClamAV", icone: "🛡", categoria: "Segurança/Lab", tier: "core", desc: "Antivírus", instalado: false },
                                { nome: "Wine", icone: "🪟", categoria: "Windows", tier: "core", desc: "Compatibilidade Windows", instalado: false },
                                { nome: "Brave", icone: "🦁", categoria: "Internet", tier: "prime", desc: "Navegador focado em privacidade", instalado: false },
                                { nome: "Teams PWA", icone: "💬", categoria: "Internet", tier: "core", desc: "Colaboração Microsoft", instalado: false }
                            ]
                            delegate: Rectangle {
                                width: 200
                                height: 260
                                color: "#151b22"
                                radius: 12
                                border.color: "#1e293b"
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    // Ícone do app
                                    Rectangle {
                                        width: 64
                                        height: 64
                                        color: "#3E8EF7"
                                        radius: 16
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelo.icone
                                            font.pointSize: 28
                                        }
                                    }

                                    Text {
                                        text: modelo.nome
                                        font.pointSize: 14
                                        font.bold: true
                                        color: "#F7F9FC"
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                        width: 176
                                    }

                                    Text {
                                        text: modelo.categoria
                                        font.pointSize: 10
                                        color: "#94A3B8"
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    // Badge de tier
                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 4
                                        Repeater {
                                            model: 3
                                            delegate: Rectangle {
                                                width: 10
                                                height: 10
                                                radius: 5
                                                color: (index === 0 && modelo.tier === "prime") ||
                                                         (index === 1 && modelo.tier === "core") ||
                                                         (index === 2 && modelo.tier === "lite")
                                                    ? "#3E8EF7" : "#334155"
                                            }
                                        }
                                    }

                                    // Badge instalado
                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 4
                                        Rectangle {
                                            width: 64
                                            height: 20
                                            radius: 10
                                            color: modelo.instalado ? "#4ADE80" : "#334155"
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelo.instalado ? "Instalado" : "Instalar"
                                                font.pointSize: 9
                                                color: modelo.instalado ? "#0E1116" : "#CBD5E1"
                                            }
                                        }
                                    }

                                    // Botão instalar/remover
                                    Button {
                                        Layout.fillWidth: true
                                        text: modelo.instalado ? "Remover" : "Instalar"
                                        font.pointSize: 11
                                        background: Rectangle {
                                            color: modelo.instalado ? "#C42B1C" : "#3E8EF7"
                                            radius: 6
                                        }
                                        onClicked: {
                                            if (modelo.instalado) {
                                                console.log("Remover flatpak: " + modelo.nome)
                                            } else {
                                                console.log("Instalar flatpak: " + modelo.nome)
                                                // Adicionar à fila
                                                filaInstalacao.push(modelo.nome)
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: console.log("Selecionar: " + modelo.nome)
                                }
                            }
                        }
                    }
                }

                // --- Aba: Garrafas (Windows bottles) ---
                Rectangle {
                    id: paginaGarrafas
                    color: "#F7F9FC"
                    visible: root.abaAtiva === "garrafas"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        Text {
                            text: "Garrafas Windows (bottles)"
                            font.pointSize: 18
                            font.bold: true
                            color: "#0E1116"
                        }

                        Text {
                            text: "Garrafas isoladas com bwrap para executar aplicativos Windows via Wine."
                            font.pointSize: 13
                            color: "#64748B"
                        }

                        ListView {
                            id: listaGarrafas
                            width: parent.width
                            height: 300
                            spacing: 8
                            model: [
                                { nome: "Office 2019", versao: "16.0", status: "ativo", apps: 3 },
                                { nome: "Photoshop CS6", versao: "13.0", status: "ativo", apps: 1 },
                                { nome: "Steam", versao: "última", status: "ativo", apps: 15 },
                                { nome: "VLC para Windows", versao: "3.0", status: "inativo", apps: 1 }
                            ]
                            delegate: Rectangle {
                                width: listaGarrafas.width
                                height: 56
                                color: "#151b22"
                                radius: 8
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 12
                                    Rectangle {
                                        width: 32
                                        height: 32
                                        color: "#9D7BFA"
                                        radius: 8
                                        Text {
                                            anchors.centerIn: parent
                                            text: "🪟"
                                            color: "#FFFFFF"
                                            font.pointSize: 16
                                        }
                                    }
                                    ColumnLayout {
                                        spacing: 2
                                        Text { text: modelo.nome; font.pointSize: 13; color: "#CBD5E1" }
                                        Text { text: "v" + modelo.versao + " • " + modelo.apps + " apps"; font.pointSize: 10; color: "#94A3B8" }
                                    }
                                    Item { Layout.fillWidth: true }
                                    Switch { checked: modelo.status === "ativo" }
                                }
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "Nova Garrafa"
                            font.pointSize: 12
                            background: Rectangle { color: "#3E8EF7"; radius: 6 }
                            onClicked: console.log("Criar nova garrafa Windows")
                        }
                    }
                }

                // --- Aba: Updates (sistema/apps separados) ---
                Rectangle {
                    id: paginaUpdates
                    color: "#F7F9FC"
                    visible: root.abaAtiva === "updates"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        Text {
                            text: "Atualizações"
                            font.pointSize: 18
                            font.bold: true
                            color: "#0E1116"
                        }

                        // Atualizações do sistema
                        Card {
                            Layout.fillWidth: true
                            Column {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12

                                Text {
                                    text: "Sistema (A/B rollback)"
                                    font.pointSize: 16
                                    font.bold: true
                                    color: "#0E1116"
                                }

                                Row {
                                    spacing: 16
                                    Text { text: "Versão atual:"; font.pointSize: 13; color: "#64748B" }
                                    Text { text: "CalVer 2026.11 slot A"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                                    Item { Layout.fillWidth: true }
                                }
                                Row {
                                    spacing: 16
                                    Text { text: "Slot inativo:"; font.pointSize: 13; color: "#64748B" }
                                    Text { text: "slot B (vazio)"; font.pointSize: 13; color: "#94A3B8" }
                                    Item { Layout.fillWidth: true }
                                }
                                Row {
                                    spacing: 16
                                    Text { text: "Última verificação:"; font.pointSize: 13; color: "#64748B" }
                                    Text { text: "nunca"; font.pointSize: 13; color: "#C42B1C" }
                                    Item { Layout.fillWidth: true }
                                }

                                Button {
                                    text: "Verificar atualizações do sistema"
                                    font.pointSize: 12
                                    background: Rectangle { color: "#3E8EF7"; radius: 6 }
                                    onClicked: console.log("Verificar atualizações do sistema")
                                }
                            }
                        }

                        // Atualizações de apps
                        Card {
                            Layout.fillWidth: true
                            Column {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12

                                Text {
                                    text: "Aplicativos (Flatpak)"
                                    font.pointSize: 16
                                    font.bold: true
                                    color: "#0E1116"
                                }

                                ListView {
                                    id: listaAppsUpdates
                                    width: parent.width
                                    height: 200
                                    spacing: 4
                                    model: [
                                        { nome: "Firefox ESR", versao: "115.0", atualizacao: "115.1", tamanho: "45 MB" },
                                        { nome: "VS Code", versao: "1.85", atualizacao: "1.86", tamanho: "85 MB" },
                                        { nome: "Spotify", versao: "1.2.3", atualizacao: "1.2.4", tamanho: "60 MB" },
                                        { nome: "Steam", versao: "latest", atualizacao: "latest", tamanho: "120 MB" }
                                    ]
                                    delegate: Rectangle {
                                        width: listaAppsUpdates.width
                                        height: 40
                                        color: "#151b22"
                                        radius: 8
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 12
                                            Text {
                                                text: modelo.nome
                                                font.pointSize: 13
                                                color: "#CBD5E1"
                                            }
                                            Text {
                                                text: modelo.versao + " → " + modelo.atualizacao
                                                font.pointSize: 11
                                                color: "#94A3B8"
                                            }
                                            Text {
                                                text: modelo.tamanho
                                                font.pointSize: 11
                                                color: "#9D7BFA"
                                            }
                                            Item { Layout.fillWidth: true }
                                            Button {
                                                text: "Atualizar"
                                                font.pointSize: 10
                                                background: Rectangle { color: "#4ADE80"; radius: 4 }
                                                onClicked: console.log("Atualizar: " + modelo.nome)
                                            }
                                        }
                                    }
                                }

                                Button {
                                    text: "Atualizar todos os aplicativos"
                                    font.pointSize: 12
                                    background: Rectangle { color: "#3E8EF7"; radius: 6 }
                                    onClicked: console.log("Atualizar todos os apps")
                                }
                            }
                        }
                    }
                }
            }
        }

        // ==================== FILA DE INSTALAÇÃO (lateral direita) ====================
        Rectangle {
            id: painelFila
            width: 300
            color: "#101418"
            border.color: "#1e293b"
            border.width: 1
            layer.enabled: true
            layer.effect: ShaderEffect {
                property variant source: shaderSource
                property real intensity: 0.6
                property color tint: "#101418"
                fragmentShader: ""
                Rectangle { id: shaderSource; width: painelFila.width; height: painelFila.height; color: "transparent" }
            }

            Column {
                anchors.fill: parent
                spacing: 0

                // Cabeçalho da fila
                Rectangle {
                    width: parent.width
                    height: 48
                    color: "#0a0c0f"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Rectangle {
                            width: 24
                            height: 24
                            color: "#F65A8E"
                            radius: 12
                            Text {
                                anchors.centerIn: parent
                                text: "⬇"
                                color: "#FFFFFF"
                                font.pointSize: 14
                            }
                        }

                        Text {
                            text: "Fila de Instalação"
                            font.pointSize: 14
                            font.bold: true
                            color: "#F7F9FC"
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: filaInstalacao.length
                            font.pointSize: 14
                            font.bold: true
                            color: "#F65A8E"
                        }
                    }
                }

                // Lista da fila
                ListView {
                    id: listaFila
                    width: parent.width
                    height: parent.height - 48
                    spacing: 6
                    model: filaInstalacao
                    delegate: Rectangle {
                        width: listaFila.width
                        height: 56
                        color: "#151b22"
                        radius: 8
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10
                            Rectangle {
                                width: 32
                                height: 32
                                color: "#3E8EF7"
                                radius: 8
                                Text {
                                    anchors.centerIn: parent
                                    text: index + 1
                                    color: "#FFFFFF"
                                    font.pointSize: 14
                                    font.bold: true
                                }
                            }
                            ColumnLayout {
                                spacing: 2
                                Text {
                                    text: modelo
                                    font.pointSize: 13
                                    color: "#CBD5E1"
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: "Baixando..."
                                    font.pointSize: 10
                                    color: "#94A3B8"
                                }
                            }
                            Item { Layout.fillWidth: true }
                            Row {
                                spacing: 4
                                ProgressBar {
                                    width: 80
                                    value: 45
                                }
                                Button {
                                    text: "✕"
                                    font.pointSize: 10
                        background: Rectangle { color: "#C42B1C"; radius: 4 }
                                    onClicked: filaInstalacao.splice(index, 1)
                                }
                            }
                        }
                    }
                }

                // Botão limpar fila
                Button {
                    Layout.fillWidth: true
                    text: "Limpar fila"
                    font.pointSize: 11
                    background: Rectangle { color: "#334155"; radius: 6 }
                    onClicked: filaInstalacao = []
                }
            }
        }
    }
}

// ==================== COMPONENTES AUXILIARES ====================

// Componente Card para uso nas seções
QtObject {
    id: cardComponent
}

// Fila de instalação (estado compartilhado)
QtObject {
    id: filaEstado
    property var itens: []
}

// Array da fila de instalação (acessível pelo QML)
var filaInstalacao = []
