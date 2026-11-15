<#
.SYNOPSIS
    Smoke test suite Fase 28 - Bloco A: ISO amd64 boot.
.DESCRIPTION
    Valida a estrutura da fase 28 (iso-amd64-boot) conforme roadmap.yaml e PRD:
    - build/live-build/build.sh real (debootstrap, squashfs+verity, grub-mkrescue)
    - iso/grub/grub.cfg para Debian live-boot
    - .github/workflows/ci.yml CI QEMU real
    - tests/qemu/smoke.sh real com QMP screendump
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase28.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Fase 28 - Bloco A: ISO amd64 boot ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do build/live-build
Write-Host "[1/6] Estrutura build/live-build/"
$dirs = @("build/live-build")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. build.sh
Write-Host "[2/6] build/live-build/build.sh"
if (Test-Path "build/live-build/build.sh") {
    $content = Get-Content "build/live-build/build.sh" -Raw
    if ($content -match "debootstrap") { Pass("build.sh: usa debootstrap") } else { Fail("build.sh: sem debootstrap") }
    if ($content -match "mksquashfs|squashfs") { Pass("build.sh: usa SquashFS") } else { Fail("build.sh: sem SquashFS") }
    if ($content -match "verity") { Pass("build.sh: usa verity") } else { Fail("build.sh: sem verity") }
    if ($content -match "grub-mkrescue") { Pass("build.sh: usa grub-mkrescue") } else { Fail("build.sh: sem grub-mkrescue") }
} else {
    Fail("build/live-build/build.sh ausente")
}

# 3. core-build.sh e lite-build.sh
Write-Host "[3/6] build/live-build/core-build.sh e lite-build.sh"
if (Test-Path "build/live-build/core-build.sh") { Pass("core-build.sh existe") } else { Fail("core-build.sh ausente") }
if (Test-Path "build/live-build/lite-build.sh") { Pass("lite-build.sh existe") } else { Fail("lite-build.sh ausente") }

# 4. iso/grub/grub.cfg
Write-Host "[4/6] iso/grub/grub.cfg"
if (Test-Path "iso/grub/grub.cfg") {
    $content = Get-Content "iso/grub/grub.cfg" -Raw
    if ($content -match "live-boot|boot=live") { Pass("grub.cfg: boot=live (Debian live-boot)") } else { Fail("grub.cfg: sem boot=live") }
    if ($content -match "/live/vmlinuz|/live/initrd") { Pass("grub.cfg: caminhos live corretos") } else { Fail("grub.conf: caminhos live incorretos") }
} else {
    Fail("iso/grub/grub.cfg ausente")
}

# 5. CI workflow
Write-Host "[5/6] .github/workflows/ci.yml"
if (Test-Path ".github/workflows/ci.yml") {
    $content = Get-Content ".github/workflows/ci.yml" -Raw
    if ($content -match "build/live-build/build.sh") { Pass("ci.yml: chama build/live-build/build.sh") } else { Fail("ci.yml: sem referência a build/live-build/build.sh") }
    if ($content -match "tests/qemu/smoke.sh") { Pass("ci.yml: chama tests/qemu/smoke.sh") } else { Fail("ci.yml: sem referência a smoke.sh") }
} else {
    Fail(".github/workflows/ci.yml ausente")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 28 - blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f28 = $state.fases | Where-Object { $_.id -eq 28 }
    if ($f24) {
        if ($f24.gate.blockers -eq 0) { Pass("Gate fase 28 GREEN: blockers = 0") } else { Fail("Gate fase 28: blockers = " + $f24.gate.blockers) }
    } else {
        Fail("Fase 28 não encontrada no state")
    }
} catch {
    Fail("Não foi possível consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
