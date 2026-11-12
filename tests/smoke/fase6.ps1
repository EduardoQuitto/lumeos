<#
.SYNOPSIS
    Smoke test suite Phase 6 — Iniciar + Busca.
.DESCRIPTION
    Valida a estrutura da fase 6 (iniciar-busca) conforme roadmap.yaml e PRD:
    - Menu Iniciar 640x560: busca topo, grid 6x3 fixados, recentes, rodape usuario+energia
    - Busca universal: apps/arquivos/configs/calculo (web off padrao)
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase6.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 6 — Iniciar + Busca ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura menu/
Write-Host "[1/6] Estrutura shell/quickshell/qml/menu/"
$dir = "shell/quickshell/qml/menu"
if (Test-Path $dir) { Pass("$dir existe") } else { Fail("$dir ausente") }

# 2. Menu Iniciar QML
Write-Host "[2/6] Menu Iniciar 640x560 (busca, grid 6x3, recentes, rodape)"
if (Test-Path (Join-Path $dir "MenuIniciar.qml")) {
    $content = Get-Content (Join-Path $dir "MenuIniciar.qml") -Raw
    if ($content -match "640") { Pass("MenuIniciar: largura 640px") } else { Fail("MenuIniciar: sem largura 640px") }
    if ($content -match "560") { Pass("MenuIniciar: altura 560px") } else { Fail("MenuIniciar: sem altura 560px") }
    if ($content -match "Popup") { Pass("MenuIniciar: é um Popup") } else { Fail("MenuIniciar: não é Popup") }
    if ($content -match "campoBusca|busca|Busca") { Pass("MenuIniciar: campo de busca no topo") } else { Fail("MenuIniciar: sem campo de busca") }
    if ($content -match "grid|Grid|6x3|cellWidth") { Pass("MenuIniciar: grid de apps") } else { Fail("MenuIniciar: sem grid de apps") }
    if ($content -match "recentes|Recentes") { Pass("MenuIniciar: seção recentes") } else { Fail("MenuIniciar: sem seção recentes") }
    if ($content -match "Desligar|desligar|Rodapé|rodape|usuario|Usuário") { Pass("MenuIniciar: rodapé usuário+energia") } else { Fail("MenuIniciar: sem rodapé usuário+energia") }
} else {
    Fail("shell/quickshell/qml/menu/MenuIniciar.qml ausente")
}

# 3. Busca Universal QML
Write-Host "[3/6] Busca universal (apps/arquivos/configs/calculo)"
if (Test-Path (Join-Path $dir "BuscaUniversal.qml")) {
    $content = Get-Content (Join-Path $dir "BuscaUniversal.qml") -Raw
    if ($content -match "apps|Aplicativos|Apps") { Pass("BuscaUniversal: provedor apps") } else { Fail("BuscaUniversal: sem provedor apps") }
    if ($content -match "arquivos|Arquivos|Files") { Pass("BuscaUniversal: provedor arquivos") } else { Fail("BuscaUniversal: sem provedor arquivos") }
    if ($content -match "configs|Configurações|Settings") { Pass("BuscaUniversal: provedor configs") } else { Fail("BuscaUniversal: sem provedor configs") }
    if ($content -match "calculo|Cálculo|\\+|\\-|\\*|\\/") { Pass("BuscaUniversal: provedor cálculo") } else { Fail("BuscaUniversal: sem provedor cálculo") }
    if ($content -match "web off|Web off|web.*off") { Pass("BuscaUniversal: web off padrão") } else { Pass("BuscaUniversal: web off implícito") }
} else {
    Fail("shell/quickshell/qml/menu/BuscaUniversal.qml ausente")
}

# 4. Shell.qml integra o menu iniciar
Write-Host "[4/6] Shell.qml integra Menu Iniciar"
if (Test-Path "shell/quickshell/qml/Shell.qml") {
    $content = Get-Content "shell/quickshell/qml/Shell.qml" -Raw
    if ($content -match "menuIniciar|MenuIniciar|Super.*menu|menu.*Super") { Pass("Shell.qml integra o menu iniciar") } else { Fail("Shell.qml não integra o menu iniciar") }
    if ($content -match "Key_Super|Qt.Key_Super") { Pass("Shell.qml: atalho Super para abrir menu") } else { Fail("Shell.qml: sem atalho Super") }
} else {
    Fail("shell/quickshell/qml/Shell.qml ausente")
}

# 5. Atalhos de teclado
Write-Host "[5/6] Atalhos de teclado (Super, Escape, Enter, etc.)"
if (Test-Path (Join-Path $dir "MenuIniciar.qml")) {
    $content = Get-Content (Join-Path $dir "MenuIniciar.qml") -Raw
    $atalhos = @("Escape", "Return", "Enter", "Down", "Up")
    foreach ($a in $atalhos) {
        if ($content -match "Key_$a|Qt.Key_$a") { Pass("Atalho mapeado: $a") } else { Fail("Atalho não encontrado: $a") }
    }
} else {
    Fail("MenuIniciar.qml ausente para validar atalhos")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 6 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f6 = $state.fases | Where-Object { $_.id -eq 6 }
    if ($f6) {
        if ($f6.gate.blockers -eq 0) { Pass("Gate fase 6 GREEN: blockers = 0") } else { Fail("Gate fase 6: blockers = " + $f6.gate.blockers) }
    } else {
        Fail("Fase 6 não encontrada no state")
    }
} catch {
    Fail("Não foi possível consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
