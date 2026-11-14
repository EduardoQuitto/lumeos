<#
.SYNOPSIS
    Smoke test suite Phase 28 — ISO amd64 boot (Bloco A).
.DESCRIPTION
    Valida a estrutura da fase 28 (iso-amd64-boot) conforme roadmap.yaml e PRD:
    - backend: backend axum+SQLite+SSE :7777
    - web: web Svelte painel :7777
    - qemu-smoke: boot QEMU <30s + screendump + ISO amd64/i386
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

Write-Host "=== Smoke test Phase 28 — ISO amd64 boot (Bloco A) ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do backend
Write-Host "[1/6] Estrutura mission-control/backend/"
$dirs = @("mission-control/backend", "mission-control/backend/src")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. Cargo.toml
Write-Host "[2/6] mission-control/backend/Cargo.toml"
if (Test-Path "mission-control/backend/Cargo.toml") {
    $content = Get-Content "mission-control/backend/Cargo.toml" -Raw
    if ($content -match "axum") { Pass("Cargo.toml: axum") } else { Fail("Cargo.toml: sem axum") }
    if ($content -match "tokio") { Pass("Cargo.toml: tokio") } else { Fail("Cargo.toml: sem tokio") }
    if ($content -match "serde") { Pass("Cargo.toml: serde") } else { Fail("Cargo.toml: sem serde") }
    if ($content -match "serde_json") { Pass("Cargo.toml: serde_json") } else { Fail("Cargo.toml: sem serde_json") }
    if ($content -match "rusqlite") { Pass("Cargo.toml: rusqlite") } else { Fail("Cargo.toml: sem rusqlite") }
} else {
    Fail("mission-control/backend/Cargo.toml ausente")
}

# 3. main.rs
Write-Host "[4/6] mission-control/backend/src/main.rs"
if (Test-Path "mission-control/backend/src/main.rs") {
    $content = Get-Content "mission-control/backend/src/main.rs" -Raw
    if ($content -match "axum") { Pass("main.rs: axum") } else { Fail("main.rs: sem axum") }
    if ($content -match "SQLite|sqlite") { Pass("main.rs: SQLite") } else { Fail("main.rs: sem SQLite") }
    if ($content -match "SSE|sse") { Pass("main.rs: SSE") } else { Fail("main.rs: sem SSE") }
} else {
    Fail("mission-control/backend/src/main.rs ausente")
}

# 5. CI QEMU
Write-Host "[5/6] .github/workflows/ci.yml e tests/qemu/smoke.sh"
if (Test-Path ".github/workflows/ci.yml") {
    $content = Get-Content ".github/workflows/ci.yml" -Raw
    if ($content -match "ci") { Pass("ci.yml: ci") } else { Fail("ci.yml: sem ci") }
    if ($content -match "build-smoke|build") { Pass("ci.yml: build") } else { Fail("ci.yml: sem build") }
} else {
    Fail(".github/workflows/ci.yml ausente")
}

if (Test-Path "tests/qemu/smoke.sh") {
    $content = Get-Content "tests/qemu/smoke.sh" -Raw
    if ($content -match "QEMU|qemu") { Pass("smoke.sh: QEMU") } else { Fail("smoke.sh: sem QEMU") }
    if ($content -match "screendump|Screendump") { Pass("smoke.sh: screendump QMP") } else { Fail("smoke.sh: sem screendump QMP") }
} else {
    Fail("tests/qemu/smoke.sh ausente")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 28 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f28 = $state.fases | Where-Object { $_.id -eq 28 }
    if ($f28) {
        if ($f27.gate.blockers -eq 0) { Pass("Gate fase 28 GREEN: blockers = 0") } else { Fail("Gate fase 28: blockers = " + $f27.gate.blockers) }
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
