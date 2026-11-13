import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume OOBE — Out-of-Box Experience
// Cartao central de vidro com passos:
//   idioma/teclado/rede/usuario/criptografia/tier/Essenciais
Popup {
    id: oobePanel
    width: 640
    height: 560
    modal: true
    focus: true
    closePolicy: Popup.NoEscape

    property int passoAtual: 0

    property var passos: [
        { id: "idioma",    titulo: "Idioma",    descricao: "Escolha o idioma do sistema" },
        { id: "teclado",   titulo: "Teclado",   descricao: "Selecione o layout do teclado" },
        { id: "rede",      titulo: "Rede",      descricao: "Conecte-se a uma rede Wi-Fi" },
        { id: "usuario",   titulo: "Usuario",   descricao: "Crie sua conta de usuario" },
        { id: "criptografia", titulo: "Criptografia", descricao: "Configuracao de criptografia de disco" },
        { id: "tier",      titulo: "Tier",      descricao: "Escolha a edição do Lume OS" },
        { id: "essenciais", titulo: "Essenciais", descricao: "Instale o pacote de aplicativos essenciais" }
    ]

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#0E1118"
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real intensity: 0.6
            property color tint: "#0E1118"
            fragmentShader: ""
            Rectangle { id: shaderSource; width: bg.width; height: bg.height; color: "transparent" }
        }
    }

    // Cartao central de vidro
    Rectangle {
        id: cartao
        width: 520
        height: 480
        anchors.centerIn: parent
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
            Rectangle { id: shaderSource2; width: cartao.width; height: cartao.height; color: "transparent" }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // Header do passo atual
            Column {
                spacing: 8
                Text {
                    text: passos[passoAtual].titulo
                    font.pointSize: 24
                    font.bold: true
                    color: "#3E8EF7"
                }
                Text {
                    text: passos[passoAtual].descricao
                    font.pointSize: 13
                    color: "#94A3B8"
                    wrapMode: Text.Wrap
                    width: parent.width
                }
            }

            // Conteudo do passo atual (stack)
            Stack {
                id: pilhaPassos
                anchors.fill: parent
                anchors.topMargin: 40

                // Idioma
                Column {
                    visible: passoAtual === 0
                    anchors.fill: parent
                    spacing: 16
                    Text {
                        text: "Selecionar idioma do sistema"
                        font.pointSize: 16
                        font.bold: true
                        color: "#F7F9FC"
                    }
                    ListView {
                        width: parent.width
                        height: 200
                        spacing: 6
                        model: [
                            { nome: "Português (Brasil)", codigo: "pt-BR" },
                            { nome: "English (United States)", codigo: "en-US" },
                            { nome: "Español", codigo: "es-ES" },
                            { nome: "Français", codigo: "fr-FR" }
                        ]
                        delegate: Rectangle {
                            width: listaIdiomas.width
                            height: 44
                            color: listaIdiomas.currentIndex === model.index ? "#3E8EF7" : "transparent"
                            radius: 8
                            Text {
                                anchors.centerIn: parent
                                text: modelo.nome
                                color: "#F7F9FC"
                                font.size: 13
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: listaIdiomas.currentIndex = model.index
                            }
                        }
                    }
                }

                // Teclado
                Column {
                    visible: passoAtual === 1
                    anchors.fill: parent
                    spacing: 16
                    Text {
                        text: "Selecionar layout de teclado"
                        font.pointSize: 16
                        font.bold: true
                        color: "#F7F9FC"
                    }
                    ListView {
                        width: parent.width
                        height: 200
                        spacing: 6
                        model: [
                            { nome: "Português (ABNT2)", codigo: "pt-br-abnt2" },
                            { nome: "English (US)", codigo: "en-us" },
                            { nome: "Español", codigo: "es" },
                            { nome: "Français", codigo: "fr" }
                        ]
                        delegate: Rectangle {
                            width: listaTeclado.width
                            height: 44
                            color: listaTeclado.currentIndex === model.index ? "#3E8EF7" : "transparent"
                            radius: 8
                            Text {
                                anchors.centerIn: parent
                                text: modelo.nome
                                color: "#F7F9FC"
                                font.size: 13
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: listaTeclado.currentIndex = model.index
                            }
                        }
                    }
                }

                // Rede
                Column {
                    visible: passoAtual === 2
                    anchors.fill: parent
                    spacing: 16
                    Text {
                        text: "Conectar a rede Wi-Fi"
                        font.pointSize: 16
                        font.bold: true
                        color: "#F7F9FC"
                    }
                    ListView {
                        width: parent.width
                        height: 200
                        spacing: 6
                        model: [
                            { nome: "Lume-Home", sinal: 5, seguro: true },
                            { nome: "Lume-Visitante", sinal: 3, seguro: false },
                            { nome: "Rede-Empresa", sinal: 4, seguro: true }
                        ]
                        delegate: Rectangle {
                            width: listaRedes.width
                            height: 44
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
                                    text: modelo.sinal === 5 ? "●●●●●" : (modelo.sinal === 3 ? "●●●○○" : "●●●●○")
                                    color: "#4ADE80"
                                    font.pointSize: 12
                                }
                                Text {
                                    text: modelo.seguro ? "Seguro" : "Aberto"
                                    font.pointSize: 10
                                    color: modelo.seguro ? "#4ADE80" : "#F65A8E"
                                }
                            }
                        }
                    }
                }

                // Usuario
                Column {
                    visible: passoAtual === 3
                    anchors.fill: parent
                    spacing: 16
                    Text {
                        text: "Criar conta de usuario"
                        font.pointSize: 16
                        font.bold: true
                        color: "#F7F9FC"
                    }
                    TextField {
                        width: 300
                        placeholderText: "Nome de usuario"
                        font.pointSize: 13
                        color: "#F7F9FC"
                        background: Rectangle { color: "#0E1116"; radius: 8 }
                    }
                    TextField {
                        width: 300
                        placeholderText: "Senha"
                        font.pointSize: 13
                        color: "#F7F9FC"
                        echoMode: TextInput.PasswordEchoOnEdit
                        background: Rectangle { color: "#0E1116"; radius: 8 }
                    }
                    TextField {
                        width: 300
                        placeholderText: "Confirmar senha"
                        font.pointSize: 13
                        color: "#F7F9FC"
                        echoMode: TextInput.PasswordEchoOnEdit
                        background: Rectangle { color: "#0E1116"; radius: 8 }
                    }
                }

                // Criptografia
                Column {
                    visible: passoAtual === 4
                    anchors.fill: parent
                    spacing: 16
                    Text {
                        text: "Criptografia de disco"
                        font.pointSize: 16
                        font.bold: true
                        color: "#F7F9FC"
                    }
                    Row {
                        spacing: 16
                        Text { text: "Criptografar disco:"; font.pointSize: 13; color: "#CBD5E1" }
                        Switch { checked: true }
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
                        }
                        Item { Layout.fillWidth: true }
                    }
                }

                // Tier
                Column {
                    visible: passoAtual === 5
                    anchors.fill: parent
                    spacing: 16
                    Text {
                        text: "Escolher edição do Lume OS"
                        font.pointSize: 16
                        font.bold: true
                        color: "#F7F9FC"
                    }
                    Column {
                        spacing: 8
                        Row {
                            spacing: 8
                            Rectangle {
                                width: 200
                                height: 100
                                color: "#3E8EF7"
                                radius: 12
                                Text {
                                    anchors.centerIn: parent
                                    text: "Prime"
                                    color: "#FFFFFF"
                                    font.bold: true
                                }
                            }
                            Rectangle {
                                width: 200
                                height: 100
                                color: "#1e293b"
                                radius: 12
                                Text {
                                    anchors.centerIn: parent
                                    text: "Core"
                                    color: "#CBD5E1"
                                    font.bold: true
                                }
                            }
                            Rectangle {
                                width: 200
                                height: 100
                                color: "#1e293b"
                                radius: 12
                                Text {
                                    anchors.centerIn: parent
                                    text: "Lite"
                                    color: "#CBD5E1"
                                    font.bold: true
                                }
                            }
                        }
                        Text {
                            text: "Prime: Vidro + Névoa + Sólido | idle ≤ 450 MB"
                            font.pointSize: 11
                            color: "#94A3B8"
                            width: parent.width
                            wrapMode: Text.Wrap
                        }
                        Text {
                            text: "Core: Névoa + Sólido | idle ≤ 350 MB"
                            font.pointSize: 11
                            color: "#94A3B8"
                            width: parent.width
                            wrapMode: Text.Wrap
                        }
                        Text {
                            text: "Lite: Vidro-lite + Sólido | idle ≤ 250 MB"
                            font.pointSize: 11
                            color: "#94A3B8"
                            width: parent.width
                            wrapMode: Text.Wrap
                        }
                    }
                }

                // Essenciais
                Column {
                    visible: passoAtual === 6
                    anchors.fill: parent
                    spacing: 16
                    Text {
                        text: "Pacote Essenciais"
                        font.pointSize: 16
                        font.bold: true
                        color: "#F7F9FC"
                    }
                    Row {
                        spacing: 8
                        Repeater {
                            model: [
                                { nome: "OnlyOffice", selecionado: true },
                                { nome: "WhatsApp PWA", selecionado: true },
                                { nome: "Spotify", selecionado: false },
                                { nome: "Discord", selecionado: true },
                                { nome: "Zoom", selecionado: false },
                                { nome: "Steam", selecionado: false },
                                { nome: "Brave", selecionado: false }
                            ]
                            delegate: Row {
                                spacing: 8
                                CheckBox {
                                    text: modelo.nome
                                    checked: modelo.selecionado
                                    color: "#3E8EF7"
                                }
                            }
                        }
                    }
                }
            }

            // Botoes de navegacao
            Row {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 16
                spacing: 12

                Button {
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
                    text: passoAtual === passos.length - 1 ? "Concluir" : "Avançar"
                    font.pointSize: 12
                    background: Rectangle {
                        color: "#3E8EF7"
                        radius: 8
                    }
                    onClicked: {
                        if (passoAtual === passos.length - 1) {
                            console.log("OOBE concluido")
                            oobePanel.close()
                        } else {
                            passoAtual = passoAtual + 1
                        }
                    }
                }
            }
        }
    }
}
