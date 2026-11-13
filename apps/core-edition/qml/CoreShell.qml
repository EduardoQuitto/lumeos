import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Shell Core — amd64 com labwc+Quickshell
// Materiais: Névoa + Sólido + sombras
// Idle alvo: ≤350MB em hardware médio (amd64, <4 GB RAM)
ApplicationWindow {
    id: coreShell
    visible: true
    width: 1280
    height: 720
    color: "#0e1116"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    property string compositor: "labwc"
    property string shell: "Quickshell"
    property string materialAtual: "Névoa"
    property int memoriaIdle: 0

    // Fundo: Névoa (tint wallpaper 80%)
    Rectangle {
        id: fundo
        anchors.fill: parent
        color: "#101418"
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real intensity: 0.8
            property color tint: "#101418"
            fragmentShader: ""
            Rectangle { id: shaderSource; width: fundo.width; height: fundo.height; color: "transparent" }
        }
    }

    // Sobreposição Névoa (tint suave)
    Rectangle {
        id: nevoa
        anchors.fill: parent
        color: "#1e293b"
        opacity: 0.15
        visible: materialAtual === "Névoa"
    }

    // Sólido (sem blur, cores sólidas)
    Rectangle {
        id: solido
        anchors.fill: parent
        color: "#0e1116"
        opacity: materialAtual === "Sólido" ? 1.0 : 0.0
    }

    // Sombras (2 camadas para janelas)
    Rectangle {
        id: sombraExterna
        width: parent.width + 12
        height: parent.height + 12
        x: -6
        y: -6
        color: "#000000"
        radius: 12
        opacity: 0.3
        z: -1
    }

    Rectangle {
        id: sombraInterna
        width: parent.width + 6
        height: parent.height + 6
        x: -3
        y: -3
        color: "#000000"
        radius: 12
        opacity: 0.15
        z: -1
    }

    // Barra inferior (pílula simplificada para Core)
    Rectangle {
        id: barra
        width: parent.width - 16
        height: 36
        x: 8
        y: parent.height - 40
        color: materialAtual === "Névoa" ? "#151b22" : "#101418"
        radius: 18
        border.color: "#1e293b"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 8

            // Botão Menu
            Button {
                id: btnMenu
                width: 28
                height: 28
                text: "L"
                font.pointSize: 12
                font.bold: true
                color: "#3e8ef7"
                background: Rectangle { color: "transparent"; radius: 14 }
                onClicked: menuAplicacoes.open()
            }

            // Botões rápidos
            Button {
                width: 28
                height: 28
                text: "F"
                font.pointSize: 12
                color: "#cbd5e1"
                background: Rectangle { color: "transparent"; radius: 14 }
                onClicked: console.log("Abrir Files")
            }
            Button {
                width: 28
                height: 28
                text: "S"
                font.pointSize: 12
                color: "#cbd5e1"
                background: Rectangle { color: "transparent"; radius: 14 }
                onClicked: console.log("Abrir Settings")
            }
            Button {
                width: 28
                height: 28
                text: "T"
                font.pointSize: 12
                color: "#cbd5e1"
                background: Rectangle { color: "transparent"; radius: 14 }
                onClicked: console.log("Abrir Terminal")
            }

            Item { Layout.fillWidth: true }

            // Indicadores do sistema
            Row {
                spacing: 8
                Text {
                    text: "●●●●●"
                    font.pointSize: 11
                    color: "#4ade80"
                }
                Text {
                    text: "●●●●○ 82%"
                    font.pointSize: 11
                    color: "#4ade80"
                }
                Text {
                    text: "pt-BR"
                    font.pointSize: 11
                    color: "#cbd5e1"
                }
                Text {
                    id: relogioCore
                    text: "10:09"
                    font.pointSize: 11
                    color: "#cbd5e1"
                    font.bold: true
                }
            }

            // Botão desligar
            Button {
                id: btnDesligar
                width: 28
                height: 28
                text: "⏻"
                font.pointSize: 12
                color: "#c42b1c"
                background: Rectangle { color: "transparent"; radius: 14 }
                onClicked: console.log("Desligar")
            }
        }
    }

    // Menu de aplicativos (popup)
    Popup {
        id: menuAplicacoes
        width: 300
        height: 400
        x: 40
        y: parent.height - 420
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Rectangle {
            anchors.fill: parent
            color: materialAtual === "Névoa" ? "#101418" : "#0e1116"
            radius: 12
            border.color: "#1e293b"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Aplicativos"
                    font.pointSize: 16
                    font.bold: true
                    color: "#f7f9fc"
                }

                ListView {
                    id: listaApps
                    width: parent.width
                    height: parent.height - 60
                    spacing: 4
                    model: [
                        { nome: "Lume Files", icone: "📁", comando: "lume-files" },
                        { nome: "Lume Settings", icone: "⚙", comando: "lume-settings" },
                        { nome: "Terminal", icone: "🖥", comando: "xterm" },
                        { nome: "Editor", icone: "📝", comando: "mousepad" },
                        { nome: "Firefox ESR", icone: "🦊", comando: "firefox-esr" },
                        { nome: "VLC", icone: "🎬", comando: "vlc" },
                        { nome: "Calculadora", icone: "🧮", comando: "galculator" },
                        { nome: "Gerenciador de Tarefas", icone: "📊", comando: "htop" },
                        { nome: "Desligar", icone: "⏻", comando: "systemctl poweroff" },
                        { nome: "Reiniciar", icone: "🔄", comando: "systemctl reboot" }
                    ]
                    delegate: Rectangle {
                        width: listaApps.width
                        height: 36
                        color: "#151b22"
                        radius: 6
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 12
                            Rectangle {
                                width: 24
                                height: 24
                                color: "#3e8ef7"
                                radius: 6
                                Text {
                                    anchors.centerIn: parent
                                    text: modelo.icone
                                    color: "#ffffff"
                                    font.pointSize: 14
                                }
                            }
                            Text {
                                text: modelo.nome
                                font.pointSize: 13
                                color: "#cbd5e1"
                            }
                            Item { Layout.fillWidth: true }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("Executar: " + modelo.comando)
                                menuAplicacoes.close()
                            }
                        }
                    }
                }
            }
        }
    }

    // Seletor de material (Névoa / Sólido)
    Popup {
        id: menuMateriais
        width: 200
        height: 200
        x: parent.width - 220
        y: parent.height - 420
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Rectangle {
            anchors.fill: parent
            color: materialAtual === "Névoa" ? "#101418" : "#0e1116"
            radius: 12
            border.color: "#1e293b"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Materiais"
                    font.pointSize: 16
                    font.bold: true
                    color: "#f7f9fc"
                }

                Row {
                    spacing: 12
                    RadioButton {
                        text: "Névoa"
                        font.pointSize: 13
                        checked: materialAtual === "Névoa"
                        color: "#cbd5e1"
                        onCheckedChanged: materialAtual = "Névoa"
                    }
                    RadioButton {
                        text: "Sólido"
                        font.pointSize: 13
                        checked: materialAtual === "Sólido"
                        color: "#cbd5e1"
                        onCheckedChanged: materialAtual = "Sólido"
                    }
                }

                Row {
                    spacing: 12
                    CheckBox {
                        text: "Sombras (2 camadas)"
                        font.pointSize: 13
                        checked: true
                        color: "#cbd5e1"
                    }
                }
            }
        }
    }

    // Monitor de memória (idle ≤350MB)
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            // Simulação de leitura de memória
            // Em produção, ler de /proc/meminfo
            memoriaIdle = Math.floor(Math.random() * 50) + 300 // 300-350 MB
            if (memoriaIdle > 350) {
                console.log("AVISO: Idle acima de 350MB (" + memoriaIdle + "MB)")
            }
        }
    }

    // Atualizar relógio
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            relogioCore.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    // Teclas de atalho
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape) {
            menuAplicacoes.close()
            menuMateriais.close()
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            menuAplicacoes.open()
            event.accepted = true
        } else if (event.key === Qt.Key_M && event.modifiers === Qt.ControlModifier) {
            menuMateriais.open()
            event.accepted = true
        } else if (event.key === Qt.Key_T && event.modifiers === (Qt.ControlModifier | Qt.AltModifier)) {
            console.log("Abrir Terminal (Ctrl+Alt+T)")
            event.accepted = true
        }
    }
}
