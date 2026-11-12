import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Alt+Tab switcher — alternar janelas
Popup {
    id: altTabSwitcher
    width: 600
    height: 400
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    property int indiceSelecionado: 0

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#101418"
        radius: 12
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
        anchors.margins: 24
        spacing: 16

        Text {
            text: "Alternar Janela"
            font.pointSize: 18
            font.bold: true
            color: "#F7F9FC"
        }

        // Lista de janelas (thumbnail + título)
        ListView {
            id: listaJanelas
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12
            model: 4
            currentIndex: altTabSwitcher.indiceSelecionado
            delegate: Rectangle {
                width: listaJanelas.width
                height: 80
                color: listaJanelas.currentIndex === index ? "#3E8EF7" : "#0E1116"
                radius: 12
                border.color: listaJanelas.currentIndex === index ? "#45C8F5" : "#1e293b"
                border.width: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 16

                    // Thumbnail
                    Rectangle {
                        width: 56
                        height: 56
                        color: "#1e293b"
                        radius: 8
                        Text {
                            anchors.centerIn: parent
                            text: "W"
                            color: "#CBD5E1"
                            font.pointSize: 16
                            font.bold: true
                        }
                    }

                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: "Janela " + (index + 1)
                            font.pointSize: 14
                            color: listaJanelas.currentIndex === index ? "#FFFFFF" : "#CBD5E1"
                            font.bold: listaJanelas.currentIndex === index
                        }
                        Text {
                            text: "documento.pdf • app"
                            font.pointSize: 11
                            color: "#94A3B8"
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listaJanelas.currentIndex = index
                        altTabSwitcher.close()
                    }
                }
            }
        }

        Text {
            text: "Alt+Tab para navegar • Solte para alternar"
            font.pointSize: 11
            color: "#94A3B8"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Navegação com Alt+Tab
    Keys.onPressed: {
        if (event.key === Qt.Key_Tab && event.modifiers === Qt.AltModifier) {
            // Avançar para próxima janela
            indiceSelecionado = (indiceSelecionado + 1) % 4
            event.accepted = true
        } else if (event.key === Qt.Key_Alt && !event.isAutoRepeat) {
            // Soltar Alt para confirmar seleção
            altTabSwitcher.close()
            event.accepted = true
        } else if (event.key === Qt.Key_Escape) {
            altTabSwitcher.close()
            event.accepted = true
        }
    }
}
