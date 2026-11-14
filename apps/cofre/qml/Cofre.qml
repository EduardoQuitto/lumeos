import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Cofre - Modo Cofre (MicroVM Descartável)
// Requisitos fase 22:
//   - microVM descartável
//   - abre app de risco e destrói sem resíduo
ApplicationWindow {
    id: cofreWindow
    visible: true
    width: 800
    height: 600
    title: "Lume Cofre"
    color: "#0E1116"

    property string estado: "ocioso" // ocioso, executando, destruindo, concluido
    property string appRisco: ""
    property int tempoDecorrido: 0

    // Fundo escuro para modo cofre
    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#0E1116"
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Cabeçalho
        Rectangle {
            width: parent.width
            height: 80
            color: "#C42B1C"
            radius: 12

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                Rectangle {
                    width: 40
                    height: 40
                    color: "#F7F9FC"
                    radius: 20
                    Text {
                        anchors.centerIn: parent
                        text: "🔒"
                        color: "#C42B1C"
                        font.pointSize: 24
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Modo Cofre"
                        font.pointSize: 20
                        font.bold: true
                        color: "#F7F9FC"
                    }
                    Text {
                        text: "MicroVM descartável - sem resíduo"
                        font.pointSize: 12
                        color: "#F7F9FC"
                    }
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: "Sair"
                    font.pointSize: 12
                    background: Rectangle { color: "#F7F9FC"; radius: 6 }
                    color: "#0E1116"
                    onClicked: cofreWindow.close()
                }
            }
        }

        // Conteúdo principal
        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            // Status do cofre
            Card {
                id: cardStatus
                Layout.fillWidth: true

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Row {
                        spacing: 16
                        Text { text: "Estado:"; font.pointSize: 13; color: "#64748B" }
                        Rectangle {
                            width: 120
                            height: 24
                            color: estado === "ocioso" ? "#3E8EF7" : estado === "executando" ? "#F65A8E" : estado === "destruindo" ? "#C42B1C" : "#4ADE80"
                            radius: 10
                            Text {
                                anchors.centerIn: parent
                                text: estado === "ocioso" ? "Ocioso" : estado === "executando" ? "Executando..." : estado === "destruindo" ? "Destruindo..." : "Concluído"
                                font.pointSize: 10
                                color: "#0E1116"
                                font.bold: true
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }
                    Row {
                        spacing: 16
                        Text { text: "App de Risco:"; font.pointSize: 13; color: "#64748B" }
                        Text {
                            text: appRisco === "" ? "Nenhum" : appRisco
                            font.pointSize: 13
                            color: appRisco === "" ? "#94A3B8" : "#0E1116"
                            font.bold: appRisco !== ""
                        }
                        Item { Layout.fillWidth: true }
                    }
                    Row {
                        spacing: 16
                        Text { text: "Tempo:"; font.pointSize: 13; color: "#64748B" }
                        Text {
                            text: tempoDecorrido + "s"
                            font.pointSize: 13
                            color: "#CBD5E1"
                        }
                        Item { Layout.fillWidth: true }
                    }
                }
            }

            // Seleção de app de risco
            Card {
                id: cardApp
                Layout.fillWidth: true

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: "Selecionar App de Risco"
                        font.pointSize: 16
                        font.bold: true
                        color: "#0E1116"
                    }

                    ListView {
                        id: listaApps
                        width: parent.width
                        height: 200
                        spacing: 6
                        model: [
                            { nome: "Navegador Suspeito", categoria: "Navegador", risco: "Alto" },
                            { nome: "Cliente P2P", categoria: "Compartilhamento", risco: "Alto" },
                            { nome: "Jogo Não Verificado", categoria: "Jogo", risco: "Médio" },
                            { nome: "Utilitário Desconhecido", categoria: "Utilitário", risco: "Médio" }
                        ]
                        delegate: Rectangle {
                            width: listaApps.width
                            height: 48
                            color: "#151b22"
                            radius: 8
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 12
                                Rectangle {
                                    width: 24
                                    height: 24
                                    color: "#F65A8E"
                                    radius: 6
                                    Text {
                                        anchors.centerIn: parent
                                        text: "!"
                                        color: "#FFFFFF"
                                        font.pointSize: 14
                                        font.bold: true
                                    }
                                }
                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: modelo.nome
                                        font.pointSize: 13
                                        color: "#CBD5E1"
                                    }
                                    Text {
                                        text: modelo.categoria + " • " + modelo.risco
                                        font.pointSize: 10
                                        color: "#94A3B8"
                                    }
                                }
                                Item { Layout.fillWidth: true }
                                Button {
                                    text: "Executar"
                                    font.pointSize: 10
                                    background: Rectangle {
                                        color: modelo.risco === "Alto" ? "#C42B1C" : "#F65A8E"
                                        radius: 6
                                    }
                                    onClicked: {
                                        appRisco = modelo.nome
                                        estado = "executando"
                                        tempoDecorrido = 0
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Controles do cofre
            Row {
                spacing: 12
                Button {
                    id: btnIniciar
                    text: "Iniciar no Cofre"
                    font.pointSize: 12
                    background: Rectangle {
                        color: estado === "ocioso" ? "#3E8EF7" : "#334155"
                        radius: 8
                    }
                    enabled: estado === "ocioso"
                    onClicked: {
                        if (appRisco !== "") {
                            estado = "executando"
                            tempoDecorrido = 0
                        }
                    }
                }
                Button {
                    id: btnDestruir
                    text: "Destruir Cofre"
                    font.pointSize: 12
                    background: Rectangle {
                        color: estado === "executando" || estado === "destruindo" ? "#C42B1C" : "#334155"
                        radius: 8
                    }
                    enabled: estado === "executando" || estado === "destruindo"
                    onClicked: {
                        estado = "destruindo"
                        tempoDecorrido = 0
                    }
                }
                Item { Layout.fillWidth: true }
                Button {
                    text: "Resetar"
                    font.pointSize: 12
                    background: Rectangle {
                        color: "#334155"
                        radius: 8
                    }
                    onClicked: {
                        estado = "ocioso"
                        appRisco = ""
                        tempoDecorrido = 0
                    }
                }
            }

            // Progresso de destruição
            Rectangle {
                id: progresso
                width: parent.width
                height: 200
                color: "#F7F9FC"
                radius: 12
                border.color: "#1e293b"
                border.width: 1
                visible: estado === "destruindo"

                Column {
                    anchors.centerIn: parent
                    spacing: 16

                    Text {
                        text: "Destruindo Cofre..."
                        font.pointSize: 16
                        font.bold: true
                        color: "#0E1116"
                    }

                    ProgressBar {
                        width: 300
                        value: progressoDestruicao
                    }

                    Text {
                        text: textoProgresso
                        font.pointSize: 12
                        color: "#64748B"
                    }

                    Button {
                        text: "Cancelar Destruição"
                        font.pointSize: 12
                        background: Rectangle { color: "#334155"; radius: 6 }
                        onClicked: {
                            estado = "executando"
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }
    }

    // ==================== LÓGICA ====================
    property int progressoDestruicao: 0
    property string textoProgresso: "Inicializando destruição..."

    Timer {
        interval: 1000
        running: estado === "executando"
        repeat: true
        onTriggered: {
            tempoDecorrido++
        }
    }

    Timer {
        interval: 500
        running: estado === "destruindo"
        repeat: true
        onTriggered: {
            progressoDestruicao += 10
            if (progressoDestruicao < 25) textoProgresso = "Parando aplicativo..."
            else if (progressoDestruicao < 50) textoProgresso = "Desmontando microVM..."
            else if (progressoDestruicao < 75) textoProgresso = "Limpando memória..."
            else if (progressoDestruicao < 90) textoProgresso = "Limpando disco..."
            else textoProgresso = "Finalizando..."

            if (progressoDestruicao >= 100) {
                progressoDestruicao = 0
                estado = "ocioso"
                appRisco = ""
                tempoDecorrido = 0
            }
        }
    }
}
