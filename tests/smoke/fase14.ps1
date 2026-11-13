<#
.SYNOPSIS
    Smoke test suite Phase 14 — OOBE + Login + Energia.
.DESCRIPTION
    Valida a estrutura da fase 14 (oobe-login-energia) conforme roadmap.yaml e PRD:
    - OOBE: cartao central de vidro (idioma/teclado/rede/usuario/criptografia/tier/Essenciais)
    - Greeter/Lock: wallpaper escurecido+blur, relogio grande, avatar central, senha em pílula
    - Telas Plymouth: desligar/reiniciar/Instalando atualizacao
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase14.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 14 — OOBE + Login + Energia ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura dos arquivos
Write-Host "[1/6] Estrutura arquivos da fase 14"
$dirs = @("apps/oobe/qml", "apps/greeter/qml", "iso/plymouth/screens")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. OOBE.qml
Write-Host "[2/6] apps/oobe/qml/Oobe.qml"
if (Test-Path "apps/oobe/qml/Oobe.qml") {
    $content = Get-Content "apps/oobe/qml/Oobe.qml" -Raw
    if ($content -match "ApplicationWindow|Popup") { Pass("OOBE.qml: janela/popup") } else { Fail("OOBE.qml: sem janela/popup") }
    if ($content -match "cartao|Cartao|radius.*16|radius.*12") { Pass("OOBE.qml: cartao central de vidro") } else { Fail("OOBE.qml: sem cartao de vidro") }
    if ($content -match "Idioma|idioma|Teclado|teclado|Rede|rede|Usuario|usuario|Criptografia|criptografia|Tier|tier|Essenciais|essenciais") { Pass("OOBE.qml: passos OOBE (idioma/teclado/rede/usuario/criptografia/tier/essenciais)") } else { Fail("OOBE.qml: sem passos OOBE completos") }
} else {
    Fail("apps/oobe/qml/Oobe.qml ausente")
}

# 3. Greeter.qml
Write-Host "[3/6] apps/greeter/qml/Greeter.qml"
if (Test-Path "apps/greeter/qml/Greeter.qml") {
    $content = Get-Content "apps/greeter/qml/Greeter.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("Greeter.qml: e janela de aplicacao") } else { Fail("Greeter.qml: nao e ApplicationWindow") }
    if ($content -match "relogio|Relogio|HH:mm|00:00") { Pass("Greeter.qml: relogio grande") } else { Fail("Greeter.qml: sem relogio grande") }
    if ($content -match "avatar|Avatar|avatar central") { Pass("Greeter.qml: avatar central") } else { Fail("Greeter.qml: sem avatar central") }
    if ($content -match "senha|Senha|senha em pilula|pilula") { Pass("Greeter.qml: senha em pilula") } else { Fail("Greeter.qml: sem senha em pilula") }
    if ($content -match "blur|desfocado|escurecido") { Pass("Greeter.qml: wallpaper escurecido+blur") } else { Fail("Greeter.qml: sem wallpaper escurecido+blur") }
} else {
    Fail("apps/greeter/qml/Greeter.qml ausente")
}

# 4. Plymouth screens
Write-Host "[4/6] Plymouth screens (desligar/reiniciar/atualizar)"
$plymouth_files = @("iso/plymouth/screens/shutdown.plymouth", "iso/plymouth/screens/reiniciar.plymouth", "iso/plymouth/screens/atualizando.plymouth")
foreach ($f in $plymouth_files) {
    if (Test-Path $f) { Pass("$f existe") } else { Fail("$f ausente") }
}

# 5. Validar conteudo Plymouth
Write-Host "[5/6] Conteudo Plymouth (desligar/reiniciar/atualizar)"
if (Test-Path "iso/plymouth/screens/shutdown.plymouth") {
    $content = Get-Content "iso/plymouth/screens/shutdown.plymouth" -Raw
    if ($content -match "desligar|Desligar|desligando|Desligando") { Pass("Plymouth: tela desligar") } else { Fail("Plymouth: sem tela desligar") }
}
if (Test-Path "iso/plymouth/screens/reiniciar.plymouth") {
    $content = Get-Content "iso/plymouth/screens/reiniciar.plymouth" -Raw
    if ($content -match "reiniciar|Reiniciar") { Pass("Plymouth: tela reiniciar") } else { Fail("Plymouth: sem tela reiniciar") }
}
if (Test-Path "iso/plymouth/screens/atualizando.plymouth") {
    $content = Get-Content "iso/plymouth/screens/atualizando.plymouth" -Raw
    if ($content -match "atualizacao|Atualizacao|Instalando|instalando") { Pass("Plymouth: tela atualizacao") } else { Fail("Plymouth: sem tela atualizacao") }
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 14 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f14 = $state.fases | Where-Object { $_.id -eq 14 }
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
