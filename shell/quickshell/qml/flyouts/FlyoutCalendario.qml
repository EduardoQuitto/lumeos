import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Flyout Calendário + Notificações — mês + lista + limpar
// Raio 16, vidro, slide 12px mola, abrir <150ms
Popup {
    id: flyoutCalendario
    width: 360
    height: 520
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    NumberAnimation on y {
        from: parent.height + 12
        to: parent.height - height - 8
        duration: 120
        easing.type: Easing.OutQuad
        running: flyoutCalendario.visible
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

        // Cabeçalho: mês/ano + botão hoje
        RowLayout {
            Text {
                text: "Novembro 2026"
                font.pointSize: 16
                font.bold: true
                color: "#F7F9FC"
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Hoje"
                font.pointSize: 11
                background: Rectangle { color: "#334155"; radius: 6 }
            }
        }

        // Grade do calendário (simplificada)
        GridLayout {
            columns: 7
            spacing: 4
            Layout.fillWidth: true
            Repeater {
                model: 7
                delegate: Text {
                    text: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"][model.index]
                    font.pointSize: 11
                    color: "#94A3B8"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            Repeater {
                model: 31
                delegate: Rectangle {
                    width: 34
                    height: 34
                    color: model.index === 12 ? "#3E8EF7" : "transparent"
                    radius: 6
                    Text {
                        anchors.centerIn: parent
                        text: model.index + 1
                        color: model.index === 12 ? "#FFFFFF" : "#CBD5E1"
                        font.pointSize: 13
                    }
                }
            }
        }

        // Notificações
        Text {
            text: "Notificacoes"
            font.pointSize: 14
            font.bold: true
            color: "#F7F9FC"
            Layout.topMargin: 12
        }
        ListView {
            id: listaNotificacoes
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6
            model: 4
            delegate: Rectangle {
                width: listaNotificacoes.width
                height: 56
                color: "#0E1116"
                radius: 8
                border.color: "#1e293b"
                border.width: 1
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    Rectangle { width: 24; height: 24; color: "#9D7BFA"; radius: 6 }
                    ColumnLayout {
                        spacing: 2
                        Text { text: "Lume OS"; font.pointSize: 12; font.bold: true; color: "#F7F9FC" }
                        Text { text: "Atualizacao disponivel"; font.pointSize: 10; color: "#94A3B8" }
                    }
                    Item { Layout.fillWidth: true }
                    Text { text: "10h"; font.pointSize: 10; color: "#64748B" }
                }
            }
        }

        // Botão limpar notificações
        Button {
            Layout.fillWidth: true
            text: "Limpar todas"
            font.pointSize: 12
            color: "#C42B1C"
            background: Rectangle { color: "transparent"; radius: 8 }
        }
    }
}
