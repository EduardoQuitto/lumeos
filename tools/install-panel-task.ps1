<#
.SYNOPSIS
    Instala o Mission Control como tarefa do Agendador de Tarefas do Windows (logon, sem admin).
.DESCRIPTION
    Cria uma tarefa iniciada no logon do usuário que sobe o Mission Control.
    Não requer privilégios de administrador (usa /create no escopo do usuário atual).
.PARAMETER Lan
    Atende em 0.0.0.0 (LAN).
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
$ScriptDir = $PSScriptRoot
$RepoDir = Resolve-Path (Join-Path $ScriptDir "..")
$StartScript = Join-Path $RepoDir "tools\start-panel.ps1"
$TaskName = "LumeMissionControl"

$args = ""
if ($Lan) { $args += " -Lan" }
if ($Token) { $args += " -Token " + $Token }
$args += " -Port $Port"

# Verifica se schtasks está disponível
if (-not (Get-Command schtasks -ErrorAction SilentlyContinue)) {
    Write-Error "schtasks não encontrado no sistema."
    exit 1
}

# Remove tarefa existente se houver
schtasks /delete /tn "$TaskName" /f 2>$null | Out-Null

$cmd = "powershell.exe -ExecutionPolicy Bypass -File `"$StartScript`" $args"
Write-Host "Criando tarefa '$TaskName' no Agendador de Tarefas..." -ForegroundColor Cyan

schtasks /create /tn "$TaskName" /tr "$cmd" /sc onlogon /rl LOWERST /ru "%USERNAME%" /f

if ($LASTEXITCODE -eq 0) {
    Write-Host "Tarefa instalada com sucesso. O painel subirá no próximo logon." -ForegroundColor Green
    Write-Host "Para remover: schtasks /delete /tn '$TaskName' /f" -ForegroundColor Gray
} else {
    Write-Error "Falha ao criar a tarefa do Agendador de Tarefas."
    exit 1
}
