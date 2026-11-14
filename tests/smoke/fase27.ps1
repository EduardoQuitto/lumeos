<#
.SYNOPSIS
    Smoke test suite Phase 27 — Beta Release.
.DESCRIPTION
    Valida a estrutura da fase 27 (beta-release) conforme roadmap.yaml e PRD:
    - QA hardware real
    - docs + site + release 0.1 assinada
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests/smoke\fase27.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 27 — Beta Release ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura de documentação
Write-Host "[1/6] Estrutura de documentação"
$dirs = @("docs/qa", "docs/site")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. QA Hardware
Write-Host "[2/6] QA Hardware"
if (Test-Path "docs/qa/qa-hardware.md") {
    $content = Get-Content "docs/qa/qa-hardware.md" -Raw
    if ($content -match "QA|qa|hardware|Hardware") { Pass("QA hardware: documento presente") } else { Fail("QA hardware: sem conteúdo") }
    if ($content -match "QA|QA hardware") { Pass("QA hardware: contém QA") } else { Fail("QA hardware: sem referência QA") }
} else {
    Fail("docs/qa/qa-hardware.md ausente")
}

# 3. Site documentation
Write-Host "[3/6] Site documentation"
if (Test-Path "docs/site/index.md") {
    $content = Get-Content "docs/site/index.md" -Raw
    if ($content -match "Lume OS") { Pass("site: contém Lume OS") } else { Fail("site: sem referência Lume OS") }
    if ($content -match "download|Download|baixar") { Pass("site: contém download") } else { Fail("site: sem referência download") }
} else {
    Fail("docs/site/index.md ausente")
}

# 4. Release notes
Write-Host "[4/6] Release notes"
if (Test-Path "docs/release-notes-0.1.md") {
    $content = Get-Content "docs/release-notes-0.1.md" -Raw
    if ($content -match "release|Release|Lume OS") { Pass("release-notes: contém release info") } else { Fail("release-notes: sem release info") }
    if ($content -match "0\.1|0\.11|2026\.11") { Pass("release-notes: versão mencionada") } else { Fail("release-notes: sem versão") }
} else {
    Fail("docs/release-notes-0.1.md ausente")
}

# 5. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 27 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f27 = $state.fases | Where-Object { $_.id -eq 27 }
    if ($f27) {
        if ($f27.gate.blockers -eq 0) { Pass("Gate fase 27 GREEN: blockers = 0") } else { Fail("Gate fase 27: blockers = " + $f27.gate.blockers) }
    } else {
        Fail("Fase 27 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
