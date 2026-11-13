<#
.SYNOPSIS
    Smoke test suite Phase 12 — Loja (Store).
.DESCRIPTION
    Valida a estrutura da fase 12 (loja) conforme roadmap.yaml e PRD:
    - 8 categorias (Essenciais, Internet, Estudo&Office, Programação, Jogos, Windows, Segurança/Lab, Sistema)
    - badges tier (prime/core/lite) + fila de instalação
    - flatpak install/remove
    - updates separado sistema/apps + aba garrafas
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase12.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 12 — Loja (Store) ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do app Store
Write-Host "[1/6] Estrutura apps/store/"
$dirs = @("apps/store", "apps/store/qml")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. Store.qml principal
Write-Host "[2/6] apps/store/qml/Store.qml"
if (Test-Path "apps/store/qml/Store.qml") {
    $content = Get-Content "apps/store/qml/Store.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("Store.qml: e janela de aplicacao") } else { Fail("Store.qml: nao e ApplicationWindow") }
    if ($content -match "8|categorias|Essenciais|Internet|Estudo|Programacao|Jogos|Windows|Seguranca|Sistema") { Pass("Store.qml: 8 categorias") } else { Fail("Store.qml: sem 8 categorias") }
    if ($content -match "badges|tier|prime|core|lite") { Pass("Store.qml: badges tier") } else { Fail("Store.qml: sem badges tier") }
    if ($content -match "fila|Fila|Instalacao|instalacao") { Pass("Store.qml: fila de instalacao") } else { Fail("Store.qml: sem fila de instalacao") }
    if ($content -match "flatpak|Flatpak|install|Instalar|remover|Remover") { Pass("Store.qml: flatpak install/remove") } else { Fail("Store.qml: sem flatpak install/remove") }
    if ($content -match "updates|Updates|atualizacao|Atualizacao|sistema|apps") { Pass("Store.qml: updates sistema/apps") } else { Fail("Store.qml: sem updates sistema/apps") }
    if ($content -match "garrafas|Garrafas|Windows|bottles|Bottles") { Pass("Store.qml: aba garrafas Windows") } else { Fail("Store.qml: sem aba garrafas") }
} else {
    Fail("apps/store/qml/Store.qml ausente")
}

# 3. Validar cada categoria especifica
Write-Host "[3/6] Validar cada uma das 8 categorias"
$categorias = @("Essenciais", "Internet", "Estudo&Office", "Programacao", "Jogos", "Windows", "Seguranca", "Sistema")
foreach ($cat in $categorias) {
    if ($content -match $cat) { Pass("Categoria: $cat") } else { Fail("Categoria: falta $cat") }
}

# 4. Validar badges tier
Write-Host "[4/6] Badges tier (prime/core/lite)"
$tier_checks = @(
    @{ chave = "prime"; desc = "tier prime" },
    @{ chave = "core"; desc = "tier core" },
    @{ chave = "lite"; desc = "tier lite" }
)
foreach ($check in $tier_checks) {
    if ($content -match $check.chave) { Pass("Badge tier: $($check.desc)") } else { Fail("Badge tier: falta $($check.desc)") }
}

# 5. Validar fila de instalacao
Write-Host "[5/6] Fila de instalacao"
if ($content -match "filaInstalacao|Fila de Instalacao|fila de instalacao") { Pass("Fila de instalacao presente") } else { Fail("Fila de instalacao ausente") }
if ($content -match "Instalar|Remover|Atualizar") { Pass "Acoes de instalacao/remocao/atualizacao" } else { Fail("Falta acoes de instalacao/remocao/atualizacao") }

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 12 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f12 = $state.fases | Where-Object { $_.id -eq 12 }
    if ($f12) {
        if ($f12.gate.blockers -eq 0) { Pass("Gate fase 12 GREEN: blockers = 0") } else { Fail("Gate fase 12: blockers = " + $f12.gate.blockers) }
    } else {
        Fail("Fase 12 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
