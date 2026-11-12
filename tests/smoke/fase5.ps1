<#
.SYNOPSIS
    Smoke test suite Phase 5 — Flyouts.
.DESCRIPTION
    Valida a estrutura da fase 5 (flyouts) conforme roadmap.yaml e PRD:
    - 4 flyouts: redes, quick settings, volume, calendario+notificacoes
    - Raio 16, vidro, slide 12px mola, abrir <150ms
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase5.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 5 — Flyouts ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura flyouts/
Write-Host "[1/6] Estrutura shell/quickshell/qml/flyouts/"
$dir = "shell/quickshell/qml/flyouts"
if (Test-Path $dir) { Pass("$dir existe") } else { Fail("$dir ausente") }

# 2. Quatro flyouts QML
Write-Host "[2/6] 4 flyouts QML (redes, quick settings, volume, calendario)"
$flyouts = @("FlyoutRedes", "FlyoutQuickSettings", "FlyoutVolume", "FlyoutCalendario")
foreach ($f in $flyouts) {
    $path = Join-Path $dir "$f.qml"
    if (Test-Path $path) { Pass("$f.qml existe") } else { Fail("$f.qml ausente") }
}

# 3. Validar conteudo dos flyouts (raio 16, vidro, slide, popup)
Write-Host "[3/6] Conteudo dos flyouts (raio 16, vidro, slide 12px, popup)"
foreach ($f in $flyouts) {
    $path = Join-Path $dir "$f.qml"
    $content = Get-Content $path -Raw
    $ok = $true
    if (-not ($content -match "Popup")) { $ok = $false; Fail("$f: nao e um Popup") }
    if (-not ($content -match "radius.*16")) { $ok = $false; Fail("$f: sem raio 16") }
    if (-not ($content -match "ShaderEffect|vidro|blur")) { $ok = $false; Fail("$f: sem efeito vidro (ShaderEffect)") }
    if (-not ($content -match "12|slide|NumberAnimation")) { $ok = $false; Fail("$f: sem animacao slide 12px") }
    if ($ok) { Pass("$f: popup + raio 16 + vidro + slide 12px") }
}

# 4. Validar conteudo especifico de cada flyout
Write-Host "[4/6] Conteudo especifico de cada flyout"

# FlyoutRedes: redes, senha, oculta, WireGuard
$content = Get-Content (Join-Path $dir "FlyoutRedes.qml") -Raw
if ($content -match "Redes|rede") { Pass("FlyoutRedes: lista de redes") } else { Fail("FlyoutRedes: sem lista de redes") }
if ($content -match "senha|Senha|oculta|Oculta|WireGuard|wireguard") { Pass("FlyoutRedes: senha/oculta/WireGuard") } else { Fail("FlyoutRedes: sem senha/oculta/WireGuard") }

# FlyoutQuickSettings: 6 toggles, 2 sliders, bateria, editar
$content = Get-Content (Join-Path $dir "FlyoutQuickSettings.qml") -Raw
if ($content -match "Configuracoes Rapidas|configuracoes rapidas") { Pass("FlyoutQuickSettings: titulo") } else { Fail("FlyoutQuickSettings: sem titulo") }
if ($content -match "Switch|switch|toggle|Toggle") { Pass("FlyoutQuickSettings: toggles") } else { Fail("FlyoutQuickSettings: sem toggles") }
if ($content -match "Slider|slider") { Pass("FlyoutQuickSettings: sliders") } else { Fail("FlyoutQuickSettings: sem sliders") }
if ($content -match "Bateria|bateria") { Pass("FlyoutQuickSettings: bateria") } else { Fail("FlyoutQuickSettings: sem bateria") }

# FlyoutVolume: dispositivos de audio
$content = Get-Content (Join-Path $dir "FlyoutVolume.qml") -Raw
if ($content -match "Som|som|audio|Audio") { Pass("FlyoutVolume: som/audio") } else { Fail("FlyoutVolume: sem som/audio") }
if ($content -match "dispositivo|Dispositivo|Saida|saida|Entrada|entrada") { Pass("FlyoutVolume: dispositivos") } else { Fail("FlyoutVolume: sem dispositivos") }

# FlyoutCalendario: mes, lista, limpar
$content = Get-Content (Join-Path $dir "FlyoutCalendario.qml") -Raw
if ($content -match "Calendario|calendario|Novembro|Mes|mes") { Pass("FlyoutCalendario: calendario/mes") } else { Fail("FlyoutCalendario: sem calendario/mes") }
if ($content -match "Notificacao|notificacao|Limpar|limpar") { Pass("FlyoutCalendario: notificacoes/limpar") } else { Fail("FlyoutCalendario: sem notificacoes/limpar") }

# 5. Shell.qml referencia os flyouts
Write-Host "[5/6] Shell.qml integra os flyouts"
if (Test-Path "shell/quickshell/qml/Shell.qml") {
    $content = Get-Content "shell/quickshell/qml/Shell.qml" -Raw
    if ($content -match "FlyoutRedes|FlyoutQuickSettings|FlyoutVolume|FlyoutCalendario|redes|Redes|volume|Volume|calendario|Calendario") {
        Pass("Shell.qml referencia os flyouts")
    } else {
        Fail("Shell.qml nao referencia os flyouts")
    }
} else {
    Fail("shell/quickshell/qml/Shell.qml ausente")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 5 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f5 = $state.fases | Where-Object { $_.id -eq 5 }
    if ($f5) {
        if ($f5.gate.blockers -eq 0) { Pass("Gate fase 5 GREEN: blockers = 0") } else { Fail("Gate fase 5: blockers = " + $f5.gate.blockers) }
    } else {
        Fail("Fase 5 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
