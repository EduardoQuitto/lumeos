<#
.SYNOPSIS
    Smoke test suite Phase 18 — Edição Core amd64.
.DESCRIPTION
    Valida a estrutura da fase 18 (edição-core) conforme roadmap.yaml e PRD:
    - shell labwc+Quickshell
    - matriz materiais (Névoa + Sólido + sombras)
    - idle ≤350MB
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase18.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 18 — Edição Core ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do core-edition
Write-Host "[1/6] Estrutura apps/core-edition/"
$dirs = @("apps/core-edition", "apps/core-edition/qml", "config/core", "config/core/labwc", "config/core/materials", "build/live-build")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. CoreShell.qml
Write-Host "[2/6] apps/core-edition/qml/CoreShell.qml"
if (Test-Path "apps/core-edition/qml/CoreShell.qml") {
    $content = Get-Content "apps/core-edition/qml/CoreShell.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("CoreShell.qml: e janela de aplicacao") } else { Fail("CoreShell.qml: nao e ApplicationWindow") }
    if ($content -match "labwc|Quickshell") { Pass("CoreShell.qml: labwc+Quickshell") } else { Fail("CoreShell.qml: sem labwc+Quickshell") }
    if ($content -match "Névoa|Nevoa|Sólido|Solido|sombras|Sombras") { Pass("CoreShell.qml: materiais Névoa/Sólido+sombras") } else { Fail("CoreShell.qml: sem materiais") }
    if ($content -match "idle|idle.*350|350.*MB|memoriaIdle") { Pass("CoreShell.qml: idle ≤350MB") } else { Fail("CoreShell.qml: sem idle ≤350MB") }
} else {
    Fail("apps/core-edition/qml/CoreShell.qml ausente")
}

# 3. Build script
Write-Host "[3/6] build/live-build/core-build.sh"
if (Test-Path "build/live-build/core-build.sh") {
    $content = Get-Content "build/live-build/core-build.sh" -Raw
    if ($content -match "amd64") { Pass("core-build.sh: amd64") } else { Fail("core-build.sh: sem amd64") }
    if ($content -match "debootstrap") { Pass("core-build.sh: debootstrap") } else { Fail("core-build.sh: sem debootstrap") }
    if ($content -match "labwc|quickshell|Labwc|Quickshell") { Pass("core-build.sh: labwc+Quickshell") } else { Fail("core-build.sh: sem labwc+quickshell") }
} else {
    Fail("build/live-build/core-build.sh ausente")
}

# 4. Configuracoes Core
Write-Host "[4/6] Configuracoes Core (labwc, idle, materiais)"
if (Test-Path "config/core/labwc/config") { Pass("config/core/labwc/config existe") } else { Fail("config/core/labwc/config ausente") }
if (Test-Path "config/lite/labwc-config") { Pass("config/lite/labwc-config existe (backup)") } else { Fail("config/lite/labwc-config ausente") }
if (Test-Path "config/core/idle-optimization.conf") { Pass("config/core/idle-optimization.conf existe") } else { Fail("config/core/idle-optimization.conf ausente") }
if (Test-Path "config/core/materials/nevoa.conf") { Pass("config/core/materials/nevoa.conf existe") } else { Fail("config/core/materials/nevoa.conf ausente") }
if (Test-Path "config/core/materials/solido.conf") { Pass("config/core/materials/solido.conf existe") } else { Fail("config/core/materials/solido.conf ausente") }

# 5. Validar conteudo do idle-optimization.conf
Write-Host "[5/6] Conteudo idle-optimization.conf"
if (Test-Path "config/core/idle-optimization.conf") {
    $content = Get-Content "config/core/idle-optimization.conf" -Raw
    if ($content -match "350|idle_max_mb") { Pass("idle-optimization.conf: idle ≤350MB") } else { Fail("idle-optimization.conf: sem idle ≤350MB") }
    if ($content -match "desabilitado|desabilitar") { Pass("idle-optimization.conf: servicos desabilitados") } else { Fail("idle-optimization.conf: sem servicos desabilitados") }
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 18 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f18 = $state.fases | Where-Object { $_.id -eq 18 }
    if ($f18) {
        if ($f18.gate.blockers -eq 0) { Pass("Gate fase 18 GREEN: blockers = 0") } else { Fail("Gate fase 18: blockers = " + $f18.gate.blockers) }
    } else {
        Fail("Fase 18 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
