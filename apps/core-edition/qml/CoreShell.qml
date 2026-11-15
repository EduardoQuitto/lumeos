import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Shell Core — labwc + Quickshell
// Arquitetura: amd64
// Target: <4 GB RAM ou GPU sem GLES3.2/VA-API
// Idle target: ≤350 MB
// Materiais: Névoa + Sólido + sombras

ApplicationWindow {
    id: coreShell
    visible: true
    width: 1280
    height: 720
    color: "#0E1116"

    property string sessao: "labwc"
    property string compositor: "quickshell"
    property string tema: "Névoa"
    property int memoriaIdle: 0

    // Fundo da área de trabalho (wallpaper aurora-peaks)
    Rectangle {
        id: fundo
        anchors.fill: parent
        color: "#0E1116"
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real intensity: 0.6
            property color tint: "#0E1116"
            fragmentShader: ""
            Rectangle { id: shaderSource; width: fundo.width; height: fundo.height; color: "transparent" }
        }
    }

    // Barra inferior pílula (simplificada para Core)
    Rectangle {
        id: barra
        width: parent.width - 16
        height: 48
        x: 8
        y: parent.height - 56
        color: "#101418"
        radius: 24
        border.color: "#1e293b"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Button {
                id: btnMenu
                width: 32
                height: 32
                text: "L"
                font.pointSize: 14
                font.bold: true
                color: "#3E8EF7"
                background: Rectangle { color: "transparent"; radius: 16 }
                onClicked: menuAplicacoes.open()
            }

            Button {
                width: 28
                height: 28
                text: "F"
                font.pointSize: 12
                color: "#CBD5E1"
                background: Rectangle { color: "transparent"; radius: 14 }
                onClicked: console.log("Abrir Files")
            }
            Button {
                width: 28
                height: 28
                text: "S"
                font.pointSize: 12
                color: "#CBD5E1"
                background: Rectangle { color: "transparent"; radius: 14 }
                onClicked: console.log("Abrir Settings")
            }
            Button {
                width: 28
                height: 28
                text: "T"
                font.pointSize: 12
                color: "#CBD5E1"
                background: Rectangle { color: "transparent"; radius: 14 }
                onClicked: console.log("Abrir Terminal")
            }

            Item { Layout.fillWidth: true }

            Row {
                spacing: 8
                Text {
                    text: "●●●●●"
                    font.pointSize: 11
                    color: "#4ADE80"
                }
                Text {
                    text: "●●●●○ 82%"
                    font.pointSize: 11
                    color: "#4ADE80"
                }
                Text {
                    text: "pt-BR"
                    font.pointSize: 11
                    color: "#CBD5E1"
                }
                Text {
                    id: relogioCore
                    text: "10:09 AM"
                    font.pointSize: 11
                    color: "#CBD5E1"
                    font.bold: true
                }
            }

            Button {
                id: btnDesligar
                width: 28
                height: 28
                text: "⏻"
                font.pointSize: 12
                color: "#C42B1C"
                background: Rectangle { color: "transparent"; radius: 14 }
                onClicked: console.log("Desligar")
            }
        }
    }

    // Monitor de memória (idle ≤350MB)
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            memoriaIdle = Math.floor(Math.random() * 50) + 300 // 300-350 MB simulado
            if (memoriaIdle > 350) {
                console.log("AVISO: Idle acima de 350MB (" + memoriaIdle + "MB)")
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            relogioCore.text = Qt.formatDateTime(new Date(), "h:mm:ss AP")
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Escape) {
            menuAplicacoes.close()
            event.accepted = true
        } else if (event.key === Qt.Key_T && event.modifiers === (Qt.ControlModifier | Qt.AltModifier)) {
            console.log("Abrir Terminal (Ctrl+Alt+T)")
            event.accepted = true
        }
    }
}
