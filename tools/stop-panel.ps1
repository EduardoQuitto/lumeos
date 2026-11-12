<#
.SYNOPSIS
    Para o Mission Control do Lume OS.
.DESCRIPTION
    Lê o PID salvo em .panel.pid e encerra o processo.
    Se não houver PID, tenta encontrar e encerrar qualquer processo lime-mission-control na porta 7777.
#>
param()

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$RepoDir = Resolve-Path (Join-Path $ScriptDir "..")
$PidFile = Join-Path $RepoDir ".panel.pid"

$stopped = $false

if (Test-Path $PidFile) {
    $pid = Get-Content $PidFile
    try {
        $proc = Get-Process -Id $pid -ErrorAction Stop
        Stop-Process -Id $pid -Force -ErrorAction Stop
        Write-Host "Mission Control (PID $pid) encerrado." -ForegroundColor Green
        $stopped = $true
    } catch {
        Write-Warning "Processo PID $pid não encontrado."
    }
    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
}

# Tenta encerrar qualquer processo do mission-control restante
$procs = Get-Process -Name "lume-mission-control" -ErrorAction SilentlyContinue
foreach ($p in $procs) {
    Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    Write-Host "Encerrado processo residual (PID $($p.Id))." -ForegroundColor Gray
    $stopped = $true
}

if (-not $stopped) {
    Write-Host "Nenhum Mission Control em execução encontrado." -ForegroundColor Gray
}
