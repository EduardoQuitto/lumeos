import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Settings — janela principal com navegação esquerda 240px vidro-lite
// Conteúdo papel/tinta (#F7F9FC / #0E1116)
// 8 páginas: sistema, tela, som, rede, bt, personalização, apps, contas
ApplicationWindow {
    id: root
    visible: true
    width: 1100
    height: 750
    title: "Lume Settings"
    color: "#0E1116"

    property string paginaAtual: "sistema"

    // ==================== NAVEGAÇÃO ESQUERDA (240px vidro-lite) ====================
    Rectangle {
        id: navEsquerda
        width: 240
        height: parent.height
        color: "#101418"
        border.color: "#1e293b"
        border.width: 1
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real intensity: 0.6
            property color tint: "#101418"
            fragmentShader: ""
            Rectangle { id: shaderSource; width: navEsquerda.width; height: navEsquerda.height; color: "transparent" }
        }

        Column {
            anchors.fill: parent
            spacing: 0

            // Cabeçalho com logo e nome
            Rectangle {
                width: parent.width
                height: 64
                color: "#0a0c0f"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Rectangle {
                        width: 32
                        height: 32
                        color: "#3E8EF7"
                        radius: 8
                        Text {
                            anchors.centerIn: parent
                            text: "L"
                            color: "#FFFFFF"
                            font.pointSize: 16
                            font.bold: true
                        }
                    }

                    Text {
                        text: "Lume Settings"
                        font.pointSize: 16
                        font.bold: true
                        color: "#F7F9FC"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            // Lista de páginas
            ListView {
                id: listaPaginas
                width: parent.width
                height: parent.height - 64
                spacing: 2
                model: [
                    { id: "sistema",    icone: "💻", nome: "Sistema" },
                    { id: "tela",       icone: "🖥", nome: "Tela" },
                    { id: "som",        icone: "🔊", nome: "Som" },
                    { id: "rede",       icone: "🌐", nome: "Rede" },
                    { id: "bt",         icone: "📶", nome: "Bluetooth" },
                    { id: "personalizacao", icone: "🎨", nome: "Personalização" },
                    { id: "apps",       icone: "📦", nome: "Apps" },
                    { id: "contas",     icone: "👤", nome: "Contas" }
                ]
                delegate: Rectangle {
                    width: listaPaginas.width
                    height: 48
                    color: listaPaginas.currentIndex === index ? "#3E8EF7" : "transparent"
                    radius: listaPaginas.currentIndex === index ? 8 : 0
                    border.color: listaPaginas.currentIndex === index ? "#45C8F5" : "transparent"
                    border.width: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            text: modelo.icone
                            font.pointSize: 16
                            color: listaPaginas.currentIndex === index ? "#FFFFFF" : "#94A3B8"
                        }

                        Text {
                            text: modelo.nome
                            font.pointSize: 13
                            color: listaPaginas.currentIndex === index ? "#FFFFFF" : "#CBD5E1"
                        }

                        Item { Layout.fillWidth: true }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.paginaAtual = modelo.id
                            listaPaginas.currentIndex = index
                        }
                    }
                }
            }
        }
    }

    // ==================== CONTEÚDO (papel/tinta) ====================
    Rectangle {
        id: conteudo
        x: navEsquerda.width
        width: parent.width - navEsquerda.width
        height: parent.height
        color: "#F7F9FC"

        // Título da página atual
        Text {
            id: tituloPagina
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 24
            anchors.leftMargin: 24
            text: paginaAtual === "sistema" ? "Sistema" :
                  paginaAtual === "tela" ? "Tela" :
                  paginaAtual === "som" ? "Som" :
                  paginaAtual === "rede" ? "Rede" :
                  paginaAtual === "bt" ? "Bluetooth" :
                  paginaAtual === "personalizacao" ? "Personalização" :
                  paginaAtual === "apps" ? "Apps" :
                  paginaAtual === "contas" ? "Contas" : "Sistema"
            font.pointSize: 24
            font.bold: true
            color: "#0E1116"
        }

        // Área de conteúdo da página
        Stack {
            id: paginas
            anchors.top: tituloPagina.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            anchors.bottomMargin: 24

            // --- Página: Sistema ---
            Rectangle {
                id: paginaSistema
                color: "#F7F9FC"
                visible: root.paginaAtual === "sistema"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Sobre"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Versão:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "CalVer 2026.11"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Edição:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Prime (amd64)"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Canal:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "stable"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Tier:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Prime"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                                Item { Layout.fillWidth: true }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#e2e8f0"
                                Layout.topMargin: 8
                                Layout.bottomMargin: 8
                            }

                            Text {
                                text: "Hardware"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }
                            Row {
                                spacing: 16
                                Text { text: "CPU:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Intel i5-14400"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "RAM:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "32 GB"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "GPU:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Intel UHD Graphics 730"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }

            // --- Página: Tela ---
            Rectangle {
                id: paginaTela
                color: "#F7F9FC"
                visible: root.paginaAtual === "tela"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Exibição"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Resolução:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "1920×1080 @ 60Hz"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Escala:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "100%"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Orientação:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Paisagem"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Tema"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 12
                                RadioButton {
                                    text: "Claro"
                                    font.pointSize: 13
                                    checked: true
                                    onCheckedChanged: root.paginaAtual = root.paginaAtual
                                }
                                RadioButton {
                                    text: "Escuro"
                                    font.pointSize: 13
                                }
                                RadioButton {
                                    text: "Sistema"
                                    font.pointSize: 13
                                }
                                Item { Layout.fillWidth: true }
                            }

                            Row {
                                spacing: 16
                                Text { text: "Cor de acento:"; font.pointSize: 13; color: "#64748B" }
                                Row {
                                    spacing: 8
                                    Repeater {
                                        model: ["#3E8EF7", "#45C8F5", "#9D7BFA", "#F65A8E", "#FF8A5C"]
                                        delegate: Rectangle {
                                            width: 24
                                            height: 24
                                            radius: 12
                                            color: modeloData
                                            border.color: modeloData === "#3E8EF7" ? "#FFFFFF" : "transparent"
                                            border.width: 2
                                        }
                                    }
                                }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }

            // --- Página: Som ---
            Rectangle {
                id: paginaSom
                color: "#F7F9FC"
                visible: root.paginaAtual === "som"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Saída de Áudio"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Dispositivo:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Altifalantes (Internal Audio)"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }

                            Row {
                                Text { text: "Volume:"; font.pointSize: 13; color: "#64748B" }
                                Item { Layout.fillWidth: true }
                                Text { text: "60%"; font.pointSize: 12; color: "#94A3B8" }
                            }
                            Slider {
                                Layout.fillWidth: true
                                value: 60
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Entrada de Áudio"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Dispositivo:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Microfone (Internal Audio)"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }

                            Row {
                                Text { text: "Volume:"; font.pointSize: 13; color: "#64748B" }
                                Item { Layout.fillWidth: true }
                                Text { text: "40%"; font.pointSize: 12; color: "#94A3B8" }
                            }
                            Slider {
                                Layout.fillWidth: true
                                value: 40
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Sons do Sistema"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Notificação:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: true }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Erro:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: true }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Inicialização:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: false }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }

            // --- Página: Rede ---
            Rectangle {
                id: paginaRede
                color: "#F7F9FC"
                visible: root.paginaAtual === "rede"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Wi-Fi"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Wi-Fi:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: true }
                                Item { Layout.fillWidth: true }
                            }

                            Row {
                                spacing: 16
                                Text { text: "Rede:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Lume-Home"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Sinal:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "●●●●○"; font.pointSize: 13; color: "#4ADE80" }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Ethernet"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Ethernet:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: false }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "IP:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Desconectado"; font.pointSize: 13; color: "#94A3B8" }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "WireGuard"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "WireGuard:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: false }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Túnel:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Nenhum ativo"; font.pointSize: 13; color: "#94A3B8" }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }

            // --- Página: Bluetooth ---
            Rectangle {
                id: paginaBt
                color: "#F7F9FC"
                visible: root.paginaAtual === "bt"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Bluetooth"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Bluetooth:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: true }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Visível:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: false }
                                Item { Layout.fillWidth: true }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#e2e8f0"
                                Layout.topMargin: 8
                                Layout.bottomMargin: 8
                            }

                            Text {
                                text: "Dispositivos Emparelhados"
                                font.pointSize: 14
                                font.bold: true
                                color: "#0E1116"
                            }

                            ListView {
                                id: listaBt
                                width: parent.width
                                height: 200
                                spacing: 4
                                model: [
                                    { nome: "Fones Lume", tipo: "fone", conectado: true },
                                    { nome: "Teclado MK", tipo: "teclado", conectado: false },
                                    { nome: "Mouse BT", tipo: "mouse", conectado: false }
                                ]
                                delegate: Rectangle {
                                    width: listaBt.width
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
                                            color: modelo.conectado ? "#4ADE80" : "#64748B"
                                            radius: 8
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelo.tipo === "fone" ? "🎧" : (modelo.tipo === "teclado" ? "⌨" : "🖱")
                                                color: "#FFFFFF"
                                                font.pointSize: 14
                                            }
                                        }
                                        ColumnLayout {
                                            spacing: 2
                                            Text { text: modelo.nome; font.pointSize: 13; color: "#CBD5E1" }
                                            Text { text: modelo.conectado ? "Conectado" : "Não conectado"; font.pointSize: 10; color: "#94A3B8" }
                                        }
                                        Item { Layout.fillWidth: true }
                                        Switch { checked: modelo.conectado }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // --- Página: Personalização ---
            Rectangle {
                id: paginaPersonalizacao
                color: "#F7F9FC"
                visible: root.paginaAtual === "personalizacao"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Wallpaper"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 12
                                Repeater {
                                    model: ["Aurora Peaks", "Crystal Glow", "Pastel Horizon", "Silk Flow", "Solar Tide"]
                                    delegate: Rectangle {
                                        width: 100
                                        height: 60
                                        color: "#1e293b"
                                        radius: 8
                                        border.color: index === 0 ? "#3E8EF7" : "transparent"
                                        border.width: 2
                                        Text {
                                            anchors.centerIn: parent
                                            text: modeloData
                                            font.pointSize: 9
                                            color: "#94A3B8"
                                            wrapMode: Text.Wrap
                                        }
                                    }
                                }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Materiais"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 12
                                Repeater {
                                    model: ["Vidro", "Névoa", "Sólido"]
                                    delegate: RadioButton {
                                        text: modeloData
                                        font.pointSize: 13
                                        checked: index === 0
                                    }
                                }
                                Item { Layout.fillWidth: true }
                            }

                            Row {
                                spacing: 16
                                Text { text: "Tint do vidro:"; font.pointSize: 13; color: "#64748B" }
                                Slider { Layout.fillWidth: true; value: 60 }
                                Text { text: "60%"; font.pointSize: 12; color: "#94A3B8" }
                            }
                        }
                    }
                }
            }

            // --- Página: Apps ---
            Rectangle {
                id: paginaApps
                color: "#F7F9FC"
                visible: root.paginaAtual === "apps"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Aplicativos Instalados"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            ListView {
                                id: listaApps
                                width: parent.width
                                height: 400
                                spacing: 4
                                model: [
                                    { nome: "Lume Files", icone: "📁", categoria: "Sistema" },
                                    { nome: "Lume Settings", icone: "⚙", categoria: "Sistema" },
                                    { nome: "Terminal", icone: "🖥", categoria: "Utilitários" },
                                    { nome: "Store", icone: "🛒", categoria: "Sistema" },
                                    { nome: "Editor", icone: "📝", categoria: "Escritório" },
                                    { nome: "Viewer", icone: "🖼", categoria: "Escritório" },
                                    { nome: "PDF", icone: "📄", categoria: "Escritório" },
                                    { nome: "Calc", icone: "🧮", categoria: "Escritório" },
                                    { nome: "Screenshot", icone: "📷", categoria: "Utilitários" },
                                    { nome: "Welcome", icone: "👋", categoria: "Sistema" }
                                ]
                                delegate: Rectangle {
                                    width: listaApps.width
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
                                            color: "#3E8EF7"
                                            radius: 8
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelo.icone
                                                color: "#FFFFFF"
                                                font.pointSize: 14
                                            }
                                        }
                                        ColumnLayout {
                                            spacing: 2
                                            Text { text: modelo.nome; font.pointSize: 13; color: "#CBD5E1" }
                                            Text { text: modelo.categoria; font.pointSize: 10; color: "#94A3B8" }
                                        }
                                        Item { Layout.fillWidth: true }
                                        Row {
                                            spacing: 4
                                            Button {
                                                text: "Padrão"
                                                font.pointSize: 10
                                                background: Rectangle { color: "#334155"; radius: 4 }
                                            }
                                            Button {
                                                text: "Desinstalar"
                                                font.pointSize: 10
                                                color: "#C42B1C"
                                                background: Rectangle { color: "#2E1A1A"; radius: 4 }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // --- Página: Contas ---
            Rectangle {
                id: paginaContas
                color: "#F7F9FC"
                visible: root.paginaAtual === "contas"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Conta de Usuário"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Rectangle {
                                    width: 80
                                    height: 80
                                    color: "#3E8EF7"
                                    radius: 40
                                    Text {
                                        anchors.centerIn: parent
                                        text: "U"
                                        color: "#FFFFFF"
                                        font.pointSize: 32
                                        font.bold: true
                                    }
                                }
                                Column {
                                    spacing: 4
                                    Text { text: "Usuário Lume"; font.pointSize: 16; font.bold: true; color: "#0E1116" }
                                    Text { text: "usuario@lume-os"; font.pointSize: 13; color: "#64748B" }
                                    Text { text: "Senha: ●●●●●●●●"; font.pointSize: 13; color: "#94A3B8" }
                                }
                                Item { Layout.fillWidth: true }
                                Button {
                                    text: "Alterar senha"
                                    font.pointSize: 12
                                    background: Rectangle { color: "#334155"; radius: 6 }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#e2e8f0"
                                Layout.topMargin: 12
                                Layout.bottomMargin: 12
                            }

                            Row {
                                spacing: 16
                                Text { text: "Login automático:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: false }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Sincronização:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: false }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Outras Contas"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Text {
                                text: "Nenhuma conta adicional configurada."
                                font.pointSize: 13
                                color: "#94A3B8"
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "Adicionar conta"
                                font.pointSize: 12
                                background: Rectangle { color: "#334155"; radius: 6 }
                            }
                        }
                    }
                }
            }
        }
    }
}
