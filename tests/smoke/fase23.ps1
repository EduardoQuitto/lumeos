<#
.SYNOPSIS
    Smoke test suite Phase 23 — Update A/B GitHub.
.DESCRIPTION
    Valida a estrutura da fase 23 (update-ab-github) conforme roadmap.yaml e PRD:
    - backend-smoke: backend de update funcionando
    - update-manifest-smoke: manifesto assinado (minisign)
    - update-rollback-smoke: rollback automático
    - update-vm-smoke: update em VM
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase23.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 23 — Update A/B GitHub ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do updated
Write-Host "[1/6] Estrutura services/updated/"
$dirs = @("services/updated", "services/updated/src")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. Cargo.toml
Write-Host "[2/6] services/updated/Cargo.toml"
if (Test-Path "services/updated/Cargo.toml") {
    $content = Get-Content "services/updated/Cargo.toml" -Raw
    if ($content -match "serde") { Pass("Cargo.toml: serde") } else { Fail("Cargo.toml: sem serde") }
    if ($content -match "serde_json") { Pass("Cargo.toml: serde_json") } else { Fail("Cargo.toml: sem serde_json") }
    if ($content -match "rusqlite") { Pass("Cargo.toml: rusqlite") } else { Fail("Cargo.toml: sem rusqlite") }
} else {
    Fail("services/updated/Cargo.toml ausente")
}

# 3. main.rs do updated
Write-Host "[3/6] services/updated/src/main.rs"
if (Test-Path "services/updated/src/main.rs") {
    $content = Get-Content "services/updated/src/main.rs" -Raw
    if ($content -match "verity|Verity") { Pass("main.rs: verity") } else { Fail("main.rs: sem verity") }
    if ($content -match "sha256|SHA256|sha256") { Pass("main.rs: SHA256") } else { Fail("main.rs: sem SHA256") }
    if ($content -match "slot|Slot") { Pass("main.rs: slots A/B") } else { Fail("main.rs: sem slots A/B") }
    if ($content -match "rollback|rollback") { Pass("main.rs: rollback automático") } else { Fail("main.rs: sem rollback automático") }
} else {
    Fail("services/updated/src/main.rs ausente")
}

# 4. Exemplo de manifesto
Write-Host "[4/6] config/update/update-manifest-example.json"
if (Test-Path "config/update/update-manifest-example.json") {
    $content = Get-Content "config/update/update-manifest-example.json" -Raw
    if ($content -match "sha256") { Pass("update-manifest-example.json: sha256") } else { Fail("update-manifest-example.json: sem sha256") }
    if ($content -match "minisign") { Pass("update-manifest-example.json: minisign") } else { Fail("update-manifest-example.json: sem minisign") }
    if ($content -match "slot") { Pass("update-manifest-example.json: slot") } else { Fail("update-manifest-example.json: sem slot") }
} else {
    Fail("config/update/update-manifest-example.json ausente")
}

# 5. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 23 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f23 = $state.fases | Where-Object { $_.id -eq 23 }
    if ($f23) {
        if ($f23.gate.blockers -eq 0) { Pass("Gate fase 23 GREEN: blockers = 0") } else { Fail("Gate fase 23: blockers = " + $f23.gate.blockers) }
    } else {
        Fail("Fase 23 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
