import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Overview — Super+Tab com thumbnails centralizados
Popup {
    id: overview
    width: parent.width
    height: parent.height
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    property bool visivel: false

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#000000"
        opacity: 0.4
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real blur: 12
            fragmentShader: ""
            Rectangle { id: shaderSource; width: bg.width; height: bg.height; color: "transparent" }
        }
    }

    // Grid de thumbnails centralizados
    GridView {
        id: gridThumbnails
        anchors.centerIn: parent
        cellWidth: 320
        cellHeight: 200
        spacing: 24
        model: 6

        delegate: Rectangle {
            width: 320
            height: 200
            color: "#101418"
            radius: 12
            border.color: overview.thumbnailSelecionado === index ? "#3E8EF7" : "#1e293b"
            border.width: overview.thumbnailSelecionado === index ? 2 : 1
            layer.enabled: true
            layer.effect: ShaderEffect {
                property variant source: shaderSource
                property real blur: 4
                fragmentShader: ""
                Rectangle { id: shaderSource; width: thumb.width; height: thumb.height; color: "transparent" }
            }

            Row {
                anchors.centerIn: parent
                spacing: 8
                Rectangle {
                    width: 40
                    height: 40
                    color: "#3E8EF7"
                    radius: 10
                    Text {
                        anchors.centerIn: parent
                        text: "W"
                        color: "#FFFFFF"
                        font.bold: true
                    }
                }
                Text {
                    text: "Janela " + (index + 1)
                    color: "#CBD5E1"
                    font.pointSize: 13
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    overview.thumbnailSelecionado = index
                    overview.close()
                }
                onEntered: overview.thumbnailSelecionado = index
            }
        }
    }

    // Fechar com Escape
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape) {
            overview.close()
            event.accepted = true
        } else if (event.key === Qt.Key_Tab && event.modifiers === Qt.SuperModifier) {
            // Ciclar overview ou fechar
            overview.close()
            event.accepted = true
        }
    }
}
