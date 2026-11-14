<#
.SYNOPSIS
    Smoke test suite Phase 24 — i18n + a11y.
.DESCRIPTION
    Valida a estrutura da fase 24 (i18n-a11y) conforme roadmap.yaml e PRD:
    - pt/en 100%
    - Orca + alto contraste
    - movimento reduzido
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase24.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 24 — i18n + a11y ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura dos arquivos de tradução
Write-Host "[1/6] Estrutura apps/i18n/locales/"
$dirs = @("apps/i18n", "apps/i18n/locales", "apps/i18n/locales/pt-BR", "apps/i18n/locales/en-US", "config/a11y")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. tokens de tradução pt-BR e en-US
Write-Host "[2/6] Arquivos de tradução pt-BR e en-US"
$locales = @("pt-BR", "en-US")
foreach ($lang in $locales) {
    $f = "apps/i18n/locales/$lang/messages.json"
    if (Test-Path $f) {
        $content = Get-Content $f -Raw | ConvertFrom-Json
        $chaves = $content.PSObject.Properties.Name
        if ($chaves.Length -gt 0) { Pass("$lang: $($chaves.Length) chaves de tradução") } else { Fail("$lang: sem chaves de tradução") }
    } else {
        Fail("$f ausente")
    }
}

# 3. Validação de tradução equivalente entre pt-BR e en-US
Write-Host "[3/6] Validação de tradução entre pt-BR e en-US"
$pt = Get-Content "apps/i18n/locales/pt-BR/messages.json" -Raw | ConvertFrom-Json
$en = Get-Content "apps/i18n/locales/en-US/messages.json" -Raw | ConvertFrom-Json
$chavesPt = $pt.PSObject.Properties.Name
$chavesEn = $en.PSObject.Properties.Name
$chavesComuns = $chavesPt | Where-Object { $chavesEn -contains $_ }
if ($chavesComuns.Count -eq $chavesPt.Count -and $chavesComuns.Count -eq $chavesEn.Count) {
    Pass("pt-BR e en-US têm mesmas $($chavesComuns.Count) chaves de tradução")
} else {
    Fail("pt-BR ($($chavesPt.Count)) e en-US ($($chavesEn.Count)) não têm mesmas chaves")
}

# 4. Arquivos de acessibilidade (a11y)
Write-Host "[4/6] Acessibilidade (a11y): Orca, alto contraste, movimento reduzido"
$a11yFiles = @(
    "config/a11y/orca-config",
    "config/a11y/alto-contraste.conf",
    "config/a11y/movimento-reduzido.conf"
)
foreach ($f in $a11yFiles) {
    if (Test-Path $f) { Pass("$f existe") } else { Fail("$f ausente") }
}

# 5. Conteúdo do a11y
Write-Host "[5/6] Conteúdo dos arquivos de acessibilidade"
if (Test-Path "config/a11y/orca-config") {
    $content = Get-Content "config/a11y/orca-config" -Raw
    if ($content -match "orca|Orca") { Pass("orca-config: referencia Orca") } else { Fail("orca-config: sem referencia Orca") }
    if ($content -match "enabled|habilitado") { Pass("orca-config: tem configuracao de habilitado") } else { Fail("orca-config: sem configuracao de habilitado") }
}
if (Test-Path "config/a11y/alto-contraste.conf") {
    $content = Get-Content "config/a11y/alto-contraste.conf" -Raw
    if ($content -match "alto|contraste|alto-contraste") { Pass("alto-contraste: configuracao de alto contraste") } else { Fail("alto-contraste: sem configuracao de alto contraste") }
}
if (Test-Path "config/a11y/movimento-reduzido.conf") {
    $content = Get-Content "config/a11y/movimento-reduzido.conf" -Raw
    if ($content -match "movimento|movimento reduzido|reduzido") { Pass("movimento-reduzido: configuracao de movimento reduzido") } else { Fail("movimento-reduzido: sem configuracao de movimento reduzido") }
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 24 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f24 = $state.fases | Where-Object { $_.id -eq 24 }
    if ($f24) {
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
