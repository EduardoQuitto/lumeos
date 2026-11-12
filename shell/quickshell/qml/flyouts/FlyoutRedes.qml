import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Flyout Redes — lista de redes Wi-Fi, senha, rede oculta, WireGuard
// Raio 16, vidro, slide 12px mola, abrir <150ms
Popup {
    id: flyoutRedes
    width: 360
    height: 440
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    property bool openAnimating: false

    // Animação de entrada: slide 12px + fade (mola)
    NumberAnimation on y {
        from: parent.height + 12
        to: parent.height - height - 8
        duration: 120
        easing.type: Easing.OutQuad
        running: flyoutRedes.visible
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#101418"
        radius: 16
        border.color: "#1e293b"
        border.width: 1
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real intensity: 0.6
            property color tint: "#101418"
            fragmentShader: ""
            Rectangle { id: shaderSource; width: bg.width; height: bg.height; color: "transparent" }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "Redes"
            font.pointSize: 18
            font.bold: true
            color: "#F7F9FC"
        }

        // Toggle Wi-Fi
        RowLayout {
            Text { text: "Wi-Fi"; font.pointSize: 14; color: "#CBD5E1" }
            Item { Layout.fillWidth: true }
            Switch { text: "Ligado"; checked: true }
        }

        // Lista de redes
        ListView {
            id: listaRedes
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            model: 5
            delegate: Rectangle {
                width: listaRedes.width
                height: 44
                color: index % 2 === 0 ? "#0E1116" : "#151b22"
                radius: 8
                border.color: "#1e293b"
                border.width: 1
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    Text { text: "◌"; color: "#94A3B8" }
                    Text { text: "Rede " + (model.index + 1); font.pointSize: 13; color: "#CBD5E1" }
                    Item { Layout.fillWidth: true }
                    Text { text: "●●●●"; color: "#4ADE80"; font.pointSize: 11 }
                }
            }
        }

        // Rede oculta
        RowLayout {
            Text { text: "Adicionar rede oculta…"; font.pointSize: 13; color: "#3E8EF7" }
            Item { Layout.fillWidth: true }
        }

        // WireGuard
        RowLayout {
            Text { text: "WireGuard"; font.pointSize: 13; color: "#CBD5E1" }
            Item { Layout.fillWidth: true }
            Switch { checked: false }
        }
    }
}
