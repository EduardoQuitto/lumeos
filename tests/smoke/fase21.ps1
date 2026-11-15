<#
.SYNOPSIS
    Smoke test suite Phase 21 — Shield Hardening.
.DESCRIPTION
    Valida a estrutura da fase 21 (shield-hardening) conforme roadmap.yaml e PRD:
    - verity+lockdown
    - AppArmor+seccomp
    - nftables+testes tamper
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase21.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 21 — Shield Hardening ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do backend shield
Write-Host "[1/6] Estrutura services/shield/"
$dirs = @("services/shield", "services/shield/src")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. shield-hardening.sh
Write-Host "[2/6] services/shield/hardening/shield-hardening.sh"
if (Test-Path "services/shield/hardening/shield-hardening.sh") {
    $content = Get-Content "apps/windows/scripts/shield-hardening.sh" -ErrorAction SilentlyContinue
    if (-not $content) {
        $content = Get-Content "services/shield/hardening/shield-hardening.sh" -Raw
    }
    if ($content -match "verity|Verity") { Pass("shield-hardening.sh: verity") } else { Fail("shield-hardening.sh: sem verity") }
    if ($content -match "lockdown|Lockdown") { Pass("shield-hardening.sh: lockdown") } else { Fail("shield-hardening.sh: sem lockdown") }
    if ($content -match "AppArmor|apparmor") { Pass("shield-hardening.sh: AppArmor") } else { Fail("shield-hardening.sh: sem AppArmor") }
    if ($content -match "seccomp") { Pass("shield-hardening.sh: seccomp") } else { Fail("shield-hardening.sh: sem seccomp") }
    if ($content -match "nftables") { Pass("shield-hardening.sh: nftables") } else { Fail("shield-hardening.sh: sem nftables") }
} else {
    Fail("services/shield/hardening/shield-hardening.sh ausente")
}

# 3. Perfil AppArmor
Write-Host "[4/6] config/apparmor/lume-shield.profile"
if (Test-Path "config/apparmor/lume-shield.profile") {
    $content = Get-Content "config/apparmor/lume-shield.profile" -Raw
    if ($content -match "apparmor|AppArmor") { Pass("AppArmor profile: contém AppArmor") } else { Fail("AppArmor profile: sem AppArmor") }
} else {
    Fail("config/apparmor/lume-shield.profile ausente")
}

# 4. Perfil seccomp
Write-Host "[5/6] config/seccomp/seccomp-profile.sh"
if (Test-Path "config/seccomp/seccomp-profile.sh") {
    $content = Get-Content "config/seccomp/seccomp-profile.sh" -Raw
    if ($content -match "seccomp|Seccomp") { Pass("seccomp-profile.sh: contém seccomp") } else { Fail("seccomp-profile.sh: sem seccomp") }
} else {
    Fail("config/seccomp/seccomp-profile.sh ausente")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 21 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f21 = $state.fases | Where-Object { $_.id -eq 21 }
    if ($f21) {
        if ($f21.gate.blockers -eq 0) { Pass("Gate fase 21 GREEN: blockers = 0") } else { Fail("Gate fase 21: blockers = " + $f21.gate.blockers) }
    } else {
        Fail("Fase 21 não encontrada no state")
    }
} catch {
    Fail("Não foi possível consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
