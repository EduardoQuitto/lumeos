<#
.SYNOPSIS
    Suíte de testes de smoke da Fase 0 — Mission Control (Windows nativo).
.DESCRIPTION
    Valida o contrato da API do Mission Control conforme docs/MISSION-CONTROL.md:
    - GET  /api/state       → 28 fases, pesos, %, blockers, sessão, ETA
    - POST /api/events      → evento publicado (SSE)
    - POST /api/heartbeat   → heartbeat aceito
    - POST /api/control     → pause/resume
    - POST /api/build       → build registrado
    - Gate: blockers_totais == 0
.EXAMPLE
    .\tests\smoke\fase0.ps1
#>
param(
    [string]$Url = "http://localhost:7777",
    [int]$Timeout = 10
)

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Suíte de smoke Fase 0 — Mission Control ===" -ForegroundColor Cyan
Write-Host "Alvo: $Url" -ForegroundColor Gray
Write-Host ""

# 1. GET /api/state
Write-Host "[1/6] GET /api/state — 28 fases com pesos"
try {
    $state = Invoke-RestMethod -Uri "$Url/api/state" -TimeoutSec $Timeout -ErrorAction Stop
    $faseCount = ($state.fases).Count
    $blockers = $state.blockers_totais
    $pct = $state.pct_global
    if ($faseCount -eq 28) { Pass("28 fases retornadas") } else { Fail("$faseCount fases (esperado 28)") }
    if ($blockers -eq 0) { Pass("blockers_totais = 0") } else { Fail("blockers_totais = $blockers (esperado 0)") }
    if ($pct -ge 0) { Pass("pct_global = $pct%") } else { Fail("pct_global inválido") }
    $sessao = $state.sessoes[0]
    if ($sessao) { Pass("sessão presente (início/decorrido/ETA)") } else { Fail("sessão ausente") }
} catch {
    Fail("GET /api/state falhou: $_")
}

# 2. POST /api/events
Write-Host "[2/6] POST /api/events — evento publicado via SSE"
try {
    $resp = Invoke-RestMethod -Method Post -Uri "$Url/api/events" -ContentType "application/json" -Body '{"tipo":"task_done","fase":0,"tarefa":"t0-smoke","payload":{"ok":true,"suite":"fase0"}}' -TimeoutSec $Timeout -ErrorAction Stop
    if ($resp.ok -eq $true) { Pass("evento publicado com ok=true") } else { Fail("resposta inesperada: $resp") }
} catch {
    Fail("POST /api/events falhou: $_")
}

# 3. POST /api/heartbeat
Write-Host "[3/6] POST /api/heartbeat — heartbeat aceito"
try {
    $resp = Invoke-RestMethod -Method Post -Uri "$Url/api/heartbeat" -ContentType "application/json" -Body '{"tarefa":"smoke-fase0","arquivo":"tests/smoke/fase0.ps1"}' -TimeoutSec $Timeout -ErrorAction Stop
    if ($resp.ok -eq $true) { Pass("heartbeat aceito") } else { Fail("resposta inesperada: $resp") }
} catch {
    Fail("POST /api/heartbeat falhou: $_")
}

# 4. POST /api/control (pause/resume)
Write-Host "[4/6] POST /api/control — pause/resume"
try {
    $r1 = Invoke-RestMethod -Method Post -Uri "$Url/api/control" -ContentType "application/json" -Body '{"pausada":true}' -TimeoutSec $Timeout -ErrorAction Stop
    if ($r1.pausada -eq $true) { Pass("pause aceito (pausada=true)") } else { Fail("pause não refletiu pausada=true") }
    $r2 = Invoke-RestMethod -Method Post -Uri "$Url/api/control" -ContentType "application/json" -Body '{"pausada":false}' -TimeoutSec $Timeout -ErrorAction Stop
    if ($r2.pausada -eq $false) { Pass("resume aceito (pausada=false)") } else { Fail("resume não refletiu pausada=false") }
} catch {
    Fail("POST /api/control falhou: $_")
}

# 5. POST /api/build
Write-Host "[5/6] POST /api/build — build registrado"
try {
    $resp = Invoke-RestMethod -Method Post -Uri "$Url/api/build" -ContentType "application/json" -Body '{"iso":"lume-amd64.iso","sha256":"deadbeef","shots":["design/shots/0/boot-amd64.png"]}' -TimeoutSec $Timeout -ErrorAction Stop
    if ($resp.ok -eq $true) { Pass("build registrado") } else { Fail("resposta inesperada: $resp") }
} catch {
    Fail("POST /api/build falhou: $_")
}

# 6. Gate: blockers 0
Write-Host "[6/6] Gate fase 0 — blockers 0"
try {
    $state = Invoke-RestMethod -Uri "$Url/api/state" -TimeoutSec $Timeout -ErrorAction Stop
    if ($state.blockers_totais -eq 0) {
        Pass("Gate fase 0 VERDE: blockers_totais = 0")
    } else {
        Fail("Gate fase 0 VERMELHO: blockers_totais = $($state.blockers_totais)")
    }
} catch {
    Fail("Não foi possível verificar o gate: $_")
}

Write-Host ""
Write-Host "=== Resultado: $script:passes passou, $script:fails falhou ===" -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
