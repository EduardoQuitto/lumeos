import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Pendrive Persistente
// Requisitos fase 16:
//   - Criador USB LUKS
//   - Backup/restore
//   - Instalação em pendrive persistente
ApplicationWindow {
    id: pendriveWindow
    visible: true
    width: 800
    height: 600
    title: "Lume Pendrive Persistente"
    color: "#0E1116"

    property int passoAtual: 0
    property string pendriveSelecionado: ""
    property string senhaLUKS: ""
    property string senhaConfirm: ""

    property var passos: [
        { id: "selecao",    titulo: "Selecionar Pendrive",    descricao: "Escolha o pendrive para persistência" },
        { id: "criptografia",  titulo: "Criptografar",        descricao: "Criar pendrive LUKS2" },
        { id: "instalacao",    titulo: "Instalar SO",         descricao: "Instalar Lume OS no pendrive" },
        { id: "backup",         titulo: "Backup/Restore",     descricao: "Backup e restauração de dados" },
        { id: "conclusao",      titulo: "Concluído",          descricao: "Pendrive persistente pronto" }
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

        Row {
            spacing: 16
            Rectangle {
                width: 48
                height: 48
                color: "#3E8EF7"
                radius: 24
                Text {
                    anchors.centerIn: parent
                    text: "💾"
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
            width: parent.width
            height: 1
            color: "#1e293b"
        }

        Stack {
            id: pilhaPassos
            anchors.fill: parent
            anchors.topMargin: 24
            anchors.bottomMargin: 24
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            // Passo 0: Selecionar Pendrive
            Column {
                visible: passoAtual === 0
                anchors.fill: parent
                spacing: 16

                Text {
                    text: "Selecionar Pendrive"
                    font.pointSize: 18
                    font.bold: true
                    color: "#F7F9FC"
                }

                ListView {
                    id: listaPendrives
                    width: parent.width
                    height: 200
                    spacing: 6
                    model: [
                        { nome: "USB Drive 1", tamanho: "32 GB", tipo: "USB 3.0", vazio: true },
                        { nome: "USB Drive 2", tamanho: "64 GB", tipo: "USB 3.1", vazio: true },
                        { nome: "USB Drive 3", tamanho: "16 GB", tipo: "USB 2.0", vazio: false }
                    ]
                    delegate: Rectangle {
                        width: listaPendrives.width
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
                                    pendriveSelecionado = modelo.nome
                                    passoAtual = 1
                                }
                            }
                        }
                    }
                }
            }

            // Passo 1: Criptografia LUKS
            Column {
                visible: passoAtual === 1
                anchors.fill: parent
                spacing: 16

                Text {
                    text: "Criptografar Pendrive (LUKS2)"
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
                            Text { text: "Pendrive:"; font.pointSize: 13; color: "#64748B" }
                            Text { text: pendriveSelecionado; font.pointSize: 13; color: "#0E1116"; font.bold: true }
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
                            Text { text: "Senha:"; font.pointSize: 13; color: "#64748B" }
                            TextField {
                                width: 250
                                placeholderText: "Senha LUKS"
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
                            Text { text: "Confirmar:"; font.pointSize: 13; color: "#64748B" }
                            TextField {
                                width: 250
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

            // Passo 2: Instalar SO
            Column {
                visible: passoAtual === 2
                anchors.fill: parent
                spacing: 16

                Text {
                    text: "Instalar Lume OS no Pendrive"
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
                            Text { text: "Pendrive destino:"; font.pointSize: 13; color: "#64748B" }
                            Text { text: pendriveSelecionado; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                            Item { Layout.fillWidth: true }
                        }

                        Row {
                            spacing: 16
                            Text { text: "ISO origem:"; font.pointSize: 13; color: "#64748B" }
                            Text { text: "lume-amd64.iso"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                            Item { Layout.fillWidth: true }
                        }

                        Row {
                            spacing: 16
                            Text { text: "Persistence size:"; font.pointSize: 13; color: "#64748B" }
                            Text { text: "50% do espaço livre"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                            Item { Layout.fillWidth: true }
                        }
                    }
                }
            }

            // Passo 3: Backup/Restore
            Column {
                visible: passoAtual === 3
                anchors.fill: parent
                spacing: 16

                Text {
                    text: "Backup e Restauração"
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

                        Text {
                            text: "Gerenciar dados persistentes no pendrive"
                            font.pointSize: 13
                            color: "#64748B"
                        }

                        Row {
                            spacing: 8
                            Button {
                                text: "Fazer Backup"
                                font.pointSize: 12
                                background: Rectangle { color: "#3E8EF7"; radius: 6 }
                                onClicked: console.log("Fazer backup do pendrive")
                            }
                            Button {
                                text: "Restaurar Backup"
                                font.pointSize: 12
                                background: Rectangle { color: "#9D7BFA"; radius: 6 }
                                onClicked: console.log("Restaurar backup do pendrive")
                            }
                            Item { Layout.fillWidth: true }
                        }

                        ListView {
                            width: parent.width
                            height: 150
                            spacing: 4
                            model: [
                                { nome: "backup_2026_11_12_10_00.tar.gz", data: "12/11/2026", tamanho: "2.4 GB" },
                                { nome: "backup_2026_11_10_14_30.tar.gz", data: "10/11/2026", tamanho: "1.8 GB" }
                            ]
                            delegate: Rectangle {
                                width: listaBackups.width
                                height: 40
                                color: "#151b22"
                                radius: 8
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 12
                                    Text {
                                        text: modelo.nome
                                        font.pointSize: 12
                                        color: "#CBD5E1"
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: modelo.data
                                        font.pointSize: 11
                                        color: "#94A3B8"
                                    }
                                    Text {
                                        text: modelo.tamanho
                                        font.pointSize: 11
                                        color: "#9D7BFA"
                                    }
                                }
                            }
                        }
                    }
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
                    text: "Pendrive Persistente Pronto!"
                    font.pointSize: 20
                    font.bold: true
                    color: "#F7F9FC"
                }

                Text {
                    text: "O Lume OS está instalado e configurado no pendrive."
                    font.pointSize: 13
                    color: "#CBD5E1"
                }

                Row {
                    spacing: 12
                    Button {
                        text: "Ejetar com Segurança"
                        font.pointSize: 12
                        background: Rectangle { color: "#3E8EF7"; radius: 6 }
                        onClicked: console.log("Ejetando pendrive...")
                    }
                    Button {
                        text: "Finalizar"
                        font.pointSize: 12
                        background: Rectangle { color: "#334155"; radius: 6 }
                        onClicked: pendriveWindow.close()
                    }
                }
            }
        }

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
                        console.log("Finalizando criação do pendrive")
                        pendriveWindow.close()
                    } else {
                        passoAtual = passoAtual + 1
                    }
                }
            }
        }
    }
}
