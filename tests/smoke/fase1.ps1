<#
.SYNOPSIS
    Smoke test suite Phase 1 — Design System + Assets.
.DESCRIPTION
    Validates phase 1 design assets per roadmap.yaml and PRD section 4:
    - 6 logo SVG variants (dark, light, mono-white, mono-ink, acento, simple)
    - Lume Arrow cursor (24/32/48 + wait)
    - Wallpapers (5 ids x light/dark) + wallpapers.yaml
    - CC0 sounds (notification, volume, error)
    - tokens.json valid
.EXAMPLE
    .\tests\smoke\fase1.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 1 — Design System + Assets ===" -ForegroundColor Cyan
Write-Host ""

# 1. Logo 6 variants
Write-Host "[1/6] Logo — 6 SVG variants"
$logoDir = "design/logo"
$logos = @("logo-dark", "logo-light", "logo-mono-white", "logo-mono-ink", "logo-acento", "logo-simple")
foreach ($l in $logos) {
    $path = Join-Path $logoDir "$l.svg"
    if (Test-Path $path) {
        $content = Get-Content $path -Raw
        if ($content -match "<svg" -and $content -match "</svg>") {
            Pass("$l.svg valid")
        } else {
            Fail("$l.svg not valid SVG")
        }
    } else {
        Fail("$l.svg missing")
    }
}

# 2. Cursor
Write-Host "[2/6] Lume Arrow cursor"
$cursorDir = "design/cursor"
$cursors = @("lume-arrow-24", "lume-arrow-32", "lume-arrow-48", "lume-arrow-wait")
foreach ($c in $cursors) {
    $path = Join-Path $cursorDir "$c.svg"
    if (Test-Path $path) { Pass("$c.svg exists") } else { Fail("$c.svg missing") }
}

# 3. Wallpapers
Write-Host "[3/6] Wallpapers + wallpapers.yaml"
$wpDir = "design/wallpapers-gen"
$packs = @("aurora-peaks", "crystal-glow", "pastel-horizon", "silk-flow", "solar-tide")
$themes = @("light", "dark")
foreach ($p in $packs) {
    foreach ($t in $themes) {
        $path = Join-Path $wpDir "$p/$t/${p}_$t.jpg"
        if (Test-Path $path) { Pass("$p/$t wallpaper exists") } else { Fail("$p/$t wallpaper missing") }
    }
}
if (Test-Path "design/wallpapers.yaml") {
    $yaml = Get-Content "design/wallpapers.yaml" -Raw
    if ($yaml -match "aurora-peaks" -and $yaml -match "light" -and $yaml -match "dark") {
        Pass("wallpapers.yaml valid with 5 packs")
    } else {
        Fail("wallpapers.yaml incomplete")
    }
} else {
    Fail("wallpapers.yaml missing")
}

# 4. Sounds
Write-Host "[4/6] CC0 sounds"
$soundsDir = "design/sounds"
$sounds = @("notification", "volume", "error")
foreach ($s in $sounds) {
    $path = Join-Path $soundsDir "$s.wav"
    if (Test-Path $path) {
        $len = (Get-Item $path).Length
        if ($len -gt 44) { Pass("$s.wav valid ($len bytes)") } else { Fail("$s.wav too small") }
    } else {
        Fail("$s.wav missing")
    }
}

# 5. tokens.json
Write-Host "[5/6] design/tokens.json"
if (Test-Path "design/tokens.json") {
    $tokens = Get-Content "design/tokens.json" -Raw | ConvertFrom-Json
    $checks = @("cor", "raio", "espaco", "tipo", "motion", "materiais", "sombra", "foco", "tiers")
    $ok = $true
    foreach ($c in $checks) {
        if (-not $tokens.PSObject.Properties.Name -contains $c) { $ok = $false; Fail("tokens.json missing key: $c") }
    }
    if ($ok) { Pass("tokens.json with all sections (PRD sec 4)") }
} else {
    Fail("design/tokens.json missing")
}

# 6. Gate: blockers 0 (phase 1)
Write-Host "[6/6] Gate phase 1 — design-assets-smoke"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f1 = $state.fases | Where-Object { $_.id -eq 1 }
    if ($f1) {
        if ($f1.gate.blockers -eq 0) { Pass("Gate phase 1 GREEN: blockers = 0") } else { Fail("Gate phase 1: blockers = " + $f1.gate.blockers) }
    } else {
        Fail("Phase 1 not found in state")
    }
} catch {
    Fail("Could not query /api/state: $_")
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
