import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Instalador HD
// Requisitos fase 15:
//   - Instalação em disco vazio
//   - LUKS+A/B (slots A e B)
//   - Teste instalação em VM
ApplicationWindow {
    id: instalador
    visible: true
    width: 800
    height: 600
    title: "Lume Instalador HD"
    color: "#0E1116"

    property int passoAtual: 0
    property string discoSelecionado: ""
    property string senhaLUKS: ""
    property string senhaConfirm: ""

    property var passos: [
        { id: "disco",    titulo: "Selecionar Disco",    descricao: "Selecione o disco vazio para instalação" },
        { id: "particao",  titulo: "Particionar",        descricao: "Criar partições LUKS+A/B" },
        { id: "usuario",   titulo: "Usuário",            descricao: "Criar conta de usuário" },
        { id: "instalacao", titulo: "Instalação",        descricao: "Instalando Lume OS..." },
        { id: "conclusao",  titulo: "Concluído",         descricao: "Instalação concluída com sucesso" }
    ]

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
        Row {
            spacing: 16
            Rectangle {
                width: 48
                height: 48
                color: "#3E8EF7"
                radius: 24
                Text {
                    anchors.centerIn: parent
                    text: "💿"
                    font.pointSize: 24
                }
            }
            Column {
                spacing: 4
                Text {
                    text: passos[passoAtual].titulo
                    font.pointSize: 20
                    font.bold: true
                    color: "#F7F9FC"
                }
                Text {
                    text: passos[passoAtual].descricao
                    font.pointSize: 13
                    color: "#94A3B8"
                }
            }
            Item { Layout.fillWidth: true }
        }

        Rectangle {
            id: linhaDivisoria
            width: parent.width
            height: 1
            color: "#1e293b"
        }

        // Conteúdo dos passos
        Stack {
            id: pilhaPassos
            anchors.fill: parent
            anchors.topMargin: 24
            anchors.bottomMargin: 24
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            // Passo 0: Selecionar Disco
            Column {
                visible: passoAtual === 0
                anchors.fill: parent
                spacing: 16

                Text {
                    text: "Selecionar Disco de Instalação"
                    font.pointSize: 18
                    font.bold: true
                    color: "#F7F9FC"
                }

                ListView {
                    id: listaDiscos
                    width: parent.width
                    height: 200
                    spacing: 6
                    model: [
                        { nome: "NVMe SSD", tamanho: "500 GB", tipo: "NVMe", vazio: true },
                        { nome: "SATA HDD", tamanho: "1 TB", tipo: "SATA", vazio: false },
                        { nome: "SATA SSD", tamanho: "250 GB", tipo: "SATA", vazio: true }
                    ]
                    delegate: Rectangle {
                        width: listaDiscos.width
                        height: 56
                        color: "#151b22"
                        radius: 8
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 12
                            Rectangle {
                                width: 32
                                height: 32
                                color: modelo.vazio ? "#4ADE80" : "#C42B1C"
                                radius: 16
                                Text {
                                    anchors.centerIn: parent
                                    text: modelo.vazio ? "✓" : "✗"
                                    color: "#FFFFFF"
                                    font.pointSize: 14
                                    font.bold: true
                                }
                            }
                            Text {
                                text: modelo.nome
                                font.pointSize: 14
                                color: "#CBD5E1"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: modelo.tamanho
                                font.pointSize: 12
                                color: "#94A3B8"
                            }
                            Text {
                                text: modelo.tipo
                                font.pointSize: 10
                                color: "#64748B"
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (modelo.vazio) {
                                    discoSelecionado = modelo.nome
                                    passoAtual = 1
                                }
                            }
                        }
                    }
                }
            }

            // Passo 1: Particionamento LUKS+A/B
            Column {
                visible: passoAtual === 1
                anchors.fill: parent
                spacing: 16

                Text {
                    text: "Particionamento e Criptografia"
                    font.pointSize: 18
                    font.bold: true
                    color: "#F7F9FC"
                }

                Card {
                    Layout.fillWidth: true

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Row {
                            spacing: 16
                            Text { text: "Disco alvo:"; font.pointSize: 13; color: "#64748B" }
                            Text { text: discoSelecionado; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                            Item { Layout.fillWidth: true }
                        }

                        Row {
                            spacing: 16
                            Text { text: "Criptografia LUKS2:"; font.pointSize: 13; color: "#64748B" }
                            Switch { checked: true }
                            Item { Layout.fillWidth: true }
                        }

                        Row {
                            spacing: 16
                            Text { text: "Slots A/B:"; font.pointSize: 13; color: "#64748B" }
                            Switch { checked: true }
                            Item { Layout.fillWidth: true }
                        }

                        Row {
                            spacing: 16
                            Text { text: "Tamanho Slot A:"; font.pointSize: 13; color: "#64748B" }
                            Text { text: "50%"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                            Item { Layout.fillWidth: true }
                        }
                        Row {
                            spacing: 16
                            Text { text: "Tamanho Slot B:"; font.pointSize: 13; color: "#64748B" }
                            Text { text: "50%"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                            Item { Layout.fillWidth: true }
                        }

                        Row {
                            spacing: 16
                            Text { text: "Senha LUKS:"; font.pointSize: 13; color: "#64748B" }
                            TextField {
                                width: 200
                                placeholderText: "Senha"
                                font.pointSize: 13
                                color: "#F7F9FC"
                                echoMode: TextInput.PasswordEchoOnEdit
                                background: Rectangle { color: "#0E1116"; radius: 8 }
                                onTextChanged: senhaLUKS = text
                            }
                            Item { Layout.fillWidth: true }
                        }
                        Row {
                            spacing: 16
                            Text { text: "Confirmar Senha:"; font.pointSize: 13; color: "#64748B" }
                            TextField {
                                width: 200
                                placeholderText: "Confirmar senha"
                                font.pointSize: 13
                                color: "#F7F9FC"
                                echoMode: TextInput.PasswordEchoOnEdit
                                background: Rectangle { color: "#0E1116"; radius: 8 }
                                onTextChanged: senhaConfirm = text
                            }
                            Item { Layout.fillWidth: true }
                        }
                    }
                }
            }

            // Passo 2: Usuário
            Column {
                visible: passoAtual === 2
                anchors.fill: parent
                spacing: 16

                Text {
                    text: "Criar Conta de Usuário"
                    font.pointSize: 18
                    font.bold: true
                    color: "#F7F9FC"
                }

                Row {
                    spacing: 16
                    Text { text: "Nome de usuário:"; font.pointSize: 13; color: "#64748B" }
                    TextField {
                        width: 250
                        placeholderText: "usuario"
                        font.pointSize: 13
                        color: "#F7F9FC"
                        background: Rectangle { color: "#0E1116"; radius: 8 }
                    }
                    Item { Layout.fillWidth: true }
                }
                Row {
                    spacing: 16
                    Text { text: "Senha:"; font.pointSize: 13; color: "#64748B" }
                    TextField {
                        width: 250
                        placeholderText: "Senha"
                        font.pointSize: 13
                        color: "#F7F9FC"
                        echoMode: TextInput.PasswordEchoOnEdit
                        background: Rectangle { color: "#0E1116"; radius: 8 }
                    }
                    Item { Layout.fillWidth: true }
                }
                Row {
                    spacing: 16
                    Text { text: "Confirmar senha:"; font.pointSize: 13; color: "#64748B" }
                    TextField {
                        width: 250
                        placeholderText: "Confirmar senha"
                        font.pointSize: 13
                        color: "#F7F9FC"
                        echoMode: TextInput.PasswordEchoOnEdit
                        background: Rectangle { color: "#0E1116"; radius: 8 }
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            // Passo 3: Instalação
            Column {
                visible: passoAtual === 3
                anchors.fill: parent
                spacing: 16

                Text {
                    text: "Instalando Lume OS..."
                    font.pointSize: 18
                    font.bold: true
                    color: "#F7F9FC"
                }

                ProgressBar {
                    width: parent.width
                    value: instalacaoProgresso
                }

                Text {
                    text: textoInstalacao
                    font.pointSize: 13
                    color: "#94A3B8"
                }

                Text {
                    text: tempoDecorrido + " s"
                    font.pointSize: 12
                    color: "#64748B"
                }
            }

            // Passo 4: Concluído
            Column {
                visible: passoAtual === 4
                anchors.fill: parent
                spacing: 16

                Rectangle {
                    width: 80
                    height: 80
                    color: "#4ADE80"
                    radius: 40
                    Text {
                        anchors.centerIn: parent
                        text: "✓"
                        color: "#FFFFFF"
                        font.pointSize: 36
                        font.bold: true
                    }
                }

                Text {
                    text: "Instalação Concluída!"
                    font.pointSize: 20
                    font.bold: true
                    color: "#F7F9FC"
                }

                Text {
                    text: "O Lume OS foi instalado com sucesso no disco."
                    font.pointSize: 13
                    color: "#CBD5E1"
                }

                Row {
                    spacing: 12
                    Button {
                        text: "Reiniciar Agora"
                        font.pointSize: 12
                        background: Rectangle { color: "#3E8EF7"; radius: 6 }
                        onClicked: console.log("Reiniciando sistema...")
                    }
                    Button {
                        text: "Finalizar"
                        font.pointSize: 12
                        background: Rectangle { color: "#334155"; radius: 6 }
                        onClicked: instalador.close()
                    }
                }
            }
        }

        // Botões de navegação
        Row {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            spacing: 12

            Button {
                id: btnAnterior
                text: "Anterior"
                font.pointSize: 12
                enabled: passoAtual > 0
                background: Rectangle {
                    color: passoAtual > 0 ? "#3E8EF7" : "#334155"
                    radius: 8
                }
                onClicked: passoAtual = Math.max(0, passoAtual - 1)
            }

            Item { Layout.fillWidth: true }

            Button {
                id: btnAvancar
                text: passoAtual === passos.length - 1 ? "Concluir" : "Avançar"
                font.pointSize: 12
                background: Rectangle {
                    color: "#3E8EF7"
                    radius: 8
                }
                onClicked: {
                    if (passoAtual === passos.length - 1) {
                        console.log("Instalação concluída")
                        instalador.close()
                    } else {
                        passoAtual = passoAtual + 1
                        if (passoAtual === 3) {
                            iniciarInstalacao()
                        }
                    }
                }
            }
        }
    }
}

// ==================== LÓGICA DE INSTALAÇÃO ====================

property int instalacaoProgresso: 0
property string textoInstalacao: "Iniciando instalação..."
property int tempoDecorrido: 0

function iniciarInstalacao() {
    passoAtual = 3
    instalacaoProgresso = 0
    textoInstalacao = "Preparando disco..."
    
    var timer = new Timer()
    timer.interval = 500
    timer.repeat = true
    timer.onTriggered = function() {
        instalacaoProgresso += 5
        if (instalacaoProgresso > 100) instalacaoProgresso = 100
        
        if (instalacaoProgresso < 20) textoInstalacao = "Criando partições..."
        else if (instalacaoProgresso < 40) textoInstalacao = "Formatando slots A/B..."
        else if (instalacaoProgresso < 60) textoInstalacao = "Criptografando com LUKS2..."
        else if (instalacaoProgresso < 80) textoInstalacao = "Instalando sistema base..."
        else textoInstalacao = "Finalizando instalação..."
        
        if (instalacaoProgresso >= 100) {
            timer.stop()
            textoInstalacao = "Instalação concluída!"
            passoAtual = 4
        }
    }
    timer.start()
    
    // Timer de tempo decorrido
    var tempoTimer = new Timer()
    tempoTimer.interval = 1000
    tempoTimer.repeat = true
    tempoTimer.onTriggered = function() {
        tempoDecorrido++
        if (instalacaoProgresso >= 100) tempoTimer.stop()
    }
    tempoTimer.start()
}
