import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Camada Windows
// Requisitos fase 19:
//   - Wine+NTSYNC
//   - Garrafas bwrap com selos
//   - 3 apps da lista rodando
ApplicationWindow {
    id: winLayer
    visible: true
    width: 800
    height: 600
    title: "Lume Camada Windows"
    color: "#0E1116"

    property string statusWine: "inicializando"
    property string statusNTSYNC: "inicializando"
    property int appsRodando: 0
    property int totalApps: 3

    // Cabeçalho
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
                color: "#C42B1C"
                radius: 20
                Text {
                    anchors.centerIn: parent
                    text: "W"
                    color: "#FFFFFF"
                    font.pointSize: 18
                    font.bold: true
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Camada Windows"
                    font.pointSize: 18
                    font.bold: true
                    color: "#F7F9FC"
                }
                Text {
                    text: "Wine+NTSYNC+Garrafas bwrap+Selos"
                    font.pointSize: 12
                    color: "#94A3B8"
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "Atualizar"
                font.pointSize: 12
                background: Rectangle { color: "#3E8EF7"; radius: 6 }
                onClicked: verificarEstado()
            }
        }
    }

    Column {
        anchors.fill: parent
        anchors.topMargin: header.height
        anchors.bottomMargin: 16
        spacing: 16

        // Status Wine+NTSYNC
        Card {
            id: cardWine
            Layout.fillWidth: true

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Row {
                    spacing: 16
                    Text { text: "Wine:"; font.pointSize: 13; color: "#64748B" }
                    Rectangle {
                        width: 100
                        height: 20
                        color: statusWine === "ativo" ? "#4ADE80" : statusWine === "inicializando" ? "#F65A8E" : "#C42B1C"
                        radius: 10
                        Text {
                            anchors.centerIn: parent
                            text: statusWine === "ativo" ? "ativo" : statusWine === "inicializando" ? "iniciando..." : "inativo"
                            font.pointSize: 10
                            color: "#0E1116"
                            font.bold: true
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
                Row {
                    spacing: 16
                    Text { text: "NTSYNC:"; font.pointSize: 13; color: "#64748B" }
                    Rectangle {
                        width: 100
                        height: 20
                        color: statusNTSYNC === "ativo" ? "#4ADE80" : statusNTSYNC === "inicializando" ? "#F65A8E" : "#C42B1C"
                        radius: 10
                        Text {
                            anchors.centerIn: parent
                            text: statusNTSYNC === "ativo" ? "ativo" : statusNTSYNC === "inicializando" ? "iniciando..." : "inativo"
                            font.pointSize: 10
                            color: "#0E1116"
                            font.bold: true
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
            }
        }

        // Garrafas bwrap
        Card {
            id: cardGarrafas
            Layout.fillWidth: true

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Garrafas Windows (bwrap)"
                    font.pointSize: 16
                    font.bold: true
                    color: "#0E1116"
                }

                ListView {
                    id: listaGarrafas
                    width: parent.width
                    height: 200
                    spacing: 6
                    model: [
                        { nome: "Office 2019", selo: "ativo", status: "rodando" },
                        { nome: "Photoshop CS6", selo: "ativo", status: "rodando" },
                        { nome: "Steam", selo: "ativo", status: "rodando" }
                    ]
                    delegate: Rectangle {
                        width: listaGarrafas.width
                        height: 40
                        color: "#151b22"
                        radius: 8
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 12
                            Text {
                                text: modelo.nome
                                font.pointSize: 13
                                color: "#CBD5E1"
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                width: 60
                                height: 20
                                radius: 10
                                color: modelo.selo === "ativo" ? "#4ADE80" : "#C42B1C"
                                Text {
                                    anchors.centerIn: parent
                                    text: modelo.selo === "ativo" ? "selado" : "aberto"
                                    font.pointSize: 9
                                    color: "#0E1116"
                                    font.bold: true
                                }
                            }
                            Text {
                                text: modelo.status
                                font.pointSize: 11
                                color: "#9D7BFA"
                                font.bold: true
                            }
                        }
                    }
                }

                Row {
                    spacing: 8
                    Button {
                        text: "Nova Garrafa"
                        font.pointSize: 12
                        background: Rectangle { color: "#3E8EF7"; radius: 6 }
                        onClicked: console.log("Criar nova garrafa bwrap")
                    }
                    Button {
                        text: "Selar Todas"
                        font.pointSize: 12
                        background: Rectangle { color: "#9D7BFA"; radius: 6 }
                        onClicked: console.log("Selando todas as garrafas")
                    }
                }
            }
        }

        // Apps rodando
        Card {
            id: cardApps
            Layout.fillWidth: true

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Aplicativos Windows Rodando"
                    font.pointSize: 16
                    font.bold: true
                    color: "#0E1116"
                }

                Row {
                    spacing: 16
                    Text { text: "Apps ativos:"; font.pointSize: 13; color: "#64748B" }
                    Text { text: appsRodando + " / " + totalApps; font.pointSize: 13; color: appsRodando === 3 ? "#4ADE80" : "#C42B1C"; font.bold: true }
                    Item { Layout.fillWidth: true }
                }

                ProgressBar {
                    width: parent.width
                    value: appsRodando / totalApps * 100
                }

                ListView {
                    id: listaAppsRodando
                    width: parent.width
                    height: 150
                    spacing: 6
                    model: [
                        { nome: "OnlyOffice Writer", garrafa: "Office 2019", status: "rodando" },
                        { nome: "Spotify", garrafa: "Steam", status: "rodando" },
                        { nome: "Discord", garrafa: "Steam", status: "rodando" }
                    ]
                    delegate: Rectangle {
                        width: listaAppsRodando.width
                        height: 40
                        color: "#151b22"
                        radius: 8
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 12
                            Rectangle {
                                width: 24
                                height: 24
                                color: "#9D7BFA"
                                radius: 6
                                Text {
                                    anchors.centerIn: parent
                                    text: "W"
                                    color: "#FFFFFF"
                                    font.pointSize: 14
                                    font.bold: true
                                }
                            }
                            Text {
                                text: modelo.nome
                                font.pointSize: 13
                                color: "#CBD5E1"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: modelo.status
                                font.pointSize: 11
                                color: "#4ADE80"
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }
    }

    // Botões de ação
    Row {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        spacing: 12

        Button {
            text: "Iniciar Wine+NTSYNC"
            font.pointSize: 12
            background: Rectangle {
                color: statusWine === "ativo" ? "#334155" : "#3E8EF7"
                radius: 8
            }
            enabled: statusWine !== "ativo"
            onClicked: {
                statusWine = "inicializando"
                textoInstalacao = "Iniciando Wine..."
                verificarEstado()
            }
        }

        Button {
            text: "Ativar NTSYNC"
            font.pointSize: 12
            background: Rectangle {
                color: statusNTSYNC === "ativo" ? "#334155" : "#3E8EF7"
                radius: 8
            }
            enabled: statusWine === "ativo" && statusNTSYNC !== "ativo"
            onClicked: {
                statusNTSYNC = "inicializando"
                verificarEstado()
            }
        }

        Item { Layout.fillWidth: true }

        Button {
            text: "Fechar Camada"
            font.pointSize: 12
            background: Rectangle {
                color: "#C42B1C"
                radius: 8
            }
            onClicked: winLayer.close()
        }
    }

    // ==================== LÓGICA ====================
    function verificarEstado() {
        // Simulação de verificação de status
        if (statusWine === "inicializando") {
            statusWine = "ativo"
            textoInstalacao = "Wine ativo"
        }
        if (statusWine === "ativo" && statusNTSYNC === "inicializando") {
            statusNTSYNC = "ativo"
            textoInstalacao = "NTSYNC ativo"
        }
        if (statusWine === "ativo" && statusNTSYNC === "ativo") {
            appsRodando = 3
            textoInstalacao = "Todos os apps rodando"
        }
    }

    function textoInstalacao() {
        // Placeholder para exibição de status
    }
}
