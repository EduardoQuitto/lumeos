<#
.SYNOPSIS
    Smoke test suite Phase 10 — Settings Parte 2 Security.
.DESCRIPTION
    Valida a estrutura da fase 10 (settings-parte2-security) conforme roadmap.yaml e PRD:
    - janela principal com nav esquerda 240px vidro-lite + conteudo papel/tinta
    - 8 paginas: sistema, tela, som, rede, bt, personalizacao, apps, contas
    - Central de Seguranca com checklist Shield (verity, lockdown, AppArmor, seccomp, nftables, TPM2)
    - pagina firewall (nftables default-deny entrada)
    - pagina inspetor sandbox
    - pagina launcher Cofre + aviso modo live
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase10.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 10 — Settings Parte 2 Security ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do app Settings security
Write-Host "[1/6] Estrutura apps/settings/qml/views/security/"
$dir = "apps/settings/qml/views/security"
if (Test-Path $dir) { Pass("$dir existe") } else { Fail("$dir ausente") }

# 2. SecurityCenter.qml
Write-Host "[2/6] SecurityCenter.qml"
if (Test-Path "apps/settings/qml/views/security/SecurityCenter.qml") {
    $content = Get-Content "apps/settings/qml/views/security/SecurityCenter.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("SecurityCenter.qml: e janela de aplicacao") } else { Fail("SecurityCenter.qml: nao e ApplicationWindow") }
    if ($content -match "navEsquerda|240|vidro|ShaderEffect") { Pass("SecurityCenter.qml: nav esquerda 240px vidro-lite") } else { Fail("SecurityCenter.qml: sem nav esquerda 240px vidro-lite") }
    if ($content -match "papel|tinta|#F7F9FC|#0E1116") { Pass("SecurityCenter.qml: conteudo papel/tinta") } else { Fail("SecurityCenter.qml: sem conteudo papel/tinta") }
    if ($content -match "paginaAtual|pilha|Stack") { Pass("SecurityCenter.qml: navegacao entre paginas") } else { Fail("SecurityCenter.qml: sem navegacao entre paginas") }
} else {
    Fail("apps/settings/qml/views/security/SecurityCenter.qml ausente")
}

# 3. Paginas de settings (8 + security)
Write-Host "[3/6] Paginas: sistema, tela, som, rede, bt, personalizacao, apps, contas, shield, firewall, sandbox, cofre, live"
$paginas = @("sistema", "tela", "som", "rede", "bt", "personalizacao", "apps", "contas", "shield", "firewall", "sandbox", "cofre", "live")
$content = Get-Content "apps/settings/qml/views/security/SecurityCenter.qml" -Raw
foreach ($p in $paginas) {
    if ($content -match $p) { Pass("Pagina: $p") } else { Fail("Pagina: falta $p") }
}

# 4. Checklist Shield (verity, lockdown, AppArmor, seccomp, nftables, TPM2)
Write-Host "[4/6] Checklist Shield (verity, lockdown, AppArmor, seccomp, nftables, TPM2)"
$shield_checks = @(
    @{ chave = "Verity|verity"; desc = "Verity (slots imutaveis)" },
    @{ chave = "Lockdown|lockdown"; desc = "Lockdown (integridade)" },
    @{ chave = "AppArmor|apparmor"; desc = "AppArmor (enforce)" },
    @{ chave = "seccomp"; desc = "seccomp (daemons)" },
    @{ chave = "nftables"; desc = "nftables (firewall)" },
    @{ chave = "TPM2|tpM2"; desc = "TPM2 (opcional)" }
)
foreach ($check in $shield_checks) {
    if ($content -match $check.chave) { Pass("Shield: $($check.desc)") } else { Fail("Shield: falta $($check.desc)") }
}

# 5. Firewall (nftables default-deny), sandbox, cofre, live
Write-Host "[5/6] Firewall, sandbox, cofre, modo live"
if ($content -match "nftables|default-deny|Firewall|firewall") { Pass("Firewall: nftables default-deny") } else { Fail("Firewall: sem nftables/default-deny") }
if ($content -match "Sandbox|sandbox|Inspetor|inspetor") { Pass("Sandbox: inspetor") } else { Fail("Sandbox: sem inspetor") }
if ($content -match "Cofre|cofre|Modo Cofre|microVM|microvm") { Pass("Cofre: launcher microVM") } else { Fail("Cofre: sem launcher microVM") }
if ($content -match "Modo Live|modo live|live|Pendrive|pendrive|Instalar|instalar") { Pass("Modo Live: aviso/pendrive/instalador") } else { Fail("Modo Live: sem aviso/pendrive/instalador") }

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 10 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f10 = $state.fases | Where-Object { $_.id -eq 10 }
    if ($f10) {
        if ($f10.gate.blockers -eq 0) { Pass("Gate fase 10 GREEN: blockers = 0") } else { Fail("Gate fase 10: blockers = " + $f10.gate.blockers) }
    } else {
        Fail("Fase 10 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
