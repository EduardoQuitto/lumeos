import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Busca Universal — provedores: apps, arquivos, configs, calculo
// Web off por padrão (conforme PRD §5)
QtObject {
    id: buscaUniversal

    // Registrar provedores de busca
    property var provedores: [
        { id: "apps", nome: "Aplicativos", prioridade: 1 },
        { id: "arquivos", nome: "Arquivos", prioridade: 2 },
        { id: "configs", nome: "Configurações", prioridade: 3 },
        { id: "calculo", nome: "Cálculo", prioridade: 4 }
    ]

    function buscar(termo) {
        if (!termo || termo.length === 0) return []

        var resultados = []

        // Provedor: apps
        var apps = ["Files", "Settings", "Store", "Terminal", "Task Manager", "Security", "Updates", "Editor", "Viewer", "PDF", "Calc", "Screenshot", "Welcome", "Backup", "Bottles"]
        apps.forEach(function(app) {
            if (app.toLowerCase().indexOf(termo.toLowerCase()) !== -1) {
                resultados.push({ tipo: "app", nome: app, icone: "app", prioridade: 1 })
            }
        })

        // Provedor: arquivos (stub - seria via filesd D-Bus)
        // resultados.push({ tipo: "arquivo", nome: "documento.pdf", caminho: "/home/usuario/documento.pdf", prioridade: 2 })

        // Provedor: configs (stub - seria via settings D-Bus)
        // resultados.push({ tipo: "config", nome: "Rede", caminho: "settings://rede", prioridade: 3 })

        // Provedor: cálculo
        var match = termo.match(/^(\d+)\s*([\+\-\*\/])\s*(\d+)$/)
        if (match) {
            var a = parseInt(match[1])
            var op = match[2]
            var b = parseInt(match[3])
            var resultado = 0
            if (op === "+") resultado = a + b
            else if (op === "-") resultado = a - b
            else if (op === "*") resultado = a * b
            else if (op === "/") resultado = b !== 0 ? a / b : 0
            resultados.push({ tipo: "calculo", expressao: termo, resultado: resultado, prioridade: 4 })
        }

        // Ordenar por prioridade
        resultados.sort(function(a, b) { return a.prioridade - b.prioridade })

        return resultados
    }
}
