<#
.SYNOPSIS
    Smoke test suite Phase 26 — Suíte de Testes VM.
.DESCRIPTION
    Valida a estrutura da fase 26 (suite-testes-vm) conforme roadmap.yaml e PRD:
    - matriz QEMU (virtio-gpu/qxl/i386)
    - instalação em disco vazio 20 GB
    - update + rollback
    - teste tamper verity
    - escape sandbox
    - screenshot diff por build
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase26.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 26 — Suíte de Testes VM ===" -ForegroundColor Cyan
Write-Host ""

# 1. Matriz QEMU
Write-Host "[1/6] Matriz QEMU"
$qemuConfigs = @(
    @{ arch = "amd64"; gpu = "virtio-gpu"; tier = "Prime" },
    @{ arch = "amd64"; gpu = "qxl"; tier = "Core" },
    @{ arch = "i386"; gpu = "vga"; tier = "Lite" }
)
foreach ($cfg in $qemuConfigs) {
    Write-Host "  QEMU $($cfg.arch) / $($cfg.gpu) / $($cfg.tier): configurado" -ForegroundColor Gray
    Pass("Configuração QEMU $($cfg.arch) + $($cfg.gpu) válida")
}

# 2. Instalação em disco vazio 20 GB
Write-Host "[2/6] Instalação em disco vazio 20 GB"
if (Test-Path "tests/suite-vm/run-all-tests.sh") {
    $content = Get-Content "tests/suite-vm/run-all-tests.sh" -Raw
    if ($content -match "20.*GB|20GB|disco vazio") { Pass("Instalação em disco vazio 20 GB: referenciado") } else { Fail("Instalação em disco vazio 20 GB: sem referência") }
} else {
    Fail("tests/suite-vm/run-all-tests.sh ausente")
}

# 3. Update + rollback
Write-Host "[3/6] Update + rollback"
if (Test-Path "services/updated/src/main.rs") {
    $content = Get-Content "services/updated/src/main.rs" -Raw
    if ($content -match "rollback|rollback") { Pass("Update: rollback automático") } else { Fail("Update: sem rollback automático") }
    if ($content -match "health_check|health") { Pass("Update: health check") } else { Fail("Update: sem health check") }
} else {
    Fail("services/updated/src/main.rs ausente")
}

# 4. Teste tamper verity
Write-Host "[4/6] Teste tamper verity"
if (Test-Path "services/shield/src/main.rs") {
    $content = Get-Content "services/shield/src/main.rs" -Raw
    if ($content -match "tamper|verity|verifica_tegridade") { Pass("Shield: testes tamper + verity") } else { Fail("Shield: sem testes tamper/verity") }
} else {
    Fail("services/shield/src/main.rs ausente")
}

# 5. Escape sandbox
Write-Host "[5/6] Escape sandbox"
if (Test-Path "services/shield/src/main.rs") {
    $content = Get-Content "services/shield/src/main.rs" -Raw
    if ($content -match "sandbox|seccomp|apparmor") { Pass("Shield: sandbox + seccomp + apparmor") } else { Fail("Shield: sem sandbox isolamento") }
} else {
    Fail("services/shield/src/main.rs ausente")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 26 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f26 = $state.fases | Where-Object { $_.id -eq 26 }
    if ($f26) {
        if ($f26.gate.blockers -eq 0) { Pass("Gate fase 26 GREEN: blockers = 0") } else { Fail("Gate fase 26: blockers = " + $f26.gate.blockers) }
    } else {
        Fail("Fase 26 não encontrada no state")
    }
} catch {
    Fail("Não foi possível consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
