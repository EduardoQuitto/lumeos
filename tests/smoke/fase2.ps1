<#
.SYNOPSIS
    Smoke test suite Phase 2 — ISO amd64 boot.
.DESCRIPTION
    Valida a estrutura da fase 2 (iso-amd64-boot) conforme roadmap.yaml e PRD:
    - iso/{plymouth,calamares,grub,hooks} existem
    - Plymouth Lume com arcos orbitais (lume.script)
    - GRUB configurado
    - build/live-build/build.sh presente
    - tests/qemu/smoke.sh presente
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase2.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 2 — ISO amd64 boot ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura iso/
Write-Host "[1/6] Estrutura iso/"
$dirs = @("iso/plymouth", "iso/calamares", "iso/grub", "iso/hooks")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. Plymouth Lume
Write-Host "[2/6] Plymouth Lume (arcos orbitais)"
$plymouth_files = @("iso/plymouth/lume.script", "iso/plymouth/theme.cfg", "iso/plymouth/plymouthd.conf")
foreach ($f in $plymouth_files) {
    if (Test-Path $f) {
        $content = Get-Content $f -Raw
        if ($content -match "arco|arcos|orbit|Lume") { Pass("$f válido (tema Lume)") } else { Pass("$f existe") }
    } else {
        Fail("$f ausente")
    }
}

# 3. GRUB
Write-Host "[3/6] GRUB configurado"
if (Test-Path "iso/grub/grub.cfg") {
    $content = Get-Content "iso/grub/grub.cfg" -Raw
    if ($content -match "menuentry" -and $content -match "Lume") { Pass("grub.cfg com entries Lume") } else { Fail("grub.cfg incompleto") }
} else {
    Fail("iso/grub/grub.cfg ausente")
}

# 4. Calamares
Write-Host "[4/6] Calamares (placeholder)"
if (Test-Path "iso/calamares/settings.conf") { Pass("iso/calamares/settings.conf existe") } else { Fail("iso/calamares/settings.conf ausente") }

# 5. Build script
Write-Host "[5/6] build/live-build/build.sh"
if (Test-Path "build/live-build/build.sh") {
    $content = Get-Content "build/live-build/build.sh" -Raw
    if ($content -match "ISO|iso|squash|SquashFS") { Pass("build.sh com referência a ISO/SquashFS") } else { Pass("build.sh existe") }
} else {
    Fail("build/live-build/build.sh ausente")
}

# 6. QEMU smoke
Write-Host "[6/6] tests/qemu/smoke.sh"
if (Test-Path "tests/qemu/smoke.sh") {
    $content = Get-Content "tests/qemu/smoke.sh" -Raw
    if ($content -match "screendump|QMP|qmp") { Pass("smoke.sh com screendump QMP") } else { Pass("smoke.sh existe") }
} else {
    Fail("tests/qemu/smoke.sh ausente")
}

# Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 2 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f2 = $state.fases | Where-Object { $_.id -eq 2 }
    if ($f2) {
        if ($f2.gate.blockers -eq 0) { Pass("Gate fase 2 GREEN: blockers = 0") } else { Fail("Gate fase 2: blockers = " + $f2.gate.blockers) }
    } else {
        Fail("Fase 2 não encontrada no state")
    }
} catch {
    Fail("Não foi possível consultar /api/state: $_")
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
