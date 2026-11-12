<#
.SYNOPSIS
    Smoke test suite Phase 11 — Terminal + CLI.
.DESCRIPTION
    Valida a estrutura da fase 11 (terminal-cli) conforme roadmap.yaml e PRD:
    - terminal: foot (Wayland) + xfce4-terminal (Lite) + starship + abas + quake
    - CLI lume completa: update, shield, tier, store, fetch, session
    - command-not-found
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase11.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 11 — Terminal + CLI ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do terminal
Write-Host "[1/6] Estrutura apps/terminal/"
$dirs = @("apps/terminal", "apps/terminal/config", "apps/terminal/scripts")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. Configurações de terminal
Write-Host "[2/6] Configurações: foot, xfce4-terminal, starship"
$configs = @("apps/terminal/config/foot.ini", "apps/terminal/config/xfce4-terminal.cfg", "apps/terminal/config/starship.toml")
foreach ($c in $configs) {
    if (Test-Path $c) { Pass("$c existe") } else { Fail("$c ausente") }
}

# 3. Conteúdo do foot.ini
Write-Host "[3/6] foot.ini - configuração Wayland"
if (Test-Path "apps/terminal/config/foot.ini") {
    $content = Get-Content "apps/terminal/config/foot.ini" -Raw
    if ($content -match "font") { Pass("foot: fonte configurada") } else { Fail("foot: sem fonte") }
    if ($content -match "colors|background|foreground") { Pass("foot: cores da paleta Lume") } else { Fail("foot: sem cores") }
    if ($content -match "tabs|aba") { Pass("foot: abas habilitadas") } else { Fail("foot: sem abas") }
} else {
    Fail("foot.ini ausente")
}

# 4. Conteúdo do starship.toml
Write-Host "[4/6] starship.toml - prompt"
if (Test-Path "apps/terminal/config/starship.toml") {
    $content = Get-Content "apps/terminal/config/starship.toml" -Raw
    if ($content -match "character|prompt") { Pass("starship: caractere de prompt") } else { Fail("starship: sem prompt") }
    if ($content -match "directory|git_branch|git_status") { Pass("starship: módulos directory/git") } else { Fail("starship: sem módulos") }
} else {
    Fail("starship.toml ausente")
}

# 5. Script quake-terminal
Write-Host "[5/6] Script quake-terminal.sh"
if (Test-Path "apps/terminal/scripts/quake-terminal.sh") {
    $content = Get-Content "apps/terminal/scripts/quake-terminal.sh" -Raw
    if ($content -match "toggle|start|stop|status") { Pass("quake-terminal: operações toggle/start/stop/status") } else { Fail("quake-terminal: sem operações") }
    if ($content -match "foot|xfce4-terminal") { Pass("quake-terminal: suporta foot/xfce4-terminal") } else { Fail("quake-terminal: sem terminal") }
} else {
    Fail("quake-terminal.sh ausente")
}

# 6. CLI lume
Write-Host "[6/6] CLI lume (services/cli/src/lume-cli)"
if (Test-Path "services/cli/src/lume-cli") {
    $content = Get-Content "services/cli/src/lume-cli" -Raw
    $comandos = @("update", "shield", "tier", "store", "fetch", "session")
    foreach ($c in $comandos) {
        if ($content -match $c) { Pass("CLI: comando $c") } else { Fail("CLI: falta comando $c") }
    }
    if ($content -match "command-not-found|comando não encontrado|sugest") { Pass("CLI: command-not-found") } else { Fail("CLI: sem command-not-found") }
} else {
    Fail("lume-cli ausente")
}

# Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 11 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f11 = $state.fases | Where-Object { $_.id -eq 11 }
    if ($f11) {
        if ($f11.gate.blockers -eq 0) { Pass("Gate fase 11 GREEN: blockers = 0") } else { Fail("Gate fase 11: blockers = " + $f11.gate.blockers) }
    } else {
        Fail("Fase 11 não encontrada no state")
    }
} catch {
    Fail("Não foi possível consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
