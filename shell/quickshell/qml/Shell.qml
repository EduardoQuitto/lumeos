import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Shell — Shell principal Qt6/QML
// Conforme design/expectative/expectativa_do_projeto.jpg
// Barra pílula inferior (48px, margem 8px), wallpaper Aurora Peaks,
// janela Lume Files com vidro/blur, sidebar, grade, tray direita.

ApplicationWindow {
    id: root
    visible: true
    width: Screen.width
    height: Screen.height

    // ==================== WALLPAPER (Aurora Peaks) ====================
    // Gradiente fluido conforme design/wallpapers-gen/aurora-peaks/
    Rectangle {
        id: wallpaper
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#45C8F5" }
            GradientStop { position: 0.25; color: "#F65A8E" }
            GradientStop { position: 0.5; color: "#FF8A5C" }
            GradientStop { position: 0.75; color: "#9D7BFA" }
            GradientStop { position: 1.0; color: "#3E8EF7" }
        }
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real intensity: 0.3
            fragmentShader: ""
            Rectangle { id: shaderSource; width: wallpaper.width; height: wallpaper.height; color: "transparent" }
        }
    }

    // Camada escurecida sutil para contraste
    Rectangle {
        anchors.fill: parent
        color: "#0E1116"
        opacity: 0.15
    }

    // ==================== BARRA PÍLULA INFERIOR (48px, margem 8px) ====================
    Rectangle {
        id: barraPilula
        width: Screen.width - 16
        height: 48
        x: 8
        y: Screen.height - 56
        radius: 24
        color: "#101418"
        border.color: "#1e293b"
        border.width: 1
        z: 100

        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real blur: 8
            fragmentShader: ""
            Rectangle { id: shaderSource; width: barraPilula.width; height: barraPilula.height; color: "transparent" }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            // Botão Lume (logo)
            Button {
                id: btnLume
                width: 32
                height: 32
                background: Rectangle { color: "#3E8EF7"; radius: 16 }
                onClicked: menuIniciar.open()
                Image {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: "../../../../design/icons/lume.svg"
                }
            }

            // Busca (lupa)
            Button {
                width: 32
                height: 32
                background: Rectangle { color: "transparent"; radius: 16 }
                onClicked: console.log("Busca")
                Image {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: "../../../../design/icons/search.svg"
                }
            }

            // Files (pasta amarela)
            Button {
                width: 32
                height: 32
                background: Rectangle { color: "#F65A8E"; radius: 16 }
                onClicked: janelaFiles.open()
                Image {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: "../../../../design/icons/files.svg"
                }
            }

            // Navegador (globo/estrela)
            Button {
                width: 32
                height: 32
                background: Rectangle { color: "#45C8F5"; radius: 16 }
                onClicked: console.log("Navegador")
                Image {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: "../../../../design/icons/browser.svg"
                }
            }

            // Settings (engrenagem)
            Button {
                width: 32
                height: 32
                background: Rectangle { color: "transparent"; radius: 16 }
                onClicked: console.log("Settings")
                Image {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: "../../../../design/icons/settings.svg"
                }
            }

            // App Store (A azul)
            Button {
                width: 32
                height: 32
                background: Rectangle { color: "#9D7BFA"; radius: 16 }
                onClicked: console.log("App Store")
                Image {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    source: "../../../../design/icons/appstore.svg"
                }
            }

            Item { Layout.fillWidth: true }

            // ==================== TRAY (à direita) ====================
            Row {
                spacing: 12

                // Wi-Fi
                Button {
                    width: 32
                    height: 32
                    background: Rectangle { color: "transparent"; radius: 16 }
                    onClicked: painelRedes.open()
                    Image {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        source: "../../../../design/icons/wifi.svg"
                    }
                }

                // Som
                Button {
                    width: 32
                    height: 32
                    background: Rectangle { color: "transparent"; radius: 16 }
                    onClicked: quickSettings.open()
                    Image {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        source: "../../../../design/icons/volume.svg"
                    }
                }

                // Bateria
                Button {
                    width: 32
                    height: 32
                    background: Rectangle { color: "transparent"; radius: 16 }
                    Image {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        source: "../../../../design/icons/battery.svg"
                    }
                }

                // Relógio + Data (2 linhas por locale)
                Column {
                    spacing: 0
                    Text {
                        id: txtHora
                        text: Qt.formatDateTime(new Date(), "h:mm AP")
                        font.pointSize: 13
                        font.bold: true
                        color: "#F7F9FC"
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        id: txtData
                        text: Qt.formatDateTime(new Date(), "MM/dd/yyyy")
                        font.pointSize: 10
                        color: "#94A3B8"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Chevron overflow
                Button {
                    width: 32
                    height: 32
                    background: Rectangle { color: "transparent"; radius: 16 }
                    Image {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: "../../../../design/icons/settings.svg"
                    }
                }
            }
        }
    }

    // Relógio atualizado a cada segundo
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            txtHora.text = Qt.formatDateTime(new Date(), "h:mm AP")
            txtData.text = Qt.formatDateTime(new Date(), "MM/dd/yyyy")
        }
    }

    // ==================== MENU INICIAR (640x560) ====================
    Popup {
        id: menuIniciar
        width: 640
        height: 560
        x: (Screen.width - width) / 2
        y: (Screen.height - height) / 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Rectangle {
            anchors.fill: parent
            color: "#101418"
            radius: 16
            border.color: "#1e293b"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16

                // Busca no topo
                TextField {
                    id: campoBusca
                    Layout.fillWidth: true
                    placeholderText: "Buscar apps, arquivos, configs..."
                    font.pointSize: 14
                    color: "#F7F9FC"
                    background: Rectangle { color: "#0E1116"; radius: 8 }
                }

                // Grid 6x3 fixados
                GridLayout {
                    id: gridApps
                    columns: 6
                    rows: 3
                    Layout.fillWidth: true
                    spacing: 12
                    Repeater {
                        model: 18
                        delegate: Rectangle {
                            width: 64
                            height: 64
                            color: "#1e293b"
                            radius: 12
                            Image {
                                anchors.centerIn: parent
                                width: 32
                                height: 32
                                source: "../../../../design/icons/files.svg"
                            }
                        }
                    }
                }

                // Rodapé: usuário + energia
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    Text {
                        text: "Usuário"
                        color: "#CBD5E1"
                        font.pointSize: 12
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: "Desligar"
                        font.pointSize: 12
                        color: "#C42B1C"
                        background: Rectangle { color: "transparent"; radius: 8 }
                    }
                }
            }
        }
    }

    // ==================== JANELA LUME FILES (conforme expectativa) ====================
    Popup {
        id: janelaFiles
        width: 800
        height: 500
        x: (Screen.width - width) / 2
        y: (Screen.height - height) / 2
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape

        // Sombra 2 camadas
        Rectangle {
            id: sombraExterna
            anchors.fill: parent
            anchors.margins: -12
            color: "#000000"
            radius: 16
            opacity: 0.3
            layer.enabled: true
            z: -1
        }
        Rectangle {
            id: sombraInterna
            anchors.fill: parent
            anchors.margins: -6
            color: "#000000"
            radius: 16
            opacity: 0.15
            layer.enabled: true
            z: -1
        }

        Rectangle {
            id: container
            anchors.fill: parent
            radius: 12
            clip: true
            border.color: "#1e293b"
            border.width: 1
            color: "#101418"

            // Efeito vidro (blur simulado)
            layer.enabled: true
            layer.effect: ShaderEffect {
                property variant source: shaderSource
                property real blur: 4
                fragmentShader: ""
                Rectangle { id: shaderSource2; width: container.width; height: container.height; color: "transparent" }
            }

            // Titlebar (40px)
            Rectangle {
                id: titlebar
                width: parent.width
                height: 40
                color: "#151b22"
                radius: 12
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    // Título
                    Row {
                        spacing: 8
                        Image {
                            width: 24
                            height: 24
                            source: "../../../../design/icons/lume.svg"
                        }
                        Text {
                            text: "Lume Files"
                            font.pointSize: 13
                            color: "#CBD5E1"
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Controles à direita
                    Row {
                        spacing: 6

                        Button {
                            width: 32
                            height: 32
                            text: "−"
                            font.pointSize: 16
                            color: "#CBD5E1"
                            background: Rectangle { color: "transparent"; radius: 16 }
                            hoverEnabled: true
                            onEntered: background.color = "#334155"
                            onExited: background.color = "transparent"
                        }

                        Button {
                            width: 32
                            height: 32
                            text: "□"
                            font.pointSize: 14
                            color: "#CBD5E1"
                            background: Rectangle { color: "transparent"; radius: 16 }
                            hoverEnabled: true
                            onEntered: background.color = "#334155"
                            onExited: background.color = "transparent"
                        }

                        Button {
                            id: btnFechar
                            width: 32
                            height: 32
                            text: "×"
                            font.pointSize: 16
                            color: "#C42B1C"
                            background: Rectangle { color: "transparent"; radius: 16 }
                            hoverEnabled: true
                            onEntered: background.color = "#2E1A1A"
                            onExited: background.color = "transparent"
                            onClicked: janelaFiles.close()
                        }
                    }
                }
            }

            // Conteúdo da janela (abaixo da titlebar)
            Rectangle {
                id: conteudo
                y: 40
                width: parent.width
                height: parent.height - 40
                color: "#0E1116"

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // ==================== SIDEBAR ESQUERDA ====================
                    Rectangle {
                        id: sidebar
                        width: 200
                        color: "#0E1116"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            Text {
                                text: "Home"
                                font.pointSize: 13
                                color: "#F7F9FC"
                                font.bold: true
                                background: Rectangle { color: "#334155"; radius: 6 }
                                padding: 8
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "Downloads"
                                font.pointSize: 13
                                color: "#CBD5E1"
                                background: Rectangle { color: "transparent"; radius: 6 }
                                padding: 8
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "Pictures"
                                font.pointSize: 13
                                color: "#CBD5E1"
                                background: Rectangle { color: "transparent"; radius: 6 }
                                padding: 8
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "Documents"
                                font.pointSize: 13
                                color: "#CBD5E1"
                                background: Rectangle { color: "transparent"; radius: 6 }
                                padding: 8
                                Layout.fillWidth: true
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }

                    // ==================== GRADE (Projects/Music/Assets) ====================
                    Rectangle {
                        id: areaGrade
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#0E1116"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            GridLayout {
                                columns: 3
                                Layout.fillWidth: true
                                spacing: 24

                                Repeater {
                                    model: 3
                                    delegate: Column {
                                        spacing: 8
                                        alignment: Qt.AlignHCenter

                                        Rectangle {
                                            width: 80
                                            height: 80
                                            color: "#151b22"
                                            radius: 12
                                            border.color: "#1e293b"
                                            border.width: 1

                                            Row {
                                                anchors.centerIn: parent
                                                Image {
                                                    width: 24
                                                    height: 24
                                                    source: index === 0 ? "../../../../design/icons/files.svg" : index === 1 ? "../../../../design/icons/volume.svg" : "../../../../design/icons/appstore.svg"
                                                }
                                            }
                                        }

                                        Text {
                                            text: index === 0 ? "Projects" : index === 1 ? "Music" : "Assets"
                                            font.pointSize: 12
                                            color: "#CBD5E1"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }
                }
            }
        }
    }

    // ==================== PAINEL REDES ====================
    Popup {
        id: painelRedes
        width: 360
        height: 400
        x: Screen.width - width - 8
        y: 64
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Rectangle {
            anchors.fill: parent
            color: "#101418"
            radius: 16
            border.color: "#1e293b"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                Text {
                    text: "Redes"
                    font.pointSize: 18
                    font.bold: true
                    color: "#F7F9FC"
                }
                ListView {
                    id: listaRedes
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: 4
                    delegate: Rectangle {
                        width: listaRedes.width
                        height: 48
                        color: "#0E1116"
                        border.color: "#1e293b"
                        border.width: 1
                        radius: 8
                        Row {
                            anchors.centerIn: parent
                            spacing: 12
                            Text { text: "◌"; color: "#94A3B8" }
                            Text { text: "Rede " + (index + 1); color: "#CBD5E1" }
                            Item { width: 40 }
                            Text { text: "●●●●"; color: "#4ADE80" }
                        }
                    }
                }
            }
        }
    }

    // ==================== QUICK SETTINGS ====================
    Popup {
        id: quickSettings
        width: 380
        height: 420
        x: Screen.width - width - 8
        y: 64
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Rectangle {
            anchors.fill: parent
            color: "#101418"
            radius: 16
            border.color: "#1e293b"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                Text {
                    text: "Configurações Rápidas"
                    font.pointSize: 18
                    font.bold: true
                    color: "#F7F9FC"
                }
                Row {
                    spacing: 12
                    Button { text: "Wi-Fi"; width: 80; height: 32; color: "#F7F9FC"; background: Rectangle { color: "#334155"; radius: 6 } }
                    Button { text: "Bluetooth"; width: 80; height: 32; color: "#F7F9FC"; background: Rectangle { color: "#334155"; radius: 6 } }
                }
                Slider {
                    Layout.fillWidth: true
                    value: 50
                }
                Text { text: "Volume"; color: "#94A3B8"; font.pointSize: 11 }
            }
        }
    }

    // ==================// ATALHOS DE TECLADO ====================
    Keys.onPressed: {
        if (event.key === Qt.Key_Super && event.modifiers === Qt.NoModifier) {
            menuIniciar.open()
            event.accepted = true
        } else if (event.key === Qt.Key_E && event.modifiers === Qt.SuperModifier) {
            console.log("Abrir Files")
            event.accepted = true
        } else if (event.key === Qt.Key_I && event.modifiers === Qt.SuperModifier) {
            console.log("Abrir Settings")
            event.accepted = true
        } else if (event.key === Qt.Key_L && event.modifiers === Qt.SuperModifier) {
            console.log("Lock")
            event.accepted = true
        } else if (event.key === Qt.Key_D && event.modifiers === Qt.SuperModifier) {
            console.log("Desktop")
            event.accepted = true
        } else if (event.key === Qt.Key_Tab && event.modifiers === Qt.SuperModifier) {
            console.log("Overview")
            event.accepted = true
        } else if (event.key === Qt.Key_T && event.modifiers === (Qt.ControlModifier | Qt.AltModifier)) {
            console.log("Terminal")
            event.accepted = true
        }
    }
}
