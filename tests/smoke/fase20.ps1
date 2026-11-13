<#
.SYNOPSIS
    Smoke test suite Phase 20 — Jogos Nuvem.
.DESCRIPTION
    Valida a estrutura da fase 20 (jogos-nuvem) conforme roadmap.yaml e PRD:
    - Steam+Proton para tiers B/C
    - Sober best-effort
    - PWAs nuvem por tier
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase20.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 20 — Jogos Nuvem ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do app cloud-gaming
Write-Host "[1/6] Estrutura apps/cloud-gaming/"
$dirs = @("apps/cloud-gaming", "apps/cloud-gaming/qml", "apps/windows/scripts", "config/cloud")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. CloudGaming.qml
Write-Host "[2/6] apps/cloud-gaming/qml/CloudGaming.qml"
if (Test-Path "apps/cloud-gaming/qml/CloudGaming.qml") {
    $content = Get-Content "apps/cloud-gaming/qml/CloudGaming.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("CloudGaming.qml: e janela de aplicacao") } else { Fail("CloudGaming.qml: nao e ApplicationWindow") }
    if ($content -match "Steam|steam|STEAM") { Pass("CloudGaming.qml: referencia Steam") } else { Fail("CloudGaming.qml: sem referencia Steam") }
    if ($content -match "Proton|proton") { Pass("CloudGaming.qml: referencia Proton") } else { Fail("CloudGaming.qml: sem referencia Proton") }
    if ($content -match "Sober|sober") { Pass("CloudGaming.qml: referencia Sober") } else { Fail("CloudGaming.qml: sem referencia Sober") }
    if ($content -match "PWA|pwa|PWAs") { Pass("CloudGaming.qml: referencia PWAs") } else { Fail("CloudGaming.qml: sem referencia PWAs") }
} else {
    Fail("apps/cloud-gaming/qml/CloudGaming.qml ausente")
}

# 3. Scripts steam-proton.sh e sober.sh
Write-Host "[3/6] apps/windows/scripts/"
if (Test-Path "apps/windows/scripts/wine-ntsync.sh") { Pass("wine-ntsync.sh existe") } else { Fail("wine-ntsync.sh ausente") }
if (Test-Path "apps/windows/scripts/steam-proton.sh") {
    $content = Get-Content "apps/windows/scripts/steam-proton.sh" -Raw
    if ($content -match "steam|Steam") { Pass("steam-proton.sh: Steam") } else { Fail("steam-proton.sh: sem Steam") }
    if ($content -match "Proton|proton") { Pass("steam-proton.sh: Proton") } else { Fail("steam-proton.sh: sem Proton") }
} else {
    Fail("apps/windows/scripts/steam-proton.sh ausente")
}

if (Test-Path "apps/windows/scripts/sober.sh") {
    $content = Get-Content "apps/windows/scripts/sober.sh" -Raw
    if ($content -match "sober|Sober") { Pass("sober.sh: Sober") } else { Fail("sober.sh: sem Sober") }
} else {
    Fail("apps/windows/scripts/sober.sh ausente")
}

# 4. Config cloud/pwas.yaml
Write-Host "[4/6] config/cloud/pwas.yaml"
if (Test-Path "config/cloud/pwas.yaml") {
    $content = Get-Content "config/cloud/pwas.yaml" -Raw
    if ($content -match "pwa|PWA") { Pass("pwas.yaml: PWAs") } else { Fail("pwas.yaml: sem PWAs") }
    if ($content -match "prime|core|lite") { Pass("pwas.yaml: tiers") } else { Fail("pwas.yaml: sem tiers") }
    if ($content -match "GeForce|geforce|Xbox|xbox|Luna|luna|Stadia|stadia") { Pass("pwas.yaml: PWAs listadas") } else { Fail("pwas.yaml: sem PWAs listadas") }
} else {
    Fail("config/cloud/pwas.yaml ausente")
}

# 5. Validar PWAs por tier
Write-Host "[5/6] PWAs por tier"
if (Test-Path "config/cloud/pwas.yaml") {
    $content = Get-Content "config/cloud/pwas.yaml" -Raw
    if ($content -match "prime") { Pass("PWAs tier Prime") } else { Fail("PWAs: falta tier Prime") }
    if ($content -match "core") { Pass("PWAs tier Core") } else { Fail("PWAs: falta tier Core") }
    if ($content -match "lite") { Pass("PWAs tier Lite") } else { Fail("PWAs: falta tier Lite") }
} else {
    Fail("config/cloud/pwas.yaml ausente")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 20 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f20 = $state.fases | Where-Object { $_.id -eq 20 }
    if ($f20) {
        if ($f20.gate.blockers -eq 0) { Pass("Gate fase 20 GREEN: blockers = 0") } else { Fail("Gate fase 20: blockers = " + $f20.gate.blockers) }
    } else {
        Fail("Fase 20 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
