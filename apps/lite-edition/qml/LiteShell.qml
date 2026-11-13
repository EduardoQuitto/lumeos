import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Shell Lite — X11 + picom para edição i386
// Otimizado para hardware fraco (P4, 1-2 GB RAM)
// Idle alvo: ≤250MB
ApplicationWindow {
    id: liteShell
    visible: true
    width: 1024
    height: 768
    color: "#0e1116"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    property string sessao: "openbox"
    property string compositor: "picom"
    property string tema: "Adwaita"
    property int memoriaIdle: 0

    // Fundo da área de trabalho
    Rectangle {
        id: fundo
        anchors.fill: parent
        color: "#0e1116"
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real intensity: 0.6
            property color tint: "#0e1116"
            fragmentShader: ""
            Rectangle { id: shaderSource; width: fundo.width; height: fundo.height; color: "transparent" }
        }
    }

    // Barra inferior estilo pílula (simplificada para Lite)
    Rectangle {
        id: barra
        width: parent.width - 16
        height: 32
        x: 8
        y: parent.height - 40
        color: "#101418"
        radius: 16
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

            // Botões rápidos (Files, Settings, Terminal)
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
                    id: relogioLite
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
            color: "#101418"
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

    // Monitor de memória (idle ≤250MB)
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            // Simulação de leitura de memória
            // Em produção, ler de /proc/meminfo
            memoriaIdle = Math.floor(Math.random() * 50) + 200 // 200-250 MB
            if (memoriaIdle > 250) {
                console.log("AVISO: Idle acima de 250MB (" + memoriaIdle + "MB)")
            }
        }
    }

    // Atualizar relógio
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            relogioLite.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    // Teclas de atalho
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape) {
            menuAplicacoes.close()
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            menuAplicacoes.open()
            event.accepted = true
        } else if (event.key === Qt.Key_T && event.modifiers === (Qt.ControlModifier | Qt.AltModifier)) {
            console.log("Abrir Terminal (Ctrl+Alt+T)")
            event.accepted = true
        }
    }
}
