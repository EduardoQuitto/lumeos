import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Essentials — OOBE 1-clique instala pacote
// Requisitos fase 13:
//   - OOBE: instala pacote Essenciais com 1 clique
//   - PWAs: Firefox modo app + .desktop + ícone
//   - MIME defaults: associação de arquivos
ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 600
    title: "Lume Essentials"
    color: "#0E1116"

    property string pacoteSelecionado: "padrao"

    // ==================== CABEÇALHO ====================
    Rectangle {
        id: header
        width: parent.width
        height: 80
        color: "#101418"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Rectangle {
                width: 40
                height: 40
                color: "#3E8EF7"
                radius: 20
                Text {
                    anchors.centerIn: parent
                    text: "L"
                    color: "#FFFFFF"
                    font.pointSize: 18
                    font.bold: true
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Pacote Essenciais"
                    font.pointSize: 18
                    font.bold: true
                    color: "#F7F9FC"
                }
                Text {
                    text: "Instalação de aplicativos essenciais com 1 clique"
                    font.pointSize: 12
                    color: "#94A3B8"
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "Avançar"
                font.pointSize: 12
                background: Rectangle { color: "#3E8EF7"; radius: 6 }
                onClicked: console.log("Avançar OOBE")
            }
        }
    }

    // ==================== CONTEÚDO ====================
    Column {
        id: content
        anchors.fill: parent
        anchors.topMargin: header.height
        anchors.bottomMargin: 16
        spacing: 16

        // Pacote Essenciais
        Card {
            id: cardEssenciais
            Layout.fillWidth: true

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Row {
                    spacing: 16
                    Rectangle {
                        width: 48
                        height: 48
                        color: "#3E8EF7"
                        radius: 12
                        Text {
                            anchors.centerIn: parent
                            text: "📦"
                            font.pointSize: 24
                        }
                    }

                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: "Pacote Essenciais"
                            font.pointSize: 16
                            font.bold: true
                            color: "#0E1116"
                        }
                        Text {
                            text: "OnlyOffice, WhatsApp PWA, Spotify/Discord/Zoom/Steam por tier, Teams PWA, Brave opcional"
                            font.pointSize: 12
                            color: "#64748B"
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Instalar com 1 clique"
                        font.pointSize: 12
                        background: Rectangle { color: "#3E8EF7"; radius: 6 }
                        onClicked: {
                            console.log("Instalar Pacote Essenciais com 1 clique")
                            root.pacoteSelecionado = "padrao"
                        }
                    }
                }

                // Lista de aplicativos inclusos
                Rectangle {
                    width: parent.width
                    color: "#151b22"
                    radius: 8
                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            text: "Aplicativos inclusos:"
                            font.pointSize: 12
                            font.bold: true
                            color: "#0E1116"
                        }

                        ListView {
                            id: listaApps
                            width: parent.width
                            height: 200
                            spacing: 4
                            model: [
                                { nome: "OnlyOffice", categoria: "Escritório", tier: "prime" },
                                { nome: "WhatsApp PWA", categoria: "Internet", tier: "core" },
                                { nome: "Spotify", categoria: "Internet", tier: "prime" },
                                { nome: "Discord", categoria: "Internet", tier: "core" },
                                { nome: "Zoom", categoria: "Internet", tier: "prime" },
                                { nome: "Steam", categoria: "Jogos", tier: "prime" },
                                { nome: "Teams PWA", categoria: "Internet", tier: "core" },
                                { nome: "Brave (opcional)", categoria: "Internet", tier: "prime" }
                            ]
                            delegate: Rectangle {
                                width: listaApps.width
                                height: 32
                                color: "transparent"
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    spacing: 8
                                    Rectangle {
                                        width: 24
                                        height: 24
                                        color: "#3E8EF7"
                                        radius: 6
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            color: "#FFFFFF"
                                            font.pointSize: 12
                                            font.bold: true
                                        }
                                    }
                                    Text {
                                        text: modelo.nome
                                        font.pointSize: 12
                                        color: "#CBD5E1"
                                    }
                                    Text {
                                        text: modelo.categoria
                                        font.pointSize: 10
                                        color: "#94A3B8"
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: modelo.tier
                                        font.pointSize: 9
                                        color: "#F65A8E"
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Opções avançadas
        Card {
            id: cardOpcoes
            Layout.fillWidth: true

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Opções de instalação"
                    font.pointSize: 16
                    font.bold: true
                    color: "#0E1116"
                }

                Row {
                    spacing: 16
                    Text { text: "Instalar PWAs:"; font.pointSize: 13; color: "#64748B" }
                    Switch { checked: true }
                    Item { Layout.fillWidth: true }
                }

                Row {
                    spacing: 16
                    Text { text: "Configurar MIME defaults:"; font.pointSize: 13; color: "#64748B" }
                    Switch { checked: true }
                    Item { Layout.fillWidth: true }
                }

                Row {
                    spacing: 16
                    Text { text: "Criar atalhos na área de trabalho:"; font.pointSize: 13; color: "#64748B" }
                    Switch { checked: true }
                    Item { Layout.fillWidth: true }
                }
            }
        }

        // Progresso (exibido durante instalação)
        Rectangle {
            id: progresso
            width: parent.width
            height: 200
            color: "#F7F9FC"
            radius: 12
            border.color: "#1e293b"
            border.width: 1
            visible: false

            Column {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    text: "Instalando Pacote Essenciais..."
                    font.pointSize: 16
                    font.bold: true
                    color: "#0E1116"
                }

                ProgressBar {
                    width: 300
                    value: 0
                }

                Text {
                    text: "Aplicativo atual: --"
                    font.pointSize: 12
                    color: "#64748B"
                }

                Button {
                    text: "Cancelar"
                    font.pointSize: 12
                    background: Rectangle { color: "#C42B1C"; radius: 6 }
                    onClicked: progresso.visible = false
                }
            }
        }

        Item { Layout.fillWidth: true }
    }
}

// Componente Card reutilizável
QtObject {
    id: cardComponent
}

// Estado de instalação
QtObject {
    id: estadoInstalacao
    property bool instalando: false
    property string appAtual: ""
    property int progresso: 0
}
