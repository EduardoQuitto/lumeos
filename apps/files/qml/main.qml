import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Files — gerenciador de arquivos
// Requisitos fase 8: toolbar, breadcrumb editavel, abas, busca rg,
// grade/lista, sidebar lugares/dispositivos/lixo, drag-drop,
// extraccao p7zip, propriedades, udisks2
ApplicationWindow {
    id: root
    visible: true
    width: 1000
    height: 700
    title: "Lume Files"
    color: "#0E1116"

    // Estado da aplicacao
    property string caminhoAtual: "/home/usuario"
    property int abaAtiva: 0
    property string modoExibicao: "grade" // "grade" ou "lista"
    property string termoBusca: ""
    property bool lixoAberto: false

    // ==================== TOOLBAR ====================
    ToolBar {
        id: toolbar
        width: parent.width
        padding: 8
        spacing: 8
        style: ToolBar { }

        // Voltar / Avancar
        ToolButton {
            id: btnVoltar
            text: "◀"
            font.pointSize: 14
            enabled: false
            toolTip: "Voltar"
            onClicked: caminhoAtual = "../"
        }
        ToolButton {
            id: btnAvancar
            text: "▶"
            font.pointSize: 14
            enabled: false
            toolTip: "Avancar"
        }

        Separator { }

        // Criar pasta / novo arquivo
        ToolButton {
            id: btnNovo
            text: "Novo"
            font.pointSize: 12
            toolTip: "Nova pasta ou arquivo"
            onClicked: console.log("Criar novo item")
        }
        Menu {
            id: menuNovo
            parent: btnNovo
            MenuItem { text: "Nova pasta"; onClicked: console.log("Nova pasta") }
            MenuItem { text: "Novo documento"; onClicked: console.log("Novo documento") }
        }
        btnNovo.popup = menuNovo

        Separator { }

        // Recortar / Copiar / Colar
        ToolButton { id: btnRecortar; text: "✂"; font.pointSize: 14; toolTip: "Recortar"; enabled: false }
        ToolButton { id: btnCopiar; text: "📋"; font.pointSize: 14; toolTip: "Copiar"; enabled: false }
        ToolButton { id: btnColar; text: "📥"; font.pointSize: 14; toolTip: "Colar"; enabled: false }

        Separator { }

        // Excluir / Lixeira
        ToolButton {
            id: btnExcluir
            text: "🗑"
            font.pointSize: 14
            toolTip: "Excluir / Mover para lixeira"
            enabled: false
            onClicked: console.log("Mover para lixeira")
        }
        ToolButton {
            id: btnLixeira
            text: "🗑"
            font.pointSize: 16
            toolTip: "Lixeira"
            onClicked: { lixoAberto = true; caminhoAtual = "trash:///" }
        }

        Item { width: 1; height: 1; Layout.fillWidth: true }

        // Modo de exibicao
        ToolButton {
            id: btnGrade
            text: "📐"
            font.pointSize: 14
            checkable: true
            checked: modoExibicao === "grade"
            toolTip: "Exibicao em grade"
            onClicked: modoExibicao = "grade"
        }
        ToolButton {
            id: btnLista
            text: "📋"
            font.pointSize: 14
            checkable: true
            checked: modoExibicao === "lista"
            toolTip: "Exibicao em lista"
            onClicked: modoExibicao = "lista"
        }

        Separator { }

        // Busca (rg)
        TextField {
            id: campoBusca
            placeholderText: "Buscar arquivos..."
            font.pointSize: 12
            width: 200
            onTextChanged: termoBusca = text
        }
        Button {
            text: "Buscar"
            font.pointSize: 12
            onClicked: console.log("Buscar com rg: " + campoBusca.text)
        }
    }

    // ==================== CONTENTO PRINCIPAL ====================
    Row {
        id: conteudo
        anchors.fill: parent
        anchors.topMargin: toolbar.height
        spacing: 0

        // ==================== SIDEBAR ====================
        Rectangle {
            id: sidebar
            width: 240
            color: "#101418"
            border.color: "#1e293b"
            border.width: 1

            ListView {
                id: listaSidebar
                anchors.fill: parent
                spacing: 4
                model: [
                    { nome: "Lugar Inicial", icone: "🏠", tipo: "lugar" },
                    { nome: "Documentos", icone: "📄", tipo: "lugar" },
                    { nome: "Downloads", icone: "⬇", tipo: "lugar" },
                    { nome: "Imagens", icone: "🖼", tipo: "lugar" },
                    { nome: "Musica", icone: "🎵", tipo: "lugar" },
                    { nome: "Videos", icone: "🎬", tipo: "lugar" },
                    Separator { },
                    { nome: "Dispositivos", icone: "💾", tipo: "cabecalho" },
                    { nome: "USB Drive", icone: "🔌", tipo: "dispositivo", montado: false },
                    { nome: "Disco HD", icone: "💿", tipo: "dispositivo", montado: true },
                    Separator { },
                    { nome: "Lixeira", icone: "🗑", tipo: "lixo", itens: 5 }
                ]
                delegate: Row {
                    width: listaSidebar.width
                    height: 40
                    spacing: 10
                    Text { text: modelo.icone; font.pointSize: 16; width: 30 }
                    Text {
                        text: modelo.nome
                        font.pointSize: 13
                        color: modelo.tipo === "lixo" ? "#F65A8E" : (modelo.tipo === "dispositivo" && !modelo.montado ? "#94A3B8" : "#CBD5E1")
                        elide: Text.ElideRight
                    }
                    Item { width: 1; height: 1; Layout.fillWidth: true }
                    modelo.tipo === "dispositivo" && !modelo.montado ? Text { text: "montar"; font.pointSize: 10; color: "#3E8EF7" } : Item {}
                }
                onClicked: {
                    if (modelo.tipo === "dispositivo" && !modelo.montado) {
                        console.log("Montar dispositivo via udisks2: " + modelo.nome)
                        modelo.montado = true
                    } else if (modelo.tipo === "lixo") {
                        lixoAberto = true
                        caminhoAtual = "trash:///"
                    } else {
                        caminhoAtual = modelo.nome
                    }
                }
            }
        }

        Separator { }

        // ==================== AREA PRINCIPAL (breadcrumb + abas + conteudo) ====================
        Column {
            id: areaPrincipal
            width: parent.width - 241
            height: parent.height

            // Breadcrumb (editavel)
            Rectangle {
                id: areaBreadcrumb
                width: parent.width
                height: 36
                color: "#151b22"
                border.color: "#1e293b"
                border.width: 1
                radius: 8

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Text {
                        text: caminhoAtual
                        font.pointSize: 12
                        color: "#3E8EF7"
                        elide: Text.ElideLeft
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Item { width: 1; height: 1; Layout.fillWidth: true }
                    Button {
                        id: btnEditarBreadcrumb
                        text: "Editar caminho"
                        font.pointSize: 11
                        toolTip: "Editar caminho diretamente"
                        onClicked: campoCaminho.visible = true
                    }
                }

                // Campo de edicao do caminho (aparece ao clicar editar)
                TextField {
                    id: campoCaminho
                    visible: false
                    anchors.fill: parent
                    anchors.margins: 6
                    text: caminhoAtual
                    font.pointSize: 12
                    onAccepted: {
                        caminhoAtual = text
                        campoCaminho.visible = false
                    }
                    onEditingFinished: campoCaminho.visible = false
                }
            }

            // Abas
            TabBar {
                id: abas
                width: parent.width
                currentIndex: abaAtiva
                model: ["Downloads", "Documentos", "Imagens"]
                onCurrentIndexChanged: abaAtiva = index
                TabButton {
                    text: "Nova aba"
                    font.pointSize: 11
                    onClicked: abas.model.insert(abas.count, "Nova aba")
                }
            }

            // Conteudo (grade ou lista)
            Stack {
                id: pilhaConteudo
                width: parent.width
                height: parent.height - areaBreadcrumb.height - abas.height

                // Visualizacao em grade
                GridView {
                    id: gradeArquivos
                    width: parent.width
                    height: parent.height
                    cellWidth: 120
                    cellHeight: 120
                    spacing: 12
                    model: [
                        { nome: "Projetos", tipo: "pasta", icone: "📁" },
                        { nome: "Music", tipo: "pasta", icone: "📁" },
                        { nome: "Assets", tipo: "pasta", icone: "📁" },
                        { nome: "documento.pdf", tipo: "arquivo", icone: "📄" },
                        { nome: "foto.jpg", tipo: "arquivo", icone: "🖼" },
                        { nome: "musica.mp3", tipo: "arquivo", icone: "🎵" },
                        { nome: "video.mp4", tipo: "arquivo", icone: "🎬" },
                        { nome: "arquivo.zip", tipo: "compactado", icone: "📦" }
                    ]
                    delegate: Rectangle {
                        width: 120
                        height: 120
                        color: "#151b22"
                        radius: 12
                        border.color: "#1e293b"
                        border.width: 1
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            Rectangle {
                                width: 48
                                height: 48
                                color: modelo.tipo === "pasta" ? "#3E8EF7" : (modelo.tipo === "compactado" ? "#9D7BFA" : "#F65A8E")
                                radius: 10
                                Text {
                                    anchors.centerIn: parent
                                    text: modelo.icone
                                    font.pointSize: 20
                                }
                            }
                            Text {
                                text: modelo.nome
                                font.pointSize: 11
                                color: "#CBD5E1"
                                horizontalAlignment: Text.AlignHCenter
                                width: 100
                                wrapMode: Text.Wrap
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (modelo.tipo === "pasta") {
                                    caminhoAtual = caminhoAtual + "/" + modelo.nome
                                    console.log("Abrir pasta: " + modelo.nome)
                                } else if (modelo.tipo === "compactado") {
                                    console.log("Extrair com p7zip: " + modelo.nome)
                                } else {
                                    console.log("Abrir arquivo: " + modelo.nome)
                                }
                            }
                            onPressed: (mouse) => { parent.color = "#1e293b" }
                            onReleased: (mouse) => { parent.color = "#151b22" }
                        }
                    }
                }

                // Visualizacao em lista
                ListView {
                    id: listaArquivos
                    width: parent.width
                    height: parent.height
                    spacing: 2
                    model: gradeArquivos.model
                    delegate: Rectangle {
                        width: listaArquivos.width
                        height: 36
                        color: ListView.isCurrentItem ? "#3E8EF7" : "#151b22"
                        Row {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 12
                            Text { text: modelo.icone; font.pointSize: 14; width: 30 }
                            Column {
                                spacing: 2
                                Text { text: modelo.nome; font.pointSize: 12; color: "#CBD5E1" }
                                Text { text: modelo.tipo === "pasta" ? "Pasta" : "Arquivo"; font.pointSize: 10; color: "#94A3B8" }
                            }
                            Item { width: 1; height: 1; Layout.fillWidth: true }
                            Text { text: modelo.tipo === "compactado" ? "Extrair com p7zip" : "-"; font.pointSize: 10; color: "#94A3B8" }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: listaArquivos.currentIndex = index
                        }
                    }
                }
            }
        }
    }

    // ==================== PAINEL DE PROPRIEDADES ====================
    Rectangle {
        id: painelPropriedades
        width: 300
        height: parent.height
        x: parent.width // fora da tela por padrão
        y: 0
        color: "#101418"
        border.color: "#1e293b"
        border.width: 1
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real blur: 8
            fragmentShader: ""
            Rectangle { id: shaderSource; width: painelPropriedades.width; height: painelPropriedades.height; color: "transparent" }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "Propriedades"
                font.pointSize: 16
                font.bold: true
                color: "#F7F9FC"
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#1e293b"
            }

            Text {
                text: "Nome: documento.pdf"
                font.pointSize: 13
                color: "#CBD5E1"
            }
            Text {
                text: "Tipo: Arquivo PDF"
                font.pointSize: 13
                color: "#CBD5E1"
            }
            Text {
                text: "Tamanho: 2,4 MB"
                font.pointSize: 13
                color: "#CBD5E1"
            }
            Text {
                text: "Local: /home/usuario/Documentos"
                font.pointSize: 13
                color: "#CBD5E1"
            }
            Text {
                text: "Criado: 12/11/2026 10:00"
                font.pointSize: 13
                color: "#CBD5E1"
            }
            Text {
                text: "Modificado: 12/11/2026 10:30"
                font.pointSize: 13
                color: "#CBD5E1"
            }

            Item { height: 1; Layout.fillHeight: true }

            Button {
                Layout.fillWidth: true
                text: "Abrir com..."
                font.pointSize: 12
                background: Rectangle { color: "#334155"; radius: 6 }
            }
            Button {
                Layout.fillWidth: true
                text: "Extrair aqui (p7zip)"
                font.pointSize: 12
                color: "#9D7BFA"
                background: Rectangle { color: "#1e293b"; radius: 6 }
                visible: false // so para arquivos compactados
            }
            Button {
                Layout.fillWidth: true
                text: "Fechar propriedades"
                font.pointSize: 12
                color: "#C42B1C"
                background: Rectangle { color: "transparent"; radius: 6 }
                onClicked: painelPropriedades.x = parent.width
            }
        }
    }

    // Atalhos de teclado
    Keys.onPressed: {
        if (event.key === Qt.Key_F && event.modifiers === Qt.ControlModifier) {
            campoBusca.focus = true
            event.accepted = true
        } else if (event.key === Qt.Key_L && event.modifiers === Qt.ControlModifier) {
            campoCaminho.visible = true
            campoCaminho.focus = true
            event.accepted = true
        } else if (event.key === Qt.Key_Delete) {
            console.log("Mover item selecionado para lixeira")
            event.accepted = true
        }
    }
}
