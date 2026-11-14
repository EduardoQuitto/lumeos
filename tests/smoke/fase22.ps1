<#
.SYNOPSIS
    Smoke test suite Phase 22 — Modo Cofre.
.DESCRIPTION
    Valida a estrutura da fase 22 (modo-cofre) conforme roadmap.yaml e PRD:
    - microVM descartavel
    - abre app de risco e destroi sem resíduo
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase22.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 22 — Modo Cofre ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do app cofre
Write-Host "[1/6] Estrutura apps/cofre/"
$dirs = @("apps/cofre", "apps/cofre/qml", "apps/windows/scripts", "config/cofre")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. Cofre.qml
Write-Host "[2/6] apps/cofre/qml/Cofre.qml"
if (Test-Path "apps/cofre/qml/Cofre.qml") {
    $content = Get-Content "apps/cofre/qml/Cofre.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("Cofre.qml: e janela de aplicacao") } else { Fail("Cofre.qml: nao e ApplicationWindow") }
    if ($content -match "microVM|microVM|micro VM") { Pass("Cofre.qml: microVM") } else { Fail("Cofre.qml: sem microVM") }
    if ($content -match "app de risco|App de Risco") { Pass("Cofre.qml: app de risco") } else { Fail("Cofre.qml: sem app de risco") }
    if ($content -match "destruir|Destruir|residuo|resíduo") { Pass("Cofre.qml: destruir sem resíduo") } else { Fail("Cofre.qml: sem destruir sem resíduo") }
} else {
    Fail("apps/cofre/qml/Cofre.qml ausente")
}

# 3. Script cofre.sh
Write-Host "[3/6] apps/windows/scripts/cofre.sh"
if (Test-Path "apps/windows/scripts/cofre.sh") {
    $content = Get-Content "apps/windows/scripts/cofre.sh" -Raw
    if ($content -match "microVM|microVM") { Pass("cofre.sh: microVM") } else { Fail("cofre.sh: sem microVM") }
    if ($content -match "destruir|Destruir|destruicao|Destruição") { Pass("cofre.sh: destruir microVM") } else { Fail("cofre.sh: sem destruir microVM") }
    if ($content -match "criar|Criar") { Pass("cofre.sh: criar microVM") } else { Fail("cofre.sh: sem criar microVM") }
} else {
    Fail("apps/windows/scripts/cofre.sh ausente")
}

# 4. Configuracao do cofre
Write-Host "[4/6] config/cofre/cofre.conf"
if (Test-Path "config/cofre/cofre.conf") {
    $content = Get-Content "config/cofre/cofre.conf" -Raw
    if ($content -match "memoria_mb|memoria") { Pass("cofre.conf: memoria") } else { Fail("cofre.conf: sem memoria") }
    if ($content -match "vcpus|vCPUs") { Pass("cofre.conf: vCPUs") } else { Fail("cofre.conf: sem vCPUs") }
    if ($content -match "isolamento|Isolamento") { Pass("cofre.conf: isolamento") } else { Fail("cofre.conf: sem isolamento") }
} else {
    Fail("config/cofre/cofre.conf ausente")
}

# 5. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 22 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f22 = $state.fases | Where-Object { $_.id -eq 22 }
    if ($f22) {
        if ($f22.gate.blockers -eq 0) { Pass("Gate fase 22 GREEN: blockers = 0") } else { Fail("Gate fase 22: blockers = " + $f22.gate.blockers) }
    } else {
        Fail("Fase 22 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
