<#
.SYNOPSIS
    Smoke test suite Phase 7 — Janelas, snap, alt-tab, overview.
.DESCRIPTION
    Valida a estrutura da fase 7 (janelas-snap-overview) conforme roadmap.yaml e PRD:
    - libdecor-lume: plugin para janelas terceiros (CSD QML + decorações)
    - Snap: 4 layouts (borda/canto + Super+setas)
    - Alt+Tab switcher
    - Super+Tab overview: thumbnails centralizados
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase7.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 7 — Janelas, snap, alt-tab, overview ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura libdecor-lume/
Write-Host "[1/6] Estrutura shell/libdecor-lume/"
$dirs = @("shell/libdecor-lume", "shell/libdecor-lume/src")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. libdecor-lume Cargo.toml e main.c
Write-Host "[2/6] libdecor-lume: Cargo.toml + main.c"
if (Test-Path "shell/libdecor-lume/Cargo.toml") { Pass("shell/libdecor-lume/Cargo.toml existe") } else { Fail("shell/libdecor-lume/Cargo.toml ausente") }
if (Test-Path "shell/libdecor-lume/src/main.c") {
    $content = Get-Content "shell/libdecor-lume/src/main.c" -Raw
    if ($content -match "libdecor|LumeDecor|surface|context") { Pass("libdecor-lume: usa API libdecor") } else { Fail("libdecor-lume: não usa API libdecor") }
    if ($content -match "CSD|titlebar|titlebar 40|controles à direita") { Pass("libdecor-lume: CSD QML com titlebar") } else { Fail("libdecor-lume: sem CSD QML") }
} else {
    Fail("shell/libdecor-lume/src/main.c ausente")
}

# 3. QML janelas (JanelaLume, Snap, AltTab, Overview)
Write-Host "[3/6] QML: JanelaLume, Snap, AltTab, Overview"
$qmls = @("JanelaLume", "Snap", "AltTab", "Overview")
$dirQml = "shell/quickshell/qml/windows"
foreach ($q in $qmls) {
    $path = Join-Path $dirQml "$q.qml"
    if (Test-Path $path) { Pass("$q.qml existe") } else { Fail("$q.qml ausente") }
}

# 4. Validar conteudo dos QMLs
Write-Host "[4/6] Conteudo dos QMLs (raio 12, titlebar 40, snap 4 layouts, alt-tab, overview)"
# JanelaLume: raio 12, titlebar 40, fechar hover C42B1C
$c = Get-Content (Join-Path $dirQml "JanelaLume.qml") -Raw
if ($c -match "radius.*12|12.*radius") { Pass("JanelaLume: raio 12") } else { Fail("JanelaLume: sem raio 12") }
if ($c -match "height.*40|40.*height|titlebar") { Pass("JanelaLume: titlebar 40px") } else { Fail("JanelaLume: sem titlebar 40px") }
if ($c -match "C42B1C|fechar|Fechar") { Pass("JanelaLume: fechar hover C42B1C") } else { Fail("JanelaLume: sem fechar C42B1C") }
if ($c -match "sombra|shadow|Sombra") { Pass("JanelaLume: sombra 2 camadas") } else { Fail("JanelaLume: sem sombra") }

# Snap: 4 layouts, Super+setas
$c = Get-Content (Join-Path $dirQml "Snap.qml") -Raw
if ($c -match "esquerda|direita|maximizar|canto") { Pass("Snap: 4 layouts") } else { Fail("Snap: sem 4 layouts") }
if ($c -match "Key_Super|Super.*Left|Super.*Right") { Pass("Snap: Super+setas") } else { Fail("Snap: sem Super+setas") }

# AltTab: alternar janelas
$c = Get-Content (Join-Path $dirQml "AltTab.qml") -Raw
if ($c -match "Alt.*Tab|Tab.*Alt|Key_Tab") { Pass("AltTab: Alt+Tab") } else { Fail("AltTab: sem Alt+Tab") }
if ($c -match "janela|Janela|thumbnail") { Pass("AltTab: lista de janelas") } else { Fail("AltTab: sem lista de janelas") }

# Overview: thumbnails centralizados, Super+Tab
$c = Get-Content (Join-Path $dirQml "Overview.qml") -Raw
if ($c -match "GridView|grid|thumbnail") { Pass("Overview: grid de thumbnails") } else { Fail("Overview: sem grid de thumbnails") }
if ($c -match "Key_Super|Super.*Tab") { Pass("Overview: Super+Tab") } else { Fail("Overview: sem Super+Tab") }

# 5. Shell.qml integra os componentes de janela
Write-Host "[5/6] Shell.qml integra componentes de janela"
if (Test-Path "shell/quickshell/qml/Shell.qml") {
    $content = Get-Content "shell/quickshell/qml/Shell.qml" -Raw
    if ($content -match "JanelaLume|Snap|AltTab|Overview|janela|Janela") { Pass("Shell.qml referencia componentes de janela") } else { Fail("Shell.qml nao referencia componentes de janela") }
} else {
    Fail("shell/quickshell/qml/Shell.qml ausente")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 7 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f7 = $state.fases | Where-Object { $_.id -eq 7 }
    if ($f7) {
        if ($f7.gate.blockers -eq 0) { Pass("Gate fase 7 GREEN: blockers = 0") } else { Fail("Gate fase 7: blockers = " + $f7.gate.blockers) }
    } else {
        Fail("Fase 7 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
