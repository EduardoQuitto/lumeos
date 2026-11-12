import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Menu Iniciar — 640x560
// Busca no topo, grid 6x3 fixados, recentes, rodape usuario+energia
Popup {
    id: menuIniciar
    width: 640
    height: 560
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    property bool openAnimating: false

    // Animação de entrada: scale + fade (mola)
    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
    }

    scale: 1

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
        anchors.margins: 16
        spacing: 12

        // ==================== BUSCA NO TOPO ====================
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: campoBusca
                Layout.fillWidth: true
                placeholderText: "Buscar apps, arquivos, configs..."
                font.pointSize: 14
                color: "#F7F9FC"
                background: Rectangle { color: "#0E1116"; radius: 8 }
                onTextChanged: atualizarResultados(text)
            }

            Button {
                width: 36
                height: 36
                text: "🔍"
                font.pointSize: 16
                background: Rectangle { color: "#3E8EF7"; radius: 8 }
                onClicked: campoBusca.focus = true
            }
        }

        // ==================== ABA: TODOS / RECENTES ====================
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Button {
                text: "Todos"
                font.pointSize: 12
                color: "#3E8EF7"
                background: Rectangle { color: "#1e293b"; radius: 6 }
                onClicked: pilhaAtual.currentIndex = 0
            }

            Button {
                text: "Recentes"
                font.pointSize: 12
                color: "#94A3B8"
                background: Rectangle { color: "transparent"; radius: 6 }
                onClicked: pilhaAtual.currentIndex = 1
            }

            Item { Layout.fillWidth: true }
        }

        // ==================== PILHA DE RESULTADOS ====================
        StackLayout {
            id: pilhaAtual
            Layout.fillWidth: true
            Layout.fillHeight: true

            // --- Aba: Todos (grid 6x3) ---
            GridView {
                id: gridApps
                width: Layout.preferredWidth
                height: Layout.preferredHeight
                cellWidth: 96
                cellHeight: 96
                model: 18
                delegate: Rectangle {
                    width: 96
                    height: 96
                    color: "#1e293b"
                    radius: 12
                    border.color: "#334155"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Rectangle {
                            width: 48
                            height: 48
                            color: "#3E8EF7"
                            radius: 12
                            Text {
                                anchors.centerIn: parent
                                text: "A"
                                color: "#FFFFFF"
                                font.pointSize: 18
                                font.bold: true
                            }
                        }

                        Text {
                            text: "App " + (model.index + 1)
                            font.pointSize: 11
                            color: "#CBD5E1"
                            horizontalAlignment: Text.AlignHCenter
                            width: 80
                            wrapMode: Text.Wrap
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("Lançar: App " + (model.index + 1))
                            menuIniciar.close()
                        }
                    }
                }
            }

            // --- Aba: Recentes ---
            ListView {
                id: listaRecentes
                width: Layout.preferredWidth
                height: Layout.preferredHeight
                spacing: 8
                model: 6
                delegate: Rectangle {
                    width: listaRecentes.width
                    height: 56
                    color: "#0E1116"
                    radius: 8
                    border.color: "#1e293b"
                    border.width: 1
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            color: "#9D7BFA"
                            radius: 10
                            Text {
                                anchors.centerIn: parent
                                text: "R"
                                color: "#FFFFFF"
                                font.pointSize: 16
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Text {
                                text: "Arquivo recente " + (model.index + 1)
                                font.pointSize: 13
                                color: "#F7F9FC"
                            }
                            Text {
                                text: "documento.pdf • 10 min atrás"
                                font.pointSize: 10
                                color: "#94A3B8"
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "▶"
                            color: "#3E8EF7"
                            font.pointSize: 14
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("Abrir recente " + (model.index + 1))
                            menuIniciar.close()
                        }
                    }
                }
            }
        }

        // ==================== RODAPÉ: USUÁRIO + ENERGIA ====================
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            // Usuário
            Row {
                spacing: 8
                Rectangle {
                    width: 36
                    height: 36
                    color: "#3E8EF7"
                    radius: 18
                    Text {
                        anchors.centerIn: parent
                        text: "U"
                        color: "#FFFFFF"
                        font.pointSize: 16
                        font.bold: true
                    }
                }
                Column {
                    spacing: 2
                    Text {
                        text: "Usuário"
                        font.pointSize: 13
                        font.bold: true
                        color: "#F7F9FC"
                    }
                    Text {
                        text: "usuario@lume-os"
                        font.pointSize: 10
                        color: "#94A3B8"
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Energia
            Column {
                spacing: 2
                Button {
                    text: "Desligar"
                    font.pointSize: 12
                    color: "#C42B1C"
                    background: Rectangle { color: "#2E1A1A"; radius: 6 }
                    onClicked: console.log("Desligar sistema")
                }
                Button {
                    text: "Reiniciar"
                    font.pointSize: 12
                    color: "#F65A8E"
                    background: Rectangle { color: "#2E1A1A"; radius: 6 }
                    onClicked: console.log("Reiniciar sistema")
                }
            }
        }
    }

    // ==================== BUSCA UNIVERSAL ====================
    function atualizarResultados(termo) {
        if (termo.length === 0) {
            pilhaAtual.currentIndex = 0
            return
        }

        // Provedores de busca (web off padrão):
        // 1. Apps
        // 2. Arquivos
        // 3. Configs
        // 4. Cálculo

        console.log("Buscando: " + termo)

        // Simular resultados de busca
        var apps = []
        var arquivos = []
        var configs = []
        var calculo = []

        // Cálculo simples
        var match = termo.match(/^(\d+)\s*([\+\-\*\/])\s*(\d+)$/)
        if (match) {
            var a = parseInt(match[1])
            var op = match[2]
            var b = parseInt(match[3])
            var resultado = 0
            if (op === "+") resultado = a + b
            else if (op === "-") resultado = a - b
            else if (op === "*") resultado = a * b
            else if (op === "/") resultado = b !== 0 ? a / b : 0
            calculo.push({ texto: termo + " = " + resultado, tipo: "calculo" })
        }

        // Alternar para aba de resultados se houver termo
        if (apps.length > 0 || arquivos.length > 0 || configs.length > 0 || calculo.length > 0) {
            // Em implementação completa, exibiria resultados unificados
            pilhaAtual.currentIndex = 0
        }
    }

    // Atalhos de teclado
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape) {
            menuIniciar.close()
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            // Lançar primeiro resultado
            console.log("Lançar primeiro resultado")
            menuIniciar.close()
            event.accepted = true
        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
            // Navegar resultados
            event.accepted = true
        }
    }

    // Abrir automaticamente o campo de busca
    Component.onCompleted: campoBusca.focus = true
}
