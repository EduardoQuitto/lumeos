import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Flyout Volume — dispositivos de áudio
// Raio 16, vidro, slide 12px mola, abrir <150ms
Popup {
    id: flyoutVolume
    width: 340
    height: 320
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    NumberAnimation on y {
        from: parent.height + 12
        to: parent.height - height - 8
        duration: 120
        easing.type: Easing.OutQuad
        running: flyoutVolume.visible
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
            text: "Som"
            font.pointSize: 18
            font.bold: true
            color: "#F7F9FC"
        }

        // Dispositivo de saída
        Text { text: "Saida de audio"; font.pointSize: 13; color: "#94A3B8" }
        ListView {
            id: listaSaida
            Layout.fillWidth: true
            height: 120
            spacing: 6
            model: 3
            delegate: Rectangle {
                width: listaSaida.width
                height: 36
                color: model.index === 0 ? "#3E8EF7" : "#0E1116"
                radius: 8
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    Text { text: "●"; color: "#FFFFFF"; font.pointSize: 10 }
                    Text { text: ["Fones de ouvido", "Altifalantes", "HDMI"][model.index]; font.pointSize: 13; color: model.index === 0 ? "#FFFFFF" : "#CBD5E1" }
                    Item { Layout.fillWidth: true }
                }
            }
        }

        // Slider volume principal
        RowLayout {
            Text { text: "Volume"; font.pointSize: 13; color: "#CBD5E1" }
            Item { Layout.fillWidth: true }
            Text { text: "60%"; font.pointSize: 12; color: "#94A3B8"; width: 30; horizontalAlignment: Text.AlignHRight }
        }
        Slider { Layout.fillWidth: true; value: 60 }

        // Dispositivo de entrada
        Text { text: "Entrada de audio (microfone)"; font.pointSize: 13; color: "#94A3B8"; Layout.topMargin: 16 }
        Slider { Layout.fillWidth: true; value: 40 }

        Button {
            Layout.fillWidth: true
            text: "Configuracoes de som..."
            font.pointSize: 13
            background: Rectangle { color: "#334155"; radius: 8 }
        }
    }
}
