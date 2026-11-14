<#
.SYNOPSIS
    Smoke test suite Phase 25 — Passe Performance.
.DESCRIPTION
    Valida a estrutura da fase 25 (passe-performance) conforme roadmap.yaml e PRD:
    - boot <20s Prime / <30s Core/Lite
    - idle 450/350/250 MB (Prime/Core/Lite)
    - flyout ≤150ms
    - ISO ≤1,4GB amd64 / ≤900MB i386
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase25.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 25 — Passe Performance ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do services/performance
Write-Host "[1/6] Estrutura services/performance/"
$dirs = @("services/performance", "services/performance/src")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. Cargo.toml
Write-Host "[2/6] services/updated/Cargo.toml"
if (Test-Path "services/performance/Cargo.toml") {
    $content = Get-Content "services/performance/Cargo.toml" -Raw
    if ($content -match "serde") { Pass("Cargo.toml: serde") } else { Fail("Cargo.toml: sem serde") }
    if ($content -match "rusqlite") { Pass("Cargo.toml: rusqlite") } else { Fail("Cargo.toml: sem rusqlite") }
} else {
    Fail("services/performance/Cargo.toml ausente")
}

# 3. main.rs
Write-Host "[3/6] services/performance/src/main.rs"
if (Test-Path "services/performance/src/main.rs") {
    $content = Get-Content "services/performance/src/main.rs" -Raw
    if ($content -match "boot_ms|boot") { Pass("main.rs: boot_ms") } else { Fail("main.rs: sem boot_ms") }
    if ($content -match "idle_mb|idle") { Pass("main.rs: idle_mb") } else { Fail("main.rs: sem idle_mb") }
    if ($content -match "flyout_ms|flyout") { Pass("main.rs: flyout_ms") } else { Fail("main.rs: sem flyout_ms") }
    if ($content -match "iso_size_bytes|iso") { Pass("main.rs: iso_size_bytes") } else { Fail("main.rs: sem iso_size_bytes") }
} else {
    Fail("services/performance/src/main.rs ausente")
}

# 4. Configurações de performance
Write-Host "[5/6] Configurações de performance"
if (Test-Path "config/performance/budgets.conf") {
    $content = Get-Content "config/performance/budgets.conf" -Raw
    if ($content -match "boot_prime_ms|20000") { Pass("budgets.conf: boot_prime_ms") } else { Fail("budgets.conf: sem boot_prime_ms") }
    if ($content -match "idle_prime_mb|450") { Pass("budgets.conf: idle_prime_mb") } else { Fail("budgets.conf: sem idle_prime_mb") }
    if ($content -match "flyout_ms|150") { Pass("budgets.conf: flyout_ms") } else { Fail("budgets.conf: sem flyout_ms") }
    if ($content -match "iso_amd64_bytes|1400000000") { Pass("budgets.conf: iso_amd64_bytes") } else { Fail("budgets.conf: sem iso_amd64_bytes") }
    if ($content -match "iso_i386_bytes|900000000") { Pass("budgets.conf: iso_i386_bytes") } else { Fail("budgets.conf: sem iso_i386_bytes") }
} else {
    Fail("config/performance/budgets.conf ausente")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 25 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f25 = $state.fases | Where-Object { $_.id -eq 25 }
    if ($f25) {
        if ($f24.gate.blockers -eq 0) { Pass("Gate fase 24 GREEN: blockers = 0") } else { Fail("Gate fase 24: blockers = " + $f24.gate.blockers) }
    } else {
        Fail("Fase 24 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
