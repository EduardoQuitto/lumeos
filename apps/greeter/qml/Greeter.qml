import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Greeter / Lock
// Wallpaper escurecido+blur, relogio grande, avatar central, senha em pilula
ApplicationWindow {
    id: greeterWindow
    visible: true
    width: 1280
    height: 720
    color: "#0E1116"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    property bool lockMode: false

    // Fundo: wallpaper escurecido + blur
    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#0E1116"
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real intensity: 0.6
            property color tint: "#0E1116"
            fragmentShader: ""
            Rectangle { id: shaderSource; width: bg.width; height: bg.height; color: "transparent" }
        }
    }

    // Sobreposicao escurecida
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.4
    }

    // Conteudo central
    Column {
        anchors.centerIn: parent
        spacing: 24

        // Relogio grande
        Text {
            id: relogio
            text: "00:00"
            font.pointSize: 96
            font.bold: true
            color: "#F7F9FC"
        }

        // Data
        Text {
            text: Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy")
            font.pointSize: 18
            color: "#94A3B8"
        }

        // Avatar central
        Rectangle {
            width: 120
            height: 120
            color: "#101418"
            radius: 60
            border.color: "#3E8EF7"
            border.width: 3
            Text {
                anchors.centerIn: parent
                text: "U"
                color: "#3E8EF7"
                font.pointSize: 48
                font.bold: true
            }
        }

        // Senha em pilula
        Rectangle {
            width: 320
            height: 56
            color: "#151b22"
            radius: 28
            border.color: "#1e293b"
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                Text {
                    text: "●●●●●●●●"
                    font.pointSize: 16
                    color: "#F7F9FC"
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: "Entrar"
                    font.pointSize: 13
                    background: Rectangle {
                        color: "#3E8EF7"
                        radius: 20
                    }
                    onClicked: console.log("Fazer login")
                }
            }
        }

        // Indicadores (rede, bateria, relogio pequeno)
        Row {
            spacing: 24
            Text {
                text: "●●●●●  Wi-Fi"
                font.pointSize: 13
                color: "#4ADE80"
            }
            Text {
                text: "●●●●○  82%"
                font.pointSize: 13
                color: "#4ADE80"
            }
            Text {
                id: relogioPequeno
                text: "10:09"
                font.pointSize: 13
                color: "#CBD5E1"
            }
        }
    }

    // Atualizar relogio
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            relogio.text = Qt.formatDateTime(new Date(), "HH:mm")
            relogioPequeno.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    // Teclas
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape) {
            greeterWindow.close()
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            console.log("Fazer login")
            event.accepted = true
        }
    }
}
