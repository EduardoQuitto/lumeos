<#
.SYNOPSIS
    Smoke test suite Phase 19 — Camada Windows.
.DESCRIPTION
    Valida a estrutura da fase 19 (camada-windows) conforme roadmap.yaml e PRD:
    - Wine+NTSYNC
    - Garrafas bwrap com selos
    - 3 apps da lista rodando
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase19.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 19 — Camada Windows ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do app Windows
Write-Host "[1/6] Estrutura apps/windows/"
$dirs = @("apps/windows", "apps/windows/qml", "apps/windows/scripts", "config/wine", "config/bwrap")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. WineLayer.qml
Write-Host "[2/6] apps/windows/qml/WineLayer.qml"
if (Test-Path "apps/windows/qml/WineLayer.qml") {
    $content = Get-Content "apps/windows/qml/WineLayer.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("WineLayer.qml: e janela de aplicacao") } else { Fail("WineLayer.qml: nao e ApplicationWindow") }
    if ($content -match "Wine|wine|WINE") { Pass("WineLayer.qml: referencia Wine") } else { Fail("WineLayer.qml: sem referencia Wine") }
    if ($content -match "NTSYNC|ntsync") { Pass("WineLayer.qml: referencia NTSYNC") } else { Fail("WineLayer.qml: sem referencia NTSYNC") }
    if ($content -match "bwrap|bWrap|BWWrap|garrafa|Garrafa") { Pass("WineLayer.qml: referencia bwrap/garrafas") } else { Fail("WineLayer.qml: sem referencia bwrap/garrafas") }
    if ($content -match "selo|Selo|SELO") { Pass("WineLayer.qml: referencia selos") } else { Fail("WineLayer.qml: sem referencia selos") }
} else {
    Fail("apps/windows/qml/WineLayer.qml ausente")
}

# 3. Script wine-ntsync.sh
Write-Host "[3/6] apps/windows/scripts/wine-ntsync.sh"
if (Test-Path "apps/windows/scripts/wine-ntsync.sh") {
    $content = Get-Content "apps/windows/scripts/wine-ntsync.sh" -Raw
    if ($content -match "wine|Wine") { Pass("wine-ntsync.sh: referencia Wine") } else { Fail("wine-ntsync.sh: sem referencia Wine") }
    if ($content -match "NTSYNC|ntsync") { Pass("wine-ntsync.sh: referencia NTSYNC") } else { Fail("wine-ntsync.sh: sem referencia NTSYNC") }
} else {
    Fail("apps/windows/scripts/wine-ntsync.sh ausente")
}

# 4. Script bwrap-bottle.sh
Write-Host "[4/6] apps/windows/scripts/bwrap-bottle.sh"
if (Test-Path "apps/windows/scripts/bwrap-bottle.sh") {
    $content = Get-Content "apps/windows/scripts/bwrap-bottle.sh" -Raw
    if ($content -match "bwrap|bWrap|BWWrap|garrafa|Garrafa") { Pass("bwrap-bottle.sh: referencia bwrap/garrafas") } else { Fail("bwrap-bottle.sh: sem referencia bwrap/garrafas") }
    if ($content -match "selo|Selo|SELO") { Pass("bwrap-bottle.sh: referencia selos") } else { Fail("bwrap-bottle.sh: sem referencia selos") }
} else {
    Fail("apps/windows/scripts/bwrap-bottle.sh ausente")
}

# 5. Script seal-app.sh
Write-Host "[5/6] apps/windows/scripts/seal-app.sh"
if (Test-Path "apps/windows/scripts/seal-app.sh") {
    $content = Get-Content "apps/windows/scripts/seal-app.sh" -Raw
    if ($content -match "selo|Selo|SELO|seal|Seal") { Pass("seal-app.sh: referencia selos") } else { Fail("seal-app.sh: sem referencia selos") }
} else {
    Fail("apps/windows/scripts/seal-app.sh ausente")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 19 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f19 = $state.fases | Where-Object { $_.id -eq 19 }
    if ($f19) {
        if ($f19.gate.blockers -eq 0) { Pass("Gate fase 19 GREEN: blockers = 0") } else { Fail("Gate fase 19: blockers = " + $f19.gate.blockers) }
    } else {
        Fail("Fase 19 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
