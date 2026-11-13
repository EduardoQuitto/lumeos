<#
.SYNOPSIS
    Smoke test suite Phase 13 — Essenciais + PWA + MIME.
.DESCRIPTION
    Valida a estrutura da fase 13 (essenciais-pwa-mime) conforme roadmap.yaml e PRD:
    - OOBE: instalação de pacote Essenciais com 1 clique
    - PWAs: Firefox modo app + .desktop + ícone
    - MIME defaults: associação de arquivos
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase13.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 13 — Essenciais + PWA + MIME ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do app Essenciais
Write-Host "[1/6] Estrutura apps/essenciais/"
$dirs = @("apps/essenciais", "apps/essenciais/qml", "apps/essenciais/scripts", "apps/pwa", "apps/pwa/scripts", "config/mime")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. Essentials.qml
Write-Host "[2/6] apps/essenciais/qml/Essentials.qml"
if (Test-Path "apps/essenciais/qml/Essentials.qml") {
    $content = Get-Content "apps/essenciais/qml/Essentials.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("Essentials.qml: e janela de aplicacao") } else { Fail("Essentials.qml: nao e ApplicationWindow") }
    if ($content -match "1 clique|1-clique|Instalar com 1 clique") { Pass("Essentials.qml: instalacao 1 clique") } else { Fail("Essentials.qml: sem instalacao 1 clique") }
    if ($content -match "OnlyOffice|WhatsApp|Spotify|Discord|Zoom|Steam|Teams|Brave") { Pass("Essentials.qml: apps essenciais listados") } else { Fail("Essentials.qml: sem apps essenciais") }
} else {
    Fail("apps/essenciais/qml/Essentials.qml ausente")
}

# 3. Script de instalacao
Write-Host "[3/6] scripts/install-essentials.sh"
if (Test-Path "apps/essenciais/scripts/install-essentials.sh") {
    $content = Get-Content "apps/essenciais/scripts/install-essentials.sh" -Raw
    if ($content -match "flatpak|Flatpak") { Pass("install-essentials.sh: usa flatpak") } else { Fail("install-essentials.sh: sem flatpak") }
    if ($content -match "onlyoffice|OnlyOffice") { Pass("install-essentials.sh: OnlyOffice") } else { Fail("install-essentials.sh: sem OnlyOffice") }
    if ($content -match "whatsapp|WhatsApp") { Pass("install-essentials.sh: WhatsApp PWA") } else { Fail("install-essentials.sh: sem WhatsApp PWA") }
    if ($content -match "teams|Teams") { Pass("install-essentials.sh: Teams PWA") } else { Fail("install-essentials.sh: sem Teams PWA") }
    if ($content -match "brave|Brave") { Pass("install-essentials.sh: Brave opcional") } else { Fail("install-essentials.sh: sem Brave opcional") }
} else {
    Fail("apps/essenciais/scripts/install-essentials.sh ausente")
}

# 4. Script PWA
Write-Host "[4/6] scripts/create-pwa.sh"
if (Test-Path "apps/pwa/scripts/create-pwa.sh") {
    $content = Get-Content "apps/pwa/scripts/create-pwa.sh" -Raw
    if ($content -match "firefox|Firefox") { Pass("create-pwa.sh: Firefox modo app") } else { Fail("create-pwa.sh: sem Firefox modo app") }
    if ($content -match ".desktop") { Pass("create-pwa.sh: gera arquivo .desktop") } else { Fail("create-pwa.sh: sem arquivo .desktop") }
    if ($content -match "icone|icone|Icon|icon") { Pass("create-pwa.sh: icone") } else { Fail("create-pwa.sh: sem icone") }
} else {
    Fail("apps/pwa/scripts/create-pwa.sh ausente")
}

# 5. MIME defaults
Write-Host "[5/6] config/mime/mimeapps.list"
if (Test-Path "config/mime/mimeapps.list") {
    $content = Get-Content "config/mime/mimeapps.list" -Raw
    if ($content -match "Default Applications") { Pass("mimeapps.list: secao Default Applications") } else { Fail("mimeapps.list: sem secao Default Applications") }
    if ($content -match "onlyoffice|OnlyOffice") { Pass("mimeapps.list: OnlyOffice MIME") } else { Fail("mimeapps.list: sem OnlyOffice MIME") }
    if ($content -match "whatsapp|WhatsApp") { Pass("mimeapps.list: WhatsApp MIME") } else { Fail("mimeapps.list: sem WhatsApp MIME") }
    if ($content -match "teams|Teams") { Pass("mimeapps.list: Teams MIME") } else { Fail("mimeapps.list: sem Teams MIME") }
    if ($content -match "spotify|Spotify") { Pass("mimeapps.list: Spotify MIME") } else { Fail("mimeapps.list: sem Spotify MIME") }
    if ($content -match "zoom|Zoom") { Pass("mimeapps.list: Zoom MIME") } else { Fail("mimeapps.list: sem Zoom MIME") }
    if ($content -match "steam|Steam") { Pass("mimeapps.list: Steam MIME") } else { Fail("mimeapps.list: sem Steam MIME") }
} else {
    Fail("config/mime/mimeapps.list ausente")
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 13 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f13 = $state.fases | Where-Object { $_.id -eq 13 }
    if ($f13) {
        if ($f13.gate.blockers -eq 0) { Pass("Gate fase 13 GREEN: blockers = 0") } else { Fail("Gate fase 13: blockers = " + $f13.gate.blockers) }
    } else {
        Fail("Fase 13 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
