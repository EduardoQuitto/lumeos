import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Snap — 4 layouts (borda/canto + Super+setas)
// Layouts: esquerda 50%, direita 50%, topo 50%, canto superior-esquerdo 25%
Item {
    id: gerenciadorSnap
    property var janelaAtual: null
    property bool snapAtivo: false

    function aplicarSnap(layout) {
        if (!janelaAtual) return

        snapAtivo = true
        var w = gerenciadorSnap.width
        var h = gerenciadorSnap.height

        switch (layout) {
            case "esquerda":
                janelaAtual.largura = w / 2
                janelaAtual.altura = h
                janelaAtual.x = 0
                janelaAtual.y = 0
                break
            case "direita":
                janelaAtual.largura = w / 2
                janelaAtual.altura = h
                janelaAtual.x = w / 2
                janelaAtual.y = 0
                break
            case "canto-superior-esquerdo":
                janelaAtual.largura = w / 2
                janelaAtual.altura = h / 2
                janelaAtual.x = 0
                janelaAtual.y = 0
                break
            case "canto-superior-direito":
                janelaAtual.largura = w / 2
                janelaAtual.altura = h / 2
                janelaAtual.x = w / 2
                janelaAtual.y = 0
                break
            case "maximizar":
                janelaAtual.largura = w
                janelaAtual.altura = h
                janelaAtual.x = 0
                janelaAtual.y = 0
                janelaAtual.maximized = true
                break
        }

        // Animação mola para a nova posição
        Behavior on x { SpringAnimation { spring: 3.2; damping: 0.28 } }
        Behavior on y { SpringAnimation { spring: 3.2; damping: 0.28 } }
        Behavior on largura { SpringAnimation { spring: 3.2; damping: 0.28 } }
        Behavior on altura { SpringAnimation { spring: 3.2; damping: 0.28 } }
    }

    // Atalhos: Super + setas
    Keys.onPressed: {
        if (event.key === Qt.Key_Left && event.modifiers === Qt.SuperModifier) {
            aplicarSnap("esquerda")
            event.accepted = true
        } else if (event.key === Qt.Key_Right && event.modifiers === Qt.SuperModifier) {
            aplicarSnap("direita")
            event.accepted = true
        } else if (event.key === Qt.Key_Up && event.modifiers === Qt.SuperModifier) {
            aplicarSnap("maximizar")
            event.accepted = true
        } else if (event.key === Qt.Key_Down && event.modifiers === Qt.SuperModifier) {
            janelaAtual.maximized = false
            janelaAtual.largura = 800
            janelaAtual.altura = 600
            event.accepted = true
        }
    }
}
