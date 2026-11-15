<#
.SYNOPSIS
    Smoke test suite Phase 29 — Daemons Rust (Mission Control Bloco B).
.DESCRIPTION
    Valida a estrutura da fase 29 (daemons Rust reais) conforme roadmap.yaml:
    - lume-detect: detecção de hardware real e D-Bus
    - lume-updated: atualização A/B com manifesto assinado
    - lume-shield: AppArmor, seccomp, nftables, D-Bus
    - lume-filesd: operações de arquivo com D-Bus
    - lume-stored: armazenamento imutável com SquashFS+verity
    - lume-cli: CLI completa com todos os subcomandos
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase29.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Fase 29 — Bloco B: Daemons Rust Reais ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura dos serviços Rust
Write-Host "[1/6] Estrutura services/"
$dirs = @("services", "services/detect", "services/updated", "services/shield", "services/filesd", "services/stored", "services/cli")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. Detalhes de cada serviço
Write-Host "[2/6] Serviços Rust com Cargo.toml e src/main.rs"
$services = @("detect", "updated", "shield", "filesd", "stored", "cli")
foreach ($s in $services) {
    $dir = "services/$s"
    $cargo = "$dir/Cargo.toml"
    $src = "$dir/src/main.rs"
    if (Test-Path $cargo) { Pass("services/$s/Cargo.toml existe") } else { Fail("services/$s/Cargo.toml ausente") }
    if (Test-Path $src) { Pass("services/$s/src/main.rs existe") } else { Fail("services/$s/src/main.rs ausente") }
}

# 3. Validar conteúdo dos serviços
Write-Host "[4/6] Conteúdo dos serviços Rust"
if (Test-Path "services/detect/src/main.rs") {
    $content = Get-Content "services/detect/src/main.rs" -Raw
    if ($content -match "tokens.json|tokens\.json") { Pass("lume-detect: tem tokens.json") } else { Fail("lume-detect: sem tokens.json") }
    if ($content -match "D-Bus|dbus|D-Bus") { Pass("lume-detect: tem D-Bus") } else { Fail("lume-detect: sem D-Bus") }
}

if (Test-Path "services/updated/src/main.rs") {
    $content = Get-Content "services/updated/src/main.rs" -Raw
    if ($content -match "manifesto|manifesto|manifesto") { Pass("lume-updated: tem manifesto") } else { Fail("lume-updated: sem manifesto") }
    if ($content -match "minisign|minisign") { Pass("lume-updated: tem minisign") } else { Fail("lume-updated: sem minisign") }
}

if (Test-Path "services/shield/src/main.rs") {
    $content = Get-Content "services/shield/src/main.rs" -Raw
    if ($content -match "AppArmor|apparmor") { Pass("lume-shield: AppArmor") } else { Fail("lume-shield: sem AppArmor") }
    if ($content -match "seccomp|seccomp") { Pass("lume-shield: seccomp") } else { Fail("lume-shield: sem seccomp") }
    if ($content -match "nftables|nftables") { Pass("lume-shield: nftables") } else { Fail("lume-shield: sem nftables") }
    if ($content -match "TPM2|tpm2|TPM2") { Pass("lume-shield: TPM2") } else { Fail("lume-shield: sem TPM2") }
}

if (Test-Path "services/filesd/src/main.rs") {
    $content = Get-Content "services/filesd/src/main.rs" -Raw
    if ($content -match "filesd|filesd|filesd") { Pass("lume-filesd: existe") } else { Fail("lume-filesd: sem conteúdo") }
    if ($content -match "D-Bus|dbus|D-Bus") { Pass("lume-filesd: D-Bus") } else { Fail("lume-filesd: sem D-Bus") }
}

if (Test-Path "services/stored/src/main.rs") {
    $content = Get-Content "services/stored/src/main.rs" -Raw
    if ($content -match "SquashFS|squashfs|verity|verity") { Pass("lume-stored: SquashFS+verity") } else { Fail("lume-stored: sem SquashFS+verity") }
}

if (Test-Path "services/cli/src/main.rs") {
    $content = Get-Content "services/cli/src/main.rs" -Raw
    if ($content -match "update|update|update") { Pass("lume-cli: comando update") } else { Fail("lume-cli: sem update") }
    if ($content -match "shield|Shield|shield") { Pass("lume-cli: shield") } else { Fail("lume-cli: sem shield") }
    if ($content -match "tier|tier|tier") { Pass("lume-cli: tier") } else { Fail("lume-cli: sem tier") }
    if ($content -match "store|store|store") { Pass("lume-cli: store") } else { Fail("lume-cli: sem store") }
    if ($content -match "fetch|fetch|fetch") { Pass("lume-cli: fetch") } else { Fail("lume-cli: sem fetch") }
    if ($content -match "session|session|session") { Pass("lume-cli: session") } else { Fail("lume-cli: sem session") }
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 29 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f29 = $state.fases | Where-Object { $_.id -eq 29 }
    if ($f29) {
        if ($f29.gate.blockers -eq 0) { Pass("Gate fase 29 GREEN: blockers = 0") } else { Fail("Gate fase 29: blockers = " + $f29.gate.blockers) }
    } else {
        Fail("Fase 29 não encontrada no state")
    }
} catch {
    Fail("Não foi possível consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
