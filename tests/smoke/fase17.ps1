<#
.SYNOPSIS
    Smoke test suite Phase 17 — Edição Lite i386.
.DESCRIPTION
    Valida a estrutura da fase 17 (edição-lite-i386) conforme roadmap.yaml e PRD:
    - ISO i386 bootável
    - shell X11 + picom
    - idle ≤250MB
    - Teste boot em VM
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase17.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 17 — Edição Lite i386 ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do edição Lite
Write-Host "[1/6] Estrutura apps/lite-edition/"
$dirs = @("apps/lite-edition", "apps/lite-edition/qml", "config/lite", "build/live-build")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. LiteShell.qml
Write-Host "[2/6] apps/lite-edition/qml/LiteShell.qml"
if (Test-Path "apps/lite-edition/qml/LiteShell.qml") {
    $content = Get-Content "apps/lite-edition/qml/LiteShell.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("LiteShell.qml: e janela de aplicacao") } else { Fail("LiteShell.qml: nao e ApplicationWindow") }
    if ($content -match "openbox|picom|X11") { Pass("LiteShell.qml: X11 + picom") } else { Fail("LiteShell.qml: sem X11 + picom") }
    if ($content -match "idle|idle.*250|250.*MB|memoriaIdle") { Pass("LiteShell.qml: idle ≤250MB") } else { Fail("LiteShell.qml: sem idle ≤250MB") }
} else {
    Fail("apps/lite-edition/qml/LiteShell.qml ausente")
}

# 3. Configuracoes lite-build.sh
Write-Host "[3/6] build/live-build/lite-build.sh"
if (Test-Path "build/live-build/lite-build.sh") {
    $content = Get-Content "build/live-build/lite-build.sh" -Raw
    if ($content -match "i386") { Pass("lite-build.sh: i386") } else { Fail("lite-build.sh: sem i386") }
    if ($content -match "ISO|iso") { Pass("lite-build.sh: ISO") } else { Fail("lite-build.sh: sem ISO") }
    if ($content -match "debootstrap") { Pass("lite-build.sh: debootstrap") } else { Fail("lite-build.sh: sem debootstrap") }
} else {
    Fail("build/live-build/lite-build.sh ausente")
}

# 4. Configuracoes X11 + picom
Write-Host "[4/6] Configuracoes X11 + picom"
if (Test-Path "config/lite/x11-session.conf") { Pass("config/lite/x11-session.conf existe") } else { Fail("config/lite/x11-session.conf ausente") }
if (Test-Path "config/lite/picom.conf") { Pass("config/lite/picom.conf existe") } else { Fail("config/lite/picom.conf ausente") }
if (Test-Path "config/lite/idle-optimization.conf") { Pass("config/lite/idle-optimization.conf existe") } else { Fail("config/lite/idle-optimization.conf ausente") }

# 5. Validar conteudo do picom.conf e idle-optimization.conf
Write-Host "[5/6] Conteudo do picom.conf e idle-optimization.conf"
if (Test-Path "config/lite/picom.conf") {
    $content = Get-Content "config/lite/picom.conf" -Raw
    if ($content -match "backend.*glx|glx.*backend") { Pass("picom.conf: backend GLX") } else { Fail("picom.conf: sem backend GLX") }
    if ($content -match "shadow|sombra") { Pass("picom.conf: sombra") } else { Fail("picom.conf: sem sombra") }
}
if (Test-Path "config/lite/idle-optimization.conf") {
    $content = Get-Content "config/lite/idle-optimization.conf" -Raw
    if ($content -match "250|idle_max_mb") { Pass("idle-optimization.conf: idle ≤250MB") } else { Fail("idle-optimization.conf: sem idle ≤250MB") }
    if ($content -match "desabilitado|desabilitar|desligado") { Pass("idle-optimization.conf: servicos desabilitados") } else { Fail("idle-optimization.conf: sem servicos desabilitados") }
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 17 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f17 = $state.fases | Where-Object { $_.id -eq 17 }
    if ($f17) {
        if ($f17.gate.blockers -eq 0) { Pass("Gate fase 17 GREEN: blockers = 0") } else { Fail("Gate fase 17: blockers = " + $f17.gate.blockers) }
    } else {
        Fail("Fase 17 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
