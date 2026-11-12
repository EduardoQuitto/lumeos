import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Janela Lume — decoração CSD QML
// Titlebar 40px, controles à direita, fechar hover #C42B1C,
// Raio 12, sombra 2 camadas, borda interna 1px
Item {
    id: janelaLume
    property string title: "Janela"
    property bool maximized: false
    property bool fullscreen: false
    property bool active: true
    property int largura: 800
    property int altura: 600

    width: largura
    height: altura + 40 // titlebar

    // Sombra 2 camadas
    Rectangle {
        id: sombraExterna
        width: janelaLume.width + 12
        height: janelaLume.height + 12
        x: -6
        y: -6
        color: "#000000"
        radius: 12
        opacity: 0.3
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real blur: 8
            fragmentShader: ""
            Rectangle { id: shaderSource; width: sombraExterna.width; height: sombraExterna.height; color: "transparent" }
        }
        z: -1
    }

    Rectangle {
        id: sombraInterna
        width: janelaLume.width + 6
        height: janelaLume.height + 6
        x: -3
        y: -3
        color: "#000000"
        radius: 12
        opacity: 0.15
        z: -1
    }

    // Container principal com raio e borda interna
    Rectangle {
        id: container
        anchors.fill: parent
        radius: 12
        clip: true
        border.color: "#1e293b"
        border.width: 1
        color: "#101418"

        // Titlebar (40px)
        Rectangle {
            id: titlebar
            width: parent.width
            height: 40
            color: active ? "#151b22" : "#0e1116"
            radius: 12
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                // Ícone + título
                Row {
                    spacing: 8
                    Rectangle {
                        width: 24
                        height: 24
                        color: "#3E8EF7"
                        radius: 6
                        Text {
                            anchors.centerIn: parent
                            text: "L"
                            color: "#FFFFFF"
                            font.pointSize: 12
                            font.bold: true
                        }
                    }
                    Text {
                        text: janelaLume.title
                        font.pointSize: 13
                        color: "#CBD5E1"
                        elide: Text.ElideRight
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                Item { Layout.fillWidth: true }

                // Controles à direita (minimizar, maximizar, fechar)
                Row {
                    spacing: 6

                    Button {
                        id: btnMinimizar
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
                        id: btnMaximizar
                        width: 32
                        height: 32
                        text: maximized ? "❐" : "□"
                        font.pointSize: 14
                        color: "#CBD5E1"
                        background: Rectangle { color: "transparent"; radius: 16 }
                        hoverEnabled: true
                        onEntered: background.color = "#334155"
                        onExited: background.color = "transparent"
                        onClicked: janelaLume.maximized = !janelaLume.maximized
                    }

                    Button {
                        id: btnFechar
                        width: 32
                        height: 32
                        text: "×"
                        font.pointSize: 16
                        color: active ? "#C42B1C" : "#64748B"
                        background: Rectangle { color: "transparent"; radius: 16 }
                        hoverEnabled: true
                        onEntered: background.color = active ? "#2E1A1A" : "transparent"
                        onExited: background.color = "transparent"
                        onClicked: janelaLume.destroy()
                    }
                }
            }
        }

        // Conteúdo da janela (área de conteúdo abaixo da titlebar)
        Rectangle {
            id: conteudo
            y: 40
            width: parent.width
            height: parent.height - 40
            color: "#0E1116"
            radius: { bottomLeft: 12; bottomRight: 12 }
            clip: true

            // Placeholder de conteúdo
            Text {
                anchors.centerIn: parent
                text: janelaLume.title
                font.pointSize: 16
                color: "#94A3B8"
            }
        }
    }

    // Efeito de abrir: scale 0.96 -> 1 mola (conforme PRD §5)
    Behavior on scale {
        SpringAnimation { spring: 3.2; damping: 0.28 }
    }

    scale: 1
}
