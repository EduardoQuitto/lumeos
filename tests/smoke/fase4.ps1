<#
.SYNOPSIS
    Smoke test suite Phase 4 — Barra, tray e relógio.
.DESCRIPTION
    Valida a estrutura da fase 4 (barra-tray-relogio) conforme roadmap.yaml e PRD:
    - shell/quickshell/ com QML da barra pilula
    - shell/lite-host/ com host QML X11
    - Barra pilula: 48px, margem 8px, icones 28px, dot 3px
    - Tray: Wi-Fi, volume/bateria, relogio 2 linhas por locale
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase4.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 4 — Barra, tray e relogio ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura shell/
Write-Host "[1/6] Estrutura shell/"
$dirs = @("shell/quickshell", "shell/quickshell/src", "shell/quickshell/qml", "shell/lite-host", "shell/lite-host/src")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. QML Shell.qml
Write-Host "[2/6] Shell.qml - barra pilula + tray"
if (Test-Path "shell/quickshell/qml/Shell.qml") {
    $content = Get-Content "shell/quickshell/qml/Shell.qml" -Raw
    if ($content -match "48") { Pass("Shell.qml referencia 48px (altura da barra)") } else { Fail("Shell.qml sem referencia a 48px") }
    if ($content -match "barraPilula|radius.*24") { Pass("Shell.qml tem barra pilula com raio") } else { Fail("Shell.qml sem barra pilula") }
    if ($content -match "Wi-Fi|rede|rede") { Pass("Shell.qml tem indicador de rede") } else { Fail("Shell.qml sem indicador de rede") }
    if ($content -match "volume|Volume|♪") { Pass("Shell.qml tem indicador de volume") } else { Fail("Shell.qml sem indicador de volume") }
    if ($content -match "bateria|Bateria") { Pass("Shell.qml tem indicador de bateria") } else { Fail("Shell.qml sem indicador de bateria") }
    if ($content -match "HH:mm|relogio|Relogio") { Pass("Shell.qml tem relogio") } else { Fail("Shell.qml sem relogio") }
} else {
    Fail("shell/quickshell/qml/Shell.qml ausente")
}

# 3. main.cpp quickshell e lite-host
Write-Host "[3/6] main.cpp (quickshell + lite-host)"
if (Test-Path "shell/quickshell/src/main.cpp") { Pass("shell/quickshell/src/main.cpp existe") } else { Fail("shell/quickshell/src/main.cpp ausente") }
if (Test-Path "shell/lite-host/src/main.cpp") { Pass("shell/lite-host/src/main.cpp existe") } else { Fail("shell/lite-host/src/main.cpp ausente") }

# 4. Cargo.toml
Write-Host "[4/6] Cargo.toml dos shells"
if (Test-Path "shell/quickshell/Cargo.toml") { Pass("shell/quickshell/Cargo.toml existe") } else { Fail("shell/quickshell/Cargo.toml ausente") }
if (Test-Path "shell/lite-host/Cargo.toml") { Pass("shell/lite-host/Cargo.toml existe") } else { Fail("shell/lite-host/Cargo.toml ausente") }

# 5. Atalhos de teclado
Write-Host "[5/6] Atalhos de teclado (Super, Super+E, Super+I, Super+L, etc.)"
if (Test-Path "shell/quickshell/qml/Shell.qml") {
    $content = Get-Content "shell/quickshell/qml/Shell.qml" -Raw
    $atalhos = @("Super", "Super+E", "Super+I", "Super+L", "Super+D", "Ctrl+Alt+T")
    foreach ($a in $atalhos) {
        if ($content -match $a -or $content -match "Key_Super") { Pass("Atalho mapeado: $a") } else { Fail("Atalho nao encontrado: $a") }
    }
} else {
    Fail("Shell.qml ausente para validar atalhos")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 4 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f4 = $state.fases | Where-Object { $_.id -eq 4 }
    if ($f4) {
        if ($f4.gate.blockers -eq 0) { Pass("Gate fase 4 GREEN: blockers = 0") } else { Fail("Gate fase 4: blockers = " + $f4.gate.blockers) }
    } else {
        Fail("Fase 4 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
