import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Flyout Quick Settings — 6 toggles + 2 sliders + bateria + editar
// Raio 16, vidro, slide 12px mola, abrir <150ms
Popup {
    id: flyoutQuickSettings
    width: 380
    height: 460
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    NumberAnimation on y {
        from: parent.height + 12
        to: parent.height - height - 8
        duration: 120
        easing.type: Easing.OutQuad
        running: flyoutQuickSettings.visible
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
            text: "Configuracoes Rapidas"
            font.pointSize: 18
            font.bold: true
            color: "#F7F9FC"
        }

        // Grid de toggles: 6 toggles em 2 colunas x 3 linhas
        GridLayout {
            columns: 2
            rows: 3
            spacing: 10
            Layout.fillWidth: true

            Repeater {
                model: 6
                delegate: RowLayout {
                    spacing: 8
                    Switch { checked: index % 2 === 0 }
                    Text {
                        text: ["Wi-Fi", "Bluetooth", "Modo Avião", "Não Perturbar", "Brilho Noite", "Localização"][index]
                        font.pointSize: 13
                        color: "#CBD5E1"
                    }
                }
            }
        }

        // 2 sliders (brilho, volume)
        Column {
            spacing: 8
            RowLayout {
                Text { text: "Brilho"; font.pointSize: 13; color: "#CBD5E1" }
                Item { Layout.fillWidth: true }
                Text { text: "75%"; font.pointSize: 12; color: "#94A3B8"; width: 30; horizontalAlignment: Text.AlignHRight }
            }
            Slider { Layout.fillWidth: true; value: 75 }

            RowLayout {
                Text { text: "Volume"; font.pointSize: 13; color: "#CBD5E1" }
                Item { Layout.fillWidth: true }
                Text { text: "60%"; font.pointSize: 12; color: "#94A3B8"; width: 30; horizontalAlignment: Text.AlignHRight }
            }
            Slider { Layout.fillWidth: true; value: 60 }
        }

        // Bateria (se existir)
        RowLayout {
            Text { text: "Bateria"; font.pointSize: 13; color: "#CBD5E1" }
            Item { Layout.fillWidth: true }
            Text { text: "82%"; font.pointSize: 13; color: "#4ADE80" }
        }

        // Botão editar
        Button {
            Layout.fillWidth: true
            text: "Editar rapidas configuracoes"
            font.pointSize: 13
            background: Rectangle { color: "#334155"; radius: 8 }
        }
    }
}
