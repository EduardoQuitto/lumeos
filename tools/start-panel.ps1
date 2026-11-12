<#
.SYNOPSIS
    Sobe o Mission Control do Lume OS em http://localhost:7777 e abre o navegador.
.DESCRIPTION
    - Verifica se o binário release existe.
    - Inicia mission-control/backend/target/release/lume-mission-control.exe
    - Aguarda o /api/state responder (até 30 s).
    - Abre o navegador padrão em localhost:7777.
    - Escreve o PID em .panel.pid para uso do stop-panel.ps1.
.PARAMETER Lan
    Atende em 0.0.0.0 (LAN). Exige --token ou variável de ambiente MC_TOKEN.
.PARAMETER Token
    Token de acesso para modo LAN.
.PARAMETER Port
    Porta de escuta (padrão 7777).
#>
param(
    [switch]$Lan,
    [string]$Token,
    [int]$Port = 7777
)

$ErrorActionPreference = "Stop"

# Caminhos absolutos baseados no local deste script
$scriptPath = $PSCommandPath
if (-not $scriptPath) { $scriptPath = $MyInvocation.MyCommand.Definition }
$ScriptDir = Split-Path -Parent $scriptPath
$RepoDir = Resolve-Path (Join-Path $ScriptDir "..")
$BackendExe = Join-Path $RepoDir "mission-control\backend\target\release\lume-mission-control.exe"
$WebDir = Join-Path $RepoDir "mission-control\backend\web\dist"
$PidFile = Join-Path $RepoDir ".panel.pid"
$Url = "http://localhost:$Port"

Write-Host "ScriptDir: $ScriptDir" -ForegroundColor Gray
Write-Host "RepoDir: $RepoDir" -ForegroundColor Gray
Write-Host "Backend: $BackendExe" -ForegroundColor Gray

# Verifica se o binário existe
if (-not (Test-Path $BackendExe)) {
    Write-Error "Binário não encontrado: $BackendExe. Rode `cargo build --release` em mission-control/backend primeiro."
    exit 1
}

# Verifica se já está rodando
if (Test-Path $PidFile) {
    $oldPid = Get-Content $PidFile
    if (Get-Process -Id $oldPid -ErrorAction SilentlyContinue) {
        Write-Warning "Mission Control já está rodando (PID $oldPid). Use stop-panel.ps1 primeiro."
        exit 0
    }
    Remove-Item $PidFile -Force
}

# Monta argumentos para o backend
$argStr = "--port $Port --web-dir `"$WebDir`""
if ($Lan) {
    if (-not $Token -and -not $env:MC_TOKEN) {
        Write-Error "Modo --lan exige -Token ou variável de ambiente MC_TOKEN."
        exit 1
    }
    $argStr += " --lan"
    if ($Token) { $argStr += " --token `"$Token`" " }
}

Write-Host "Iniciando Mission Control em $Url ..." -ForegroundColor Cyan

# Inicia o backend em uma nova janela de cmd (desanexado)
cmd /c "start /B ""Lume MC"" `"$BackendExe"" $argStr" 

# Aguarda o PID do processo (dá tempo para iniciar)
Start-Sleep -Seconds 2

# Tenta encontrar o PID pelo nome do processo
$proc = Get-Process -Name "lume-mission-control" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($proc) {
    $proc.Id | Out-File -FilePath $PidFile -Encoding utf8
    Write-Host "PID salvo: $($proc.Id)" -ForegroundColor Gray
}

# Aguarda o /api/state responder (até 30 s)
Write-Host "Aguardando o painel ficar disponível..." -ForegroundColor Gray
$ready = $false
for ($i = 0; $i -lt 60; $i++) {
    try {
        $r = Invoke-RestMethod -Uri "$Url/api/state" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($r) { $ready = $true; break }
    } catch {}
    Start-Sleep -Milliseconds 500
}

if (-not $ready) {
    Write-Warning "O painel ainda não respondeu em $Url/api/state."
    if ($proc) { Write-Host "PID: $($proc.Id). Teste manualmente: Invoke-RestMethod $Url/api/state" }
} else {
    Write-Host "Mission Control online em $Url" -ForegroundColor Green
    Start-Process $Url
    Write-Host "Para parar: .\tools\stop-panel.ps1" -ForegroundColor Gray
}
