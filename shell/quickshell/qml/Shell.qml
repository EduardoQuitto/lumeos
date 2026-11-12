import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    visible: true
    width: Screen.width
    height: Screen.height
    color: "#0E1116"

    // Barra pílula (48px, margem 8px)
    Rectangle {
        id: barraPilula
        width: Screen.width - 16
        height: 48
        x: 8
        y: 8
        radius: 24
        color: "#101418"
        border.color: "#1e293b"
        border.width: 1
        z: 100

        // Efeito vidro (blur simulado com gradiente sutil)
        Layer {
            effect: ShaderEffect {
                property variant source: shaderSource
                property real intensity: 0.6
                property color tint: "#101418"
                fragmentShader: ""
                Rectangle {
                    id: shaderSource
                    width: barraPilula.width
                    height: barraPilula.height
                    color: "transparent"
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            // Botão Iniciar (Super)
            Button {
                id: btnIniciar
                width: 32
                height: 32
                text: "L"
                font.pointSize: 14
                font.bold: true
                color: "#3E8EF7"
                background: Rectangle { color: "transparent"; radius: 16 }
                onClicked: menuIniciar.open()
            }

            // Ícones de app fixos (Super+E files, Super+I settings, etc.)
            Row {
                id: rowApps
                spacing: 8
                // Ícones serão preenchidos dinamicamente
                Button {
                    width: 28
                    height: 28
                    text: "F"
                    color: "#CBD5E1"
                    background: Rectangle { color: "transparent"; radius: 14 }
                    hoverEnabled: true
                    onEntered: background.color = "#334155"
                    onExited: background.color = "transparent"
                }
            }

            Item { Layout.fillWidth: true }

            // Tray: Wi-Fi, volume/bateria, relógio
            Row {
                id: rowTray
                spacing: 12

                // Wi-Fi
                Button {
                    width: 28
                    height: 28
                    text: "◌"
                    color: "#94A3B8"
                    background: Rectangle { color: "transparent"; radius: 14 }
                    onClicked: painelRedes.open()
                }

                // Cluster volume/bateria
                Button {
                    width: 28
                    height: 28
                    text: "♪"
                    color: "#94A3B8"
                    background: Rectangle { color: "transparent"; radius: 14 }
                    onClicked: quickSettings.open()
                }

                // Bateria (só se existir)
                Button {
                    width: 28
                    height: 28
                    text: "●"
                    color: "#4ADE80"
                    background: Rectangle { color: "transparent"; radius: 14 }
                    visible: bateriaExiste
                }

                // Relógio (2 linhas por locale)
                Column {
                    id: colRelogio
                    spacing: 0
                    Text {
                        id: txtHora
                        text: Qt.formatDateTime(new Date(), "HH:mm")
                        font.pointSize: 16
                        font.bold: true
                        color: "#F7F9FC"
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        id: txtData
                        text: Qt.formatDateTime(new Date(), "dd/MM")
                        font.pointSize: 11
                        color: "#94A3B8"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Chevron overflow
                Button {
                    width: 28
                    height: 28
                    text: "..."
                    color: "#94A3B8"
                    background: Rectangle { color: "transparent"; radius: 14 }
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
            txtHora.text = Qt.formatDateTime(new Date(), "HH:mm")
            txtData.text = Qt.formatDateTime(new Date(), "dd/MM")
        }
    }

    // Menu Iniciar (640x560)
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

                // Grid 6x3 fixados + recentes
                GridLayout {
                    id: gridApps
                    columns: 6
                    rows: 3
                    Layout.fillWidth: true
                    spacing: 12
                    // Apps preenchidos dinamicamente
                    Repeater {
                        model: 18
                        delegate: Rectangle {
                            width: 64
                            height: 64
                            color: "#1e293b"
                            radius: 12
                            Text {
                                anchors.centerIn: parent
                                text: "A"
                                color: "#94A3B8"
                            }
                        }
                    }
                }

                // Rodapé: usuário + energia
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    Text {
                        text: "Usuario"
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

    // Painel de redes (Wi-Fi → painel redes)
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

    // Quick settings (volume/bateria → quick settings)
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
                    text: "Configuracoes Rapidas"
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

    // Atalhos de teclado
    Keys.onPressed: {
        if (event.key === Qt.Key_Super && event.modifiers === Qt.NoModifier) {
            menuIniciar.open()
            event.accepted = true
        } else if (event.key === Qt.Key_E && event.modifiers === Qt.SuperModifier) {
            // Super+E: files
            console.log("Abrir Files")
            event.accepted = true
        } else if (event.key === Qt.Key_I && event.modifiers === Qt.SuperModifier) {
            // Super+I: settings
            console.log("Abrir Settings")
            event.accepted = true
        } else if (event.key === Qt.Key_L && event.modifiers === Qt.SuperModifier) {
            // Super+L: lock
            console.log("Lock")
            event.accepted = true
        } else if (event.key === Qt.Key_D && event.modifiers === Qt.SuperModifier) {
            // Super+D: desktop
            console.log("Desktop")
            event.accepted = true
        } else if (event.key === Qt.Key_Tab && event.modifiers === Qt.SuperModifier) {
            // Super+Tab: overview
            console.log("Overview")
            event.accepted = true
        } else if (event.key === Qt.Key_T && event.modifiers === (Qt.ControlModifier | Qt.AltModifier)) {
            // Ctrl+Alt+T: terminal
            console.log("Terminal")
            event.accepted = true
        }
    }

    property bool bateriaExiste: true
}
