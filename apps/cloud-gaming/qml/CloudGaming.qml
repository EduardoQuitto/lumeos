import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Jogos Nuvem
// Requisitos fase 20:
//   - Steam+Proton para tiers B/C
//   - Sober best-effort
//   - PWAs nuvem por tier
ApplicationWindow {
    id: cloudGaming
    visible: true
    width: 800
    height: 600
    title: "Lume Jogos Nuvem"
    color: "#0E1116"

    property string steamStatus: "inicializando"
    property string protonStatus: "inicializando"
    property string soberStatus: "inicializando"
    property string tier: "prime"

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
                color: "#9D7BFA"
                radius: 20
                Text {
                    anchors.centerIn: parent
                    text: "☁"
                    color: "#FFFFFF"
                    font.pointSize: 24
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Jogos Nuvem"
                    font.pointSize: 18
                    font.bold: true
                    color: "#F7F9FC"
                }
                Text {
                    text: "Steam/Proton + Sober + PWAs por tier"
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

        // Status Steam+Proton
        Card {
            id: cardSteam
            Layout.fillWidth: true

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Row {
                    spacing: 16
                    Text { text: "Steam:"; font.pointSize: 13; color: "#64748B" }
                    Rectangle {
                        width: 100
                        height: 20
                        color: steamStatus === "ativo" ? "#4ADE80" : statusSteam === "inicializando" ? "#F65A8E" : "#C42B1C"
                        radius: 10
                        Text {
                            anchors.centerIn: parent
                            text: steamStatus === "ativo" ? "ativo" : steamStatus === "inicializando" ? "iniciando..." : "inativo"
                            font.pointSize: 10
                            color: "#0E1116"
                            font.bold: true
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
                Row {
                    spacing: 16
                    Text { text: "Proton:"; font.pointSize: 13; color: "#64748B" }
                    Rectangle {
                        width: 100
                        height: 20
                        color: protonStatus === "ativo" ? "#4ADE80" : protonStatus === "inicializando" ? "#F65A8E" : "#C42B1C"
                        radius: 10
                        Text {
                            anchors.centerIn: parent
                            text: protonStatus === "ativo" ? "ativo" : protonStatus === "inicializando" ? "iniciando..." : "inativo"
                            font.pointSize: 10
                            color: "#0E1116"
                            font.bold: true
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
            }
        }

        // Sober
        Card {
            id: cardSober
            Layout.fillWidth: true

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Row {
                    spacing: 16
                    Text { text: "Sober:"; font.pointSize: 13; color: "#64748B" }
                    Rectangle {
                        width: 100
                        height: 20
                        color: soberStatus === "ativo" ? "#4ADE80" : soberStatus === "inicializando" ? "#F65A8E" : "#C42B1C"
                        radius: 10
                        Text {
                            anchors.centerIn: parent
                            text: soberStatus === "ativo" ? "ativo" : soberStatus === "inicializando" ? "iniciando..." : "inativo"
                            font.pointSize: 10
                            color: "#0E1116"
                            font.bold: true
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                Row {
                    spacing: 16
                    Text { text: "Tier:"; font.pointSize: 13; color: "#64748B" }
                    Text {
                        text: tier
                        font.pointSize: 13
                        color: "#0E1116"
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                }
            }
        }

        // PWAs Nuvem
        Card {
            id: cardPwa
            Layout.fillWidth: true

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "PWAs Nuvem por Tier"
                    font.pointSize: 16
                    font.bold: true
                    color: "#0E1116"
                }

                ListView {
                    id: listaPwa
                    width: parent.width
                    height: 200
                    spacing: 6
                    model: [
                        { nome: "GeForce Now", tier: "prime", url: "https://play.geforce.com", status: "disponível" },
                        { nome: "Xbox Cloud Gaming", tier: "core", url: "https://xbox.com/play", status: "disponível" },
                        { nome: "Amazon Luna", tier: "lite", url: "https://luna.amazon.com", status: "disponível" },
                        { nome: "Google Stadia", tier: "prime", url: "https://stadia.google.com", status: "descontinuado" },
                        { nome: "Nvidia GeForce Now", tier: "core", url: "https://nvidia.com/pt-br/geforce-now/", status: "disponível" }
                    ]
                    delegate: Rectangle {
                        width: listaPwa.width
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
                            Text {
                                text: modelo.tier
                                font.pointSize: 10
                                color: "#9D7BFA"
                                font.bold: true
                            }
                            Text {
                                text: modelo.status
                                font.pointSize: 11
                                color: modelo.status === "disponível" ? "#4ADE80" : "#C42B1C"
                                font.bold: true
                            }
                        }
                    }
                }

                Row {
                    spacing: 8
                    Button {
                        text: "Abrir PWA"
                        font.pointSize: 12
                        background: Rectangle { color: "#3E8EF7"; radius: 6 }
                        onClicked: console.log("Abrir PWA selecionada")
                    }
                    Button {
                        text: "Instalar PWA"
                        font.pointSize: 12
                        background: Rectangle { color: "#9D7BFA"; radius: 6 }
                        onClicked: console.log("Instalar PWA selecionada")
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
            text: "Instalar Steam+Proton"
            font.pointSize: 12
            background: Rectangle {
                color: steamStatus === "ativo" ? "#334155" : "#3E8EF7"
                radius: 8
            }
            enabled: steamStatus !== "ativo"
            onClicked: {
                steamStatus = "inicializando"
                verificarEstado()
            }
        }

        Button {
            text: "Instalar Proton"
            font.pointSize: 12
            background: Rectangle {
                color: protonStatus === "ativo" ? "#334155" : "#3E8EF7"
                radius: 8
            }
            enabled: steamStatus === "ativo" && protonStatus !== "ativo"
            onClicked: {
                protonStatus = "inicializando"
                verificarEstado()
            }
        }

        Button {
            text: "Instalar Sober"
            font.pointSize: 12
            background: Rectangle {
                color: soberStatus === "ativo" ? "#334155" : "#3E8EF7"
                radius: 8
            }
            enabled: steamStatus === "ativo" && soberStatus !== "ativo"
            onClicked: {
                soberStatus = "inicializando"
                verificarEstado()
            }
        }

        Item { Layout.fillWidth: true }

        Button {
            text: "Fechar"
            font.pointSize: 12
            background: Rectangle {
                color: "#C42B1C"
                radius: 8
            }
            onClicked: cloudGaming.close()
        }
    }

    // ==================== LÓGICA ====================
    function verificarEstado() {
        if (steamStatus === "inicializando") {
            steamStatus = "ativo"
            textoInstalacao = "Wine ativo"
        }
        if (steamStatus === "ativo" && protonStatus === "inicializando") {
            protonStatus = "ativo"
            textoInstalacao = "NTSYNC ativo"
        }
        if (steamStatus === "ativo" && protonStatus === "ativo") {
            soberStatus = "ativo"
            textoInstalacao = "Todos os apps rodando"
        }
    }
}
