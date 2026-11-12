<#
.SYNOPSIS
    Smoke test suite Phase 9 — Settings Parte 1.
.DESCRIPTION
    Valida a estrutura da fase 9 (settings-parte1) conforme roadmap.yaml e PRD:
    - janela principal com nav esquerda 240px vidro-lite + conteudo papel/tinta
    - 8 paginas: sistema, tela, som, rede, bt, personalizacao, apps, contas
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase9.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 9 — Settings Parte 1 ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do app Settings
Write-Host "[1/6] Estrutura apps/settings/"
$dirs = @("apps/settings", "apps/settings/qml", "apps/settings/qml/views")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. Settings.qml principal
Write-Host "[2/6] apps/settings/qml/Settings.qml"
if (Test-Path "apps/settings/qml/Settings.qml") {
    $content = Get-Content "apps/settings/qml/Settings.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("Settings.qml: e janela de aplicacao") } else { Fail("Settings.qml: nao e ApplicationWindow") }
    if ($content -match "navEsquerda|240|vidro|ShaderEffect") { Pass("Settings.qml: nav esquerda 240px vidro-lite") } else { Fail("Settings.qml: sem nav esquerda 240px vidro-lite") }
    if ($content -match "papel|tinta|#F7F9FC|#0E1116") { Pass("Settings.qml: conteudo papel/tinta") } else { Fail("Settings.qml: sem conteudo papel/tinta") }
    if ($content -match "paginaAtual|pilha|Stack") { Pass("Settings.qml: navegacao entre paginas") } else { Fail("Settings.qml: sem navegacao entre paginas") }
} else {
    Fail("apps/settings/qml/Settings.qml ausente")
}

# 3. 8 paginas de settings
Write-Host "[3/6] 8 paginas: sistema, tela, som, rede, bt, personalizacao, apps, contas"
$paginas = @("sistema", "tela", "som", "rede", "bt", "personalizacao", "apps", "contas")
$content = Get-Content "apps/settings/qml/Settings.qml" -Raw
foreach ($p in $paginas) {
    if ($content -match $p) { Pass("Pagina: $p") } else { Fail("Pagina: falta $p") }
}

# 4. Conteudo especifico das paginas
Write-Host "[4/6] Conteudo especifico das paginas"
# Sistema: versao, canal, tier, hardware
if ($content -match "Versao|versao|2026.11") { Pass("Sistema: verso/canal") } else { Fail("Sistema: sem verso/canal") }
if ($content -match "Tier|tier|Prime|Core|Lite") { Pass("Sistema: tier") } else { Fail("Sistema: sem tier") }
if ($content -match "CPU|RAM|GPU|Hardware|hardware") { Pass("Sistema: hardware") } else { Fail("Sistema: sem hardware") }

# Tela: resolucao, escala, tema
if ($content -match "Resolucao|resolucao|1920|1080") { Pass("Tela: resolucao") } else { Fail("Tela: sem resolucao") }
if ($content -match "Escala|escala|100%") { Pass("Tela: escala") } else { Fail("Tela: sem escala") }
if ($content -match "Tema|tema|Claro|Escuro|Sistema") { Pass("Tela: tema claro/escuro") } else { Fail("Tela: sem tema claro/escuro") }

# Som: dispositivos, volume, sons
if ($content -match "Saida|saida|Audio|audio|Volume|volume") { Pass("Som: saida/volume") } else { Fail("Som: sem saida/volume") }
if ($content -match "Entrada|entrada|Microfone|microfone") { Pass("Som: entrada/microfone") } else { Fail("Som: sem entrada/microfone") }
if ($content -match "Notificacao|notificacao|Erro|erro|Inicializacao|inicializacao") { Pass("Som: sons do sistema") } else { Fail("Som: sem sons do sistema") }

# Rede: Wi-Fi, Ethernet, WireGuard
if ($content -match "Wi-Fi|wi-fi|WiFi") { Pass("Rede: Wi-Fi") } else { Fail("Rede: sem Wi-Fi") }
if ($content -match "Ethernet|ethernet") { Pass("Rede: Ethernet") } else { Fail("Rede: sem Ethernet") }
if ($content -match "WireGuard|wireguard") { Pass("Rede: WireGuard") } else { Fail("Rede: sem WireGuard") }

# Bluetooth: dispositivos emparelhados
if ($content -match "Bluetooth|bluetooth|Emparelhado|emparelhado|Dispositivo|dispositivo") { Pass("BT: bluetooth/dispositivos") } else { Fail("BT: sem bluetooth/dispositivos") }

# Personalizacao: wallpaper, acento, materiais
if ($content -match "Wallpaper|wallpaper|Aurora|Crystal|Pastel|Silk|Solar") { Pass("Personalizacao: wallpaper") } else { Fail("Personalizacao: sem wallpaper") }
if ($content -match "Acento|acento|Cor|cor|#3E8EF7|#45C8F5") { Pass("Personalizacao: cor de acento") } else { Fail("Personalizacao: sem cor de acento") }
if ($content -match "Materiais|materiais|Vidro|Névoa|Nevoa|Solido|Solido") { Pass("Personalizacao: materiais") } else { Fail("Personalizacao: sem materiais") }

# Apps: instalados, padroes, desinstalar
if ($content -match "Aplicativos|aplicativos|Instalados|instalados") { Pass("Apps: aplicativos instalados") } else { Fail("Apps: sem aplicativos instalados") }
if ($content -match "Desinstalar|desinstalar|Padrão|padrao") { Pass("Apps: desinstalar/padrao") } else { Fail("Apps: sem desinstalar/padrao") }

# Contas: usuario, senha, sincronizacao
if ($content -match "Usuario|usuario|Conta|conta|Senha|senha") { Pass("Contas: usuario/senha") } else { Fail("Contas: sem usuario/senha") }
if ($content -match "Sincronizacao|sincronizacao|Login automatico|login automatico") { Pass("Contas: sincronizacao/login") } else { Fail("Contas: sem sincronizacao/login") }

# 5. Atalhos / navegacao
Write-Host "[5/6] Navegacao entre paginas (clique na lista)"
if ($content -match "MouseArea|onClicked|root.paginaAtual|listaPaginas.currentIndex") { Pass("Navegacao: clique muda pagina") } else { Fail("Navegacao: sem clique muda pagina") }

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 9 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f9 = $state.fases | Where-Object { $_.id -eq 9 }
    if ($f9) {
        if ($f9.gate.blockers -eq 0) { Pass("Gate fase 9 GREEN: blockers = 0") } else { Fail("Gate fase 9: blockers = " + $f9.gate.blockers) }
    } else {
        Fail("Fase 9 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
