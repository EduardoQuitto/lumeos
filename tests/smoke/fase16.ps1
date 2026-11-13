<#
.SYNOPSIS
    Smoke test suite Phase 16 — Pendrive Persistente.
.DESCRIPTION
    Valida a estrutura da fase 16 (pendrive-persistente) conforme roadmap.yaml e PRD:
    - Criador USB LUKS + backup/restore
    - Instalação em pendrive persistente
    - Teste instalação em pendrive
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase16.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 16 — Pendrive Persistente ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do pendrive
Write-Host "[1/6] Estrutura apps/pendrive/qml/"
$dirs = @("apps/pendrive", "apps/pendrive/qml", "apps/instalador/scripts")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. PendriveCreator.qml
Write-Host "[2/6] apps/pendrive/qml/PendriveCreator.qml"
if (Test-Path "apps/pendrive/qml/PendriveCreator.qml") {
    $content = Get-Content "apps/pendrive/qml/PendriveCreator.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("PendriveCreator.qml: e janela de aplicacao") } else { Fail("PendriveCreator.qml: nao e ApplicationWindow") }
    if ($content -match "pendrive|Pendrive|USB|usb") { Pass("PendriveCreator.qml: selecao de pendrive") } else { Fail("PendriveCreator.qml: sem selecao de pendrive") }
    if ($content -match "LUKS|luks|criptografar|Criptografar") { Pass("PendriveCreator.qml: criptografia LUKS") } else { Fail("PendriveCreator.qml: sem criptografia LUKS") }
    if ($content -match "senhaLUKS|senhaConfirm|SENHA_LUKS") { Pass("PendriveCreator.qml: senha LUKS") } else { Fail("PendriveCreator.qml: sem senha LUKS") }
} else {
    Fail("apps/pendrive/qml/PendriveCreator.qml ausente")
}

# 3. Criador USB LUKS script
Write-Host "[3/6] apps/instalador/scripts/criador-usb-luks.sh"
if (Test-Path "apps/instalador/scripts/criador-usb-luks.sh") {
    $content = Get-Content "apps/instalador/scripts/criador-usb-luks.sh" -Raw
    if ($content -match "LUKS|luks|cryptsetup") { Pass("criador-usb-luks.sh: criptografia LUKS2") } else { Fail("criador-usb-luks.sh: sem criptografia LUKS2") }
    if ($content -match "mkfs.ext4|ext4") { Pass("criador-usb-luks.sh: formatacao ext4") } else { Fail("criador-usb-luks.sh: sem formatacao ext4") }
    if ($content -match "mount|Mount|montar|Montar") { Pass("criador-usb-luks.sh: montagem") } else { Fail("criador-usb-luks.sh: sem montagem") }
} else {
    Fail("apps/instalador/scripts/criador-usb-luks.sh ausente")
}

# 4. Backup/Restore script
Write-Host "[4/6] apps/instalador/scripts/backup-restore.sh"
if (Test-Path "apps/instalador/scripts/backup-restore.sh") {
    $content = Get-Content "apps/instalador/scripts/backup-restore.sh" -Raw
    if ($content -match "backup|Backup|backup-restore") { Pass("backup-restore.sh: funcao backup") } else { Fail("backup-restore.sh: sem funcao backup") }
    if ($content -match "restore|Restore|restaurar|Restaurar") { Pass("backup-restore.sh: funcao restore") } else { Fail("backup-restore.sh: sem funcao restore") }
    if ($content -match "tar czf|tar xzf") { Pass("backup-restore.sh: compactacao/descompactacao tar.gz") } else { Fail("backup-restore.sh: sem compactacao tar.gz") }
} else {
    Fail("apps/instalador/scripts/backup-restore.sh ausente")
}

# 5. Validar fluxo completo
Write-Host "[5/6] Validar fluxo completo: pendrive -> LUKS -> instalacao -> backup/restore"
$content = Get-Content "apps/pendrive/qml/PendriveCreator.qml" -Raw
if ($content -match "backup|Backup|backup-restore|Restaurar") { Pass("PendriveCreator.qml: referencia backup/restore") } else { Fail("PendriveCreator.qml: sem referencia backup/restore") }
if ($content -match "passoAtual|passos|PASSO") { Pass("PendriveCreator.qml: fluxo de passos") } else { Fail("PendriveCreator.qml: sem fluxo de passos") }

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 16 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f16 = $state.fases | Where-Object { $_.id -eq 16 }
    if ($f16) {
        if ($f16.gate.blockers -eq 0) { Pass("Gate fase 16 GREEN: blockers = 0") } else { Fail("Gate fase 16: blockers = " + $f16.gate.blockers) }
    } else {
        Fail("Fase 16 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
