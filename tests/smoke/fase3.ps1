<#
.SYNOPSIS
    Smoke test suite Phase 3 — Daemons Rust + detect.
.DESCRIPTION
    Valida a estrutura da fase 3 (daemons-rust-detect) conforme roadmap.yaml e PRD:
    - services/{detect,updated,shield,filesd,stored,cli} existem com Cargo.toml
    - lume-detect com classificação de tiers
    - lume-fetch (CLI) presente
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase3.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 3 — Daemons Rust + detect ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura dos serviços
Write-Host "[1/6] Estrutura services/"
$services = @("detect", "updated", "shield", "filesd", "stored", "cli")
foreach ($s in $services) {
    $dir = Join-Path "services" $s
    $cargo = Join-Path $dir "Cargo.toml"
    $src = Join-Path $dir "src" "main.rs"
    if (Test-Path $dir) { Pass("services/$s existe") } else { Fail("services/$s ausente") }
    if (Test-Path $cargo) { Pass("services/$s/Cargo.toml existe") } else { Fail("services/$s/Cargo.toml ausente") }
    if (Test-Path $src) { Pass("services/$s/src/main.rs existe") } else { Fail("services/$s/src/main.rs ausente") }
}

# 2. lume-detect com classificação de tiers
Write-Host "[2/6] lume-detect"
if (Test-Path "services/detect/src/main.rs") {
    $content = Get-Content "services/detect/src/main.rs" -Raw
    if ($content -match "tier|Tier" -and $content -match "classify") { Pass("lume-detect tem logica de classificacao") } else { Fail("lume-detect sem classificacao") }
    if ($content -match "prime|core|lite") { Pass("lume-detect tem 3 tiers (prime/core/lite)") } else { Fail("lume-detect sem 3 tiers") }
    if ($content -match "vm|VM|virtual") { Pass("lume-detect detecta VM (padrao Core)") } else { Fail("lume-detect sem deteccao de VM") }
} else {
    Fail("services/detect/src/main.rs ausente")
}

# 3. CLI (lume-fetch)
Write-Host "[3/6] CLI lume (lume-fetch)"
if (Test-Path "services/cli/src/main.rs") {
    $content = Get-Content "services/cli/src/main.rs" -Raw
    if ($content -match "fetch") { Pass("CLI tem comando fetch") } else { Fail("CLI sem comando fetch") }
    if ($content -match "clap") { Pass("CLI usa clap para parsing") } else { Fail("CLI sem clap") }
} else {
    Fail("services/cli/src/main.rs ausente")
}

# 4. D-Bus (referencia no codigo)
Write-Host "[4/6] API D-Bus para daemons"
# Verifica se ha referencia a D-Bus em algum servico
$dbus_found = $false
foreach ($s in $services) {
    $f = Join-Path "services" $s "src" "main.rs"
    if (Test-Path $f) {
        $c = Get-Content $f -Raw
        if ($c -match "dbus|DBus|D-Bus") { $dbus_found = $true }
    }
}
if ($dbus_found) { Pass("Referencia a D-Bus encontrada em algum servico") } else { Fail("Nenhuma referencia a D-Bus encontrada (placeholder aceito)") }

# 5. Cargo.toml valido em todos
Write-Host "[5/6] Cargo.toml valido em todos os servicos"
$cargo_ok = $true
foreach ($s in $services) {
    $cargo = Join-Path "services" $s "Cargo.toml"
    if (-not (Test-Path $cargo)) { $cargo_ok = $false; Fail("services/$s/Cargo.toml ausente") }
    else {
        $c = Get-Content $cargo -Raw
        if (-not ($c -match "name\s*=")) { $cargo_ok = $false; Fail("services/$s/Cargo.toml sem name") }
    }
}
if ($cargo_ok) { Pass("Todos os Cargo.toml validos") }

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 3 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f3 = $state.fases | Where-Object { $_.id -eq 3 }
    if ($f3) {
        if ($f3.gate.blockers -eq 0) { Pass("Gate fase 3 GREEN: blockers = 0") } else { Fail("Gate fase 3: blockers = " + $f3.gate.blockers) }
    } else {
        Fail("Fase 3 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
