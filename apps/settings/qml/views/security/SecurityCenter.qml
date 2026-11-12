import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Lume Settings — Central de Segurança (fase 10)
// 8 páginas + Central de Segurança com checklist Shield
// Checklist: verity, lockdown, AppArmor, seccomp, nftables, TPM2
ApplicationWindow {
    id: root
    visible: true
    width: 1100
    height: 750
    title: "Lume Settings — Segurança"
    color: "#0E1116"

    property string paginaAtual: "shield"

    // ==================== NAVEGAÇÃO ESQUERDA (240px vidro-lite) ====================
    Rectangle {
        id: navEsquerda
        width: 240
        height: parent.height
        color: "#101418"
        border.color: "#1e293b"
        border.width: 1
        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: shaderSource
            property real intensity: 0.6
            property color tint: "#101418"
            fragmentShader: ""
            Rectangle { id: shaderSource; width: navEsquerda.width; height: navEsquerda.height; color: "transparent" }
        }

        Column {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                width: parent.width
                height: 64
                color: "#0a0c0f"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Rectangle {
                        width: 32
                        height: 32
                        color: "#C42B1C"
                        radius: 8
                        Text {
                            anchors.centerIn: parent
                            text: "S"
                            color: "#FFFFFF"
                            font.pointSize: 16
                            font.bold: true
                        }
                    }

                    Text {
                        text: "Segurança"
                        font.pointSize: 16
                        font.bold: true
                        color: "#F7F9FC"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }

            ListView {
                id: listaPaginas
                width: parent.width
                height: parent.height - 64
                spacing: 2
                model: [
                    { id: "shield", icone: "🛡", nome: "Central de Segurança" },
                    { id: "firewall", icone: "🧱", nome: "Firewall" },
                    { id: "sandbox",  icone: "🔒", nome: "Sandbox" },
                    { id: "cofre",    icone: "🏦", nome: "Modo Cofre" },
                    { id: "live",     icone: "⚠",  nome: "Modo Live" },
                    { id: "sistema",  icone: "💻", nome: "Sistema" },
                    { id: "tela",     icone: "🖥", nome: "Tela" },
                    { id: "som",      icone: "🔊", nome: "Som" }
                ]
                delegate: Rectangle {
                    width: listaPaginas.width
                    height: 48
                    color: listaPaginas.currentIndex === index ? "#C42B1C" : "transparent"
                    radius: listaPaginas.currentIndex === index ? 8 : 0
                    border.color: listaPaginas.currentIndex === index ? "#F65A8E" : "transparent"
                    border.width: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            text: modelo.icone
                            font.pointSize: 16
                            color: listaPaginas.currentIndex === index ? "#FFFFFF" : "#94A3B8"
                        }

                        Text {
                            text: modelo.nome
                            font.pointSize: 13
                            color: listaPaginas.currentIndex === index ? "#FFFFFF" : "#CBD5E1"
                        }

                        Item { Layout.fillWidth: true }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.paginaAtual = modelo.id
                            listaPaginas.currentIndex = index
                        }
                    }
                }
            }
        }
    }

    // ==================== CONTEÚDO ====================
    Rectangle {
        id: conteudo
        x: navEsquerda.width
        width: parent.width - navEsquerda.width
        height: parent.height
        color: "#F7F9FC"

        Text {
            id: tituloPagina
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 24
            anchors.leftMargin: 24
            text: paginaAtual === "shield"    ? "Central de Segurança" :
                  paginaAtual === "firewall"  ? "Firewall" :
                  paginaAtual === "sandbox"   ? "Inspetor Sandbox" :
                  paginaAtual === "cofre"     ? "Modo Cofre" :
                  paginaAtual === "live"      ? "Modo Live" :
                  paginaAtual === "sistema"   ? "Sistema" :
                  paginaAtual === "tela"      ? "Tela" :
                  paginaAtual === "som"       ? "Som" : "Segurança"
            font.pointSize: 24
            font.bold: true
            color: "#0E1116"
        }

        Stack {
            id: paginas
            anchors.top: tituloPagina.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            anchors.bottomMargin: 24

            // --- Página: Central de Segurança (Shield Checklist) ---
            Rectangle {
                id: paginaShield
                color: "#F7F9FC"
                visible: root.paginaAtual === "shield"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Text {
                                text: "Lume Shield — Checklist de Segurança"
                                font.pointSize: 18
                                font.bold: true
                                color: "#0E1116"
                            }

                            Text {
                                text: "Verifique o status de cada camada de proteção do sistema."
                                font.pointSize: 13
                                color: "#64748B"
                            }

                            // Checklist Shield
                            Column {
                                id: checklistShield
                                spacing: 10

                                ChecklistItem {
                                    titulo: "Verity (slots imutáveis)"
                                    descricao: "Verificação de integridade dos slots A/B do SO"
                                    estado: "ativo"
                                    nivel: "critico"
                                }
                                ChecklistItem {
                                    titulo: "Lockdown (integridade)"
                                    descricao: "Secure Boot com módulos assinados (B/C)"
                                    estado: "ativo"
                                    nivel: "critico"
                                }
                                ChecklistItem {
                                    titulo: "AppArmor (enforce)"
                                    descricao: "Controle de acesso obrigatório para daemons"
                                    estado: "ativo"
                                    nivel: "alto"
                                }
                                ChecklistItem {
                                    titulo: "seccomp (daemons)"
                                    descricao: "Filtro de chamadas do sistema nos serviços Rust"
                                    estado: "ativo"
                                    nivel: "alto"
                                }
                                ChecklistItem {
                                    titulo: "nftables (firewall)"
                                    descricao: "Default-deny de entrada na rede"
                                    estado: "ativo"
                                    nivel: "alto"
                                }
                                ChecklistItem {
                                    titulo: "TPM2 (opcional)"
                                    descricao: "Módulo de plataforma confiável (off padrão)"
                                    estado: "desativado"
                                    nivel: "baixo"
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#e2e8f0"
                                Layout.topMargin: 8
                                Layout.bottomMargin: 8
                            }

                            Row {
                                spacing: 12
                                Text {
                                    text: "Nível geral de segurança:"
                                    font.pointSize: 13
                                    color: "#64748B"
                                }
                                Rectangle {
                                    width: 100
                                    height: 24
                                    radius: 12
                                    color: "#4ADE80"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Alto"
                                        font.pointSize: 11
                                        font.bold: true
                                        color: "#0E1116"
                                    }
                                }
                                Item { Layout.fillWidth: true }
                                Button {
                                    text: "Aplicar todas"
                                    font.pointSize: 12
                                    background: Rectangle { color: "#3E8EF7"; radius: 6 }
                                    onClicked: console.log("Aplicar todas as configurações de segurança")
                                }
                            }
                        }
                    }
                }
            }

            // --- Página: Firewall (nftables) ---
            Rectangle {
                id: paginaFirewall
                color: "#F7F9FC"
                visible: root.paginaAtual === "firewall"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Firewall (nftables)"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Estado do firewall:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: true }
                                Item { Layout.fillWidth: true }
                            }

                            Row {
                                spacing: 16
                                Text { text: "Política de entrada:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "default-deny"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                                Item { Layout.fillWidth: true }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#e2e8f0"
                                Layout.topMargin: 8
                                Layout.bottomMargin: 8
                            }

                            Text {
                                text: "Regras de entrada"
                                font.pointSize: 14
                                font.bold: true
                                color: "#0E1116"
                            }

                            ListView {
                                id: listaRegras
                                width: parent.width
                                height: 200
                                spacing: 4
                                model: [
                                    { nome: "SSH (22)", protocolo: "tcp", porta: "22", estado: "permitido" },
                                    { nome: "DNS (53)", protocolo: "udp", porta: "53", estado: "permitido" },
                                    { nome: "HTTP (80)", protocolo: "tcp", porta: "80", estado: "bloqueado" },
                                    { nome: "HTTPS (443)", protocolo: "tcp", porta: "443", estado: "bloqueado" },
                                    { nome: "WireGuard", protocolo: "udp", porta: "51820", estado: "permitido" }
                                ]
                                delegate: Rectangle {
                                    width: listaRegras.width
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
                                        Text {
                                            text: modelo.protocolo + " " + modelo.porta
                                            font.pointSize: 11
                                            color: "#94A3B8"
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: modelo.estado
                                            font.pointSize: 11
                                            color: modelo.estado === "permitido" ? "#4ADE80" : "#C42B1C"
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Adicionar regra"
                                font.pointSize: 14
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 8
                                TextField {
                                    placeholderText: "Nome da regra"
                                    font.pointSize: 12
                                    width: 150
                                }
                                TextField {
                                    placeholderText: "Porta"
                                    font.pointSize: 12
                                    width: 80
                                }
                                Button {
                                    text: "Adicionar"
                                    font.pointSize: 12
                                    background: Rectangle { color: "#3E8EF7"; radius: 6 }
                                }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }

            // --- Página: Inspetor Sandbox ---
            Rectangle {
                id: paginaSandbox
                color: "#F7F9FC"
                visible: root.paginaAtual === "sandbox"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Inspetor Sandbox"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Text {
                                text: "Inspecione o isolamento de aplicações e daemons do sistema."
                                font.pointSize: 13
                                color: "#64748B"
                            }

                            ListView {
                                id: listaSandbox
                                width: parent.width
                                height: 400
                                spacing: 4
                                model: [
                                    { nome: "lume-detect", tipo: "daemon", isolamento: "seccomp+AppArmor", nivel: "alto" },
                                    { nome: "lume-updated", tipo: "daemon", isolamento: "seccomp+AppArmor", nivel: "alto" },
                                    { nome: "lume-shield", tipo: "daemon", isolamento: "seccomp+AppArmor", nivel: "alto" },
                                    { nome: "lume-filesd", tipo: "daemon", isolamento: "seccomp+AppArmor", nivel: "alto" },
                                    { nome: "lume-stored", tipo: "daemon", isolamento: "seccomp+AppArmor", nivel: "alto" },
                                    { nome: "lume-cli", tipo: "CLI", isolamento: "sem isolamento", nivel: "baixo" },
                                    { nome: "Lume Files (app)", tipo: "app", isolamento: "Flatpak", nivel: "medio" },
                                    { nome: "Terminal", tipo: "app", isolamento: "sem isolamento", nivel: "baixo" }
                                ]
                                delegate: Rectangle {
                                    width: listaSandbox.width
                                    height: 48
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
                                        Text {
                                            text: modelo.tipo
                                            font.pointSize: 11
                                            color: "#94A3B8"
                                        }
                                        Item { Layout.fillWidth: true }
                                        Column {
                                            spacing: 2
                                            Text { text: modelo.isolamento; font.pointSize: 11; color: "#94A3B8" }
                                            Text { text: modelo.nivel; font.pointSize: 10; color: modelo.nivel === "alto" ? "#4ADE80" : (modelo.nivel === "medio" ? "#F65A8E" : "#C42B1C") }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // --- Página: Modo Cofre ---
            Rectangle {
                id: paginaCofre
                color: "#F7F9FC"
                visible: root.paginaAtual === "cofre"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Modo Cofre"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Text {
                                text: "MicroVM descartável para abrir apps de risco sem deixar resíduo."
                                font.pointSize: 13
                                color: "#64748B"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Modo Cofre:"; font.pointSize: 13; color: "#64748B" }
                                Switch { checked: false }
                                Item { Layout.fillWidth: true }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#e2e8f0"
                                Layout.topMargin: 8
                                Layout.bottomMargin: 8
                            }

                            Text {
                                text: "Requisitos"
                                font.pointSize: 14
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Edição:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Prime (C)"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "RAM mínima:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "8 GB"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Arquitetura:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "amd64"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#e2e8f0"
                                Layout.topMargin: 8
                                Layout.bottomMargin: 8
                            }

                            Text {
                                text: "Aplicativos permitidos no Cofre"
                                font.pointSize: 14
                                font.bold: true
                                color: "#0E1116"
                            }

                            ListView {
                                id: listaCofre
                                width: parent.width
                                height: 150
                                spacing: 4
                                model: [
                                    { nome: "Navegador (risco médio)", status: "permitido" },
                                    { nome: "Cliente SSH (risco médio)", status: "permitido" },
                                    { nome: "Cliente FTP (risco alto)", status: "bloqueado" },
                                    { nome: "Cliente Torrent (risco alto)", status: "bloqueado" }
                                ]
                                delegate: Rectangle {
                                    width: listaCofre.width
                                    height: 36
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
                                            text: modelo.status
                                            font.pointSize: 11
                                            color: modelo.status === "permitido" ? "#4ADE80" : "#C42B1C"
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Ação"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "Abrir app de risco no Cofre"
                                font.pointSize: 13
                                background: Rectangle { color: "#C42B1C"; radius: 8 }
                                onClicked: console.log("Abrir app no modo Cofre")
                            }
                        }
                    }
                }
            }

            // --- Página: Modo Live ---
            Rectangle {
                id: paginaLive
                color: "#F7F9FC"
                visible: root.paginaAtual === "live"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        color: "#FFF3CD"
                        border.color: "#F65A8E"
                        border.width: 1
                        radius: 12

                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 16

                            Row {
                                spacing: 12
                                Rectangle {
                                    width: 48
                                    height: 48
                                    color: "#C42B1C"
                                    radius: 24
                                    Text {
                                        anchors.centerIn: parent
                                        text: "⚠"
                                        color: "#FFFFFF"
                                        font.pointSize: 24
                                    }
                                }
                                Column {
                                    spacing: 4
                                    Text {
                                        text: "Modo Live Ativo"
                                        font.pointSize: 18
                                        font.bold: true
                                        color: "#C42B1C"
                                    }
                                    Text {
                                        text: "Você está executando o Lume OS a partir de um pendrive live."
                                        font.pointSize: 13
                                        color: "#0E1116"
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#F65A8E"
                                Layout.topMargin: 8
                                Layout.bottomMargin: 8
                            }

                            Column {
                                spacing: 8
                                Text {
                                    text: "⚠ Alterações feitas neste modo não serão persistentes após reiniciar."
                                    font.pointSize: 13
                                    color: "#0E1116"
                                    wrapMode: Text.Wrap
                                    width: parent.width
                                }
                                Text {
                                    text: "⚠ Use o instalador HD para instalar o Lume OS permanentemente."
                                    font.pointSize: 13
                                    color: "#0E1116"
                                    wrapMode: Text.Wrap
                                    width: parent.width
                                }
                                Text {
                                    text: "⚠ Criptografia de disco não está ativa no modo live."
                                    font.pointSize: 13
                                    color: "#0E1116"
                                    wrapMode: Text.Wrap
                                    width: parent.width
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#F65A8E"
                                Layout.topMargin: 8
                                Layout.bottomMargin: 8
                            }

                            Row {
                                spacing: 12
                                Button {
                                    text: "Instalar no HD"
                                    font.pointSize: 13
                                    background: Rectangle { color: "#C42B1C"; radius: 8 }
                                    onClicked: console.log("Abrir instalador HD")
                                }
                                Button {
                                    text: "Criar pendrive persistente"
                                    font.pointSize: 13
                                    background: Rectangle { color: "#3E8EF7"; radius: 8 }
                                    onClicked: console.log("Abrir criador de pendrive persistente")
                                }
                                Item { Layout.fillWidth: true }
                                Button {
                                    text: "Entendi"
                                    font.pointSize: 13
                                    background: Rectangle { color: "transparent"; radius: 8 }
                                    onClicked: console.log("Aviso de modo live descartado")
                                }
                            }
                        }
                    }
                }
            }

            // --- Página: Sistema ---
            Rectangle {
                id: paginaSistemaSec
                color: "#F7F9FC"
                visible: root.paginaAtual === "sistema"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Sobre"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Versão:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "CalVer 2026.11"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Edição:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Prime (amd64)"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Canal:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "stable"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Tier:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Prime"; font.pointSize: 13; color: "#0E1116"; font.bold: true }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }

            // --- Página: Tela ---
            Rectangle {
                id: paginaTelaSec
                color: "#F7F9FC"
                visible: root.paginaAtual === "tela"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Exibição"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                spacing: 16
                                Text { text: "Resolução:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "1920×1080 @ 60Hz"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Escala:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "100%"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                            Row {
                                spacing: 16
                                Text { text: "Tema:"; font.pointSize: 13; color: "#64748B" }
                                Text { text: "Claro"; font.pointSize: 13; color: "#0E1116" }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }

            // --- Página: Som ---
            Rectangle {
                id: paginaSomSec
                color: "#F7F9FC"
                visible: root.paginaAtual === "som"

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    Card {
                        Layout.fillWidth: true
                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Text {
                                text: "Som"
                                font.pointSize: 16
                                font.bold: true
                                color: "#0E1116"
                            }

                            Row {
                                Text { text: "Volume:"; font.pointSize: 13; color: "#64748B" }
                                Item { Layout.fillWidth: true }
                                Text { text: "60%"; font.pointSize: 12; color: "#94A3B8" }
                            }
                            Slider {
                                Layout.fillWidth: true
                                value: 60
                            }
                        }
                    }
                }
            }
        }
    }
}

// ==================== COMPONENTES AUXILIARES ====================

// Card com sombra e vidro
QtObject {
    id: cardComponent
}

// Componente ChecklistItem para o Shield
QtObject {
    id: checklistItemComponent
}

// Nota: Os componentes Card e ChecklistItem são instanciados inline no QML acima
// como Rectangle e Row para simplicidade. Em produção, seriam componentes separados.
