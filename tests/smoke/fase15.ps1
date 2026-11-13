<#
.SYNOPSIS
    Smoke test suite Phase 15 — Instalador HD.
.DESCRIPTION
    Valida a estrutura da fase 15 (instalador-hd) conforme roadmap.yaml e PRD:
    - Instalador HD: interface de instalação em disco vazio
    - LUKS+A/B: partição criptografada com slots A e B
    - Instalação em VM teste
    - Teste de instalação completa
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase15.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 15 — Instalador HD ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do instalador
Write-Host "[1/6] Estrutura apps/instalador/"
$dirs = @("apps/instalador", "apps/instalador/qml", "apps/instalador/scripts")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. Instalador QML
Write-Host "[2/6] apps/instalador/qml/Instalador.qml"
if (Test-Path "apps/instalador/qml/Instalador.qml") {
    $content = Get-Content "apps/instalador/qml/Instalador.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("Instalador.qml: e janela de aplicacao") } else { Fail("Instalador.qml: nao e ApplicationWindow") }
    if ($content -match "disco|Disco|disco") { Pass("Instalador.qml: selecao de disco") } else { Fail("Instalador.qml: sem selecao de disco") }
    if ($content -match "LUKS|Luks|luks|criptografia|Criptografia") { Pass("Instalador.qml: criptografia LUKS") } else { Fail("Instalador.qml: sem criptografia LUKS") }
    if ($content -match "slot|Slot|A/B|slot A|slot B") { Pass("Instalador.qml: slots A/B") } else { Fail("Instalador.qml: sem slots A/B") }
} else {
    Fail("apps/instalador/qml/Instalador.qml ausente")
}

# 3. Script de instalacao
Write-Host "[3/6] apps/instalador/scripts/instalar-hd.sh"
if (Test-Path "apps/instalador/scripts/instalar-hd.sh") {
    $content = Get-Content "apps/instalador/scripts/instalar-hd.sh" -Raw
    if ($content -match "LUKS|luks|criptografar|Criptografar") { Pass("instalar-hd.sh: criptografia LUKS") } else { Fail("instalar-hd.sh: sem criptografia LUKS") }
    if ($content -match "particionar|Particionar|particao|Particao") { Pass("instalar-hd.sh: particionamento") } else { Fail("instalar-hd.sh: sem particionamento") }
    if ($content -match "slot|Slot|A/B") { Pass("instalar-hd.sh: slots A/B") } else { Fail("instalar-hd.sh: sem slots A/B") }
    if ($content -match "grub|GRUB|grub-install") { Pass("instalar-hd.sh: instalacao GRUB") } else { Fail("instalar-hd.sh: sem instalacao GRUB") }
} else {
    Fail("apps/instalador/scripts/instalar-hd.sh ausente")
}

# 4. Validar funcionalidades principais
Write-Host "[4/6] Validar funcionalidades principais"
$content = Get-Content "apps/instalador/qml/Instalador.qml" -Raw
if ($content -match "discoSelecionado|discoSelecionado") { Pass("Instalador.qml: selecao de disco") } else { Fail("Instalador.qml: sem selecao de disco") }
if ($content -match "senhaLUKS|senhaConfirm|SENHA_LUKS") { Pass("Instalador.qml: senha LUKS") } else { Fail("Instalador.qml: sem senha LUKS") }
if ($content -match "particao|Particao|particionar|Particionar") { Pass("Instalador.qml: particionamento") } else { Fail("Instalador.qml: sem particionamento") }

# 5. Script de instalacao funcional
Write-Host "[6/6] Validar script de instalacao"
$instaladorScript = Get-Content "apps/instalador/scripts/instalar-hd.sh" -Raw
$instalacao_checks = @(
    @{ chave = "particionar_disco"; desc = "funcao particionar_disco" },
    @{ chave = "criptografar_luks"; desc = "funcao criptografar_luks" },
    @{ chave = "instalar_sistema"; desc = "funcao instalar_sistema" },
    @{ chave = "instalar_grub"; desc = "funcao instalar_grub" },
    @{ chave = "wipefs|mkpart|GPT" } = "particionamento GPT",
    @{ chave = "cryptsetup" } = "criptografia LUKS2",
    @{ chave = "grub-install" } = "instalacao GRUB"
)
foreach ($check in $instalacao_checks) {
    $chave = $check.chave
    $desc = $check.desc
    if ($content -match $chave) { Pass("Instalador: $desc") } else { Fail("Instalador: falta $desc") }
}

# Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 15 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f15 = $state.fases | Where-Object { $_.id -eq 15 }
    if ($f14) {
        if ($f14.gate.blockers -eq 0) { Pass("Gate fase 14 GREEN: blockers = 0") } else { Fail("Gate fase 14: blockers = " + $f14.gate.blockers) }
    } else {
        Fail("Fase 14 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
