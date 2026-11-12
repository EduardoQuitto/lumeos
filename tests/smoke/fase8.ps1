<#
.SYNOPSIS
    Smoke test suite Phase 8 — Lume Files.
.DESCRIPTION
    Valida a estrutura da fase 8 (lume-files) conforme roadmap.yaml e PRD:
    - toolbar com acoes
    - breadcrumb editavel
    - abas com arrasto
    - busca rg + grade/lista + sidebar lugares/dispositivos/lixo
    - lixo (restaurar/esvaziar)
    - montagem (udisks2)
    - extracao p7zip + propriedades
    - Gate: blockers 0 no Mission Control
.EXAMPLE
    .\tests\smoke\fase8.ps1
#>
param()

$ErrorActionPreference = "Stop"
$fails = 0
$passes = 0

function Pass($msg) { $script:passes++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $script:fails++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }

Write-Host "=== Smoke test Phase 8 — Lume Files ===" -ForegroundColor Cyan
Write-Host ""

# 1. Estrutura do app Files
Write-Host "[1/6] Estrutura apps/files/"
$dirs = @("apps/files", "apps/files/qml", "apps/files/qml/views")
foreach ($d in $dirs) {
    if (Test-Path $d) { Pass("$d existe") } else { Fail("$d ausente") }
}

# 2. main.qml
Write-Host "[2/6] apps/files/qml/main.qml"
if (Test-Path "apps/files/qml/main.qml") {
    $content = Get-Content "apps/files/qml/main.qml" -Raw
    if ($content -match "ApplicationWindow") { Pass("main.qml: e uma janela de aplicacao") } else { Fail("main.qml: nao e ApplicationWindow") }
    if ($content -match "Toolbar|ToolBar|toolbar") { Pass("main.qml: tem toolbar") } else { Fail("main.qml: sem toolbar") }
    if ($content -match "breadcrumb|Breadcrumb|caminhoAtual|caminho") { Pass("main.qml: tem breadcrumb/caminho") } else { Fail("main.qml: sem breadcrumb") }
    if ($content -match "TabBar|abas|Abas") { Pass("main.qml: tem abas") } else { Fail("main.qml: sem abas") }
    if ($content -match "busca|Busca|Buscar|campoBusca") { Pass("main.qml: tem campo de busca") } else { Fail("main.qml: sem campo de busca") }
    if ($content -match "grade|Grade|GridView|lista|Lista|ListView") { Pass("main.qml: tem visualizacao grade/lista") } else { Fail("main.qml: sem grade/lista") }
    if ($content -match "sidebar|Sidebar|lugar|Lugar|dispositivo|Dispositivo|lixeira|Lixeira|lixo") { Pass("main.qml: tem sidebar com lugares/dispositivos/lixo") } else { Fail("main.qml: sem sidebar completa") }
    if ($content -match "udisk|udisks2|montar|Montar|dispositivo") { Pass("main.qml: tem montagem (udisks2)") } else { Fail("main.qml: sem montagem") }
    if ($content -match "p7zip|P7zip|extrair|Extrair|compactado") { Pass("main.qml: tem extracao p7zip") } else { Fail("main.qml: sem extracao") }
    if ($content -match "propriedade|Propriedade|Propriedades") { Pass("main.qml: tem painel de propriedades") } else { Fail("main.qml: sem propriedades") }
} else {
    Fail("apps/files/qml/main.qml ausente")
}

# 3. Validar componentes especificos da toolbar
Write-Host "[3/6] Componentes da toolbar (voltar/avancar/novo/copiar/colar/excluir/lixeira/exibicao)"
$toolbar_checks = @(
    @{ chave = "btnVoltar"; desc = "botao Voltar" },
    @{ chave = "btnAvancar"; desc = "botao Avancar" },
    @{ chave = "btnNovo"; desc = "botao Novo" },
    @{ chave = "btnCopiar"; desc = "botao Copiar" },
    @{ chave = "btnColar"; desc = "botao Colar" },
    @{ chave = "btnExcluir"; desc = "botao Excluir" },
    @{ chave = "btnLixeira"; desc = "botao Lixeira" },
    @{ chave = "btnGrade|btnLista"; desc = "modo de exibicao grade/lista" },
    @{ chave = "campoBusca"; desc = "campo de busca" }
)
$content = Get-Content "apps/files/qml/main.qml" -Raw
foreach ($check in $toolbar_checks) {
    if ($content -match $check.chave) { Pass("Toolbar: $($check.desc)") } else { Fail("Toolbar: falta $($check.desc)") }
}

# 4. Validar sidebar com lugares, dispositivos e lixo
Write-Host "[4/6] Sidebar (lugares, dispositivos, lixo)"
$sidebar_checks = @(
    @{ chave = "Lugar Inicial|LugarInicial"; desc = "lugar inicial" },
    @{ chave = "Documentos|Downloads|Imagens|Musica|Videos"; desc = "pastas de lugar" },
    @{ chave = "Dispositivos|USB Drive|Disco HD"; desc = "dispositivos" },
    @{ chave = "Lixeira|lixeira|trash"; desc = "lixeira" }
)
foreach ($check in $sidebar_checks) {
    if ($content -match $check.chave) { Pass("Sidebar: $($check.desc)") } else { Fail("Sidebar: falta $($check.desc)") }
}

# 5. Atalhos de teclado
Write-Host "[5/6] Atalhos de teclado (Ctrl+F busca, Ctrl+L caminho, Delete excluir)"
$atalhos = @(
    @{ chave = "Ctrl.*F|Key_F|ControlModifier.*F"; desc = "Ctrl+F busca" },
    @{ chave = "Ctrl.*L|Key_L|ControlModifier.*L"; desc = "Ctrl+L caminho" },
    @{ chave = "Key_Delete|Delete"; desc = "Delete excluir" }
)
foreach ($atalho in $atalhos) {
    if ($content -match $atalho.chave) { Pass("Atalho: $($atalho.desc)") } else { Fail("Atalho: falta $($atalho.desc)") }
}

# 6. Gate via Mission Control
Write-Host ""
Write-Host "[Gate] Fase 8 — blockers 0 no Mission Control"
try {
    $state = Invoke-RestMethod -Uri "http://localhost:7777/api/state" -TimeoutSec 5 -ErrorAction Stop
    $f8 = $state.fases | Where-Object { $_.id -eq 8 }
    if ($f8) {
        if ($f8.gate.blockers -eq 0) { Pass("Gate fase 8 GREEN: blockers = 0") } else { Fail("Gate fase 8: blockers = " + $f8.gate.blockers) }
    } else {
        Fail("Fase 8 nao encontrada no state")
    }
} catch {
    Fail("Nao foi possivel consultar /api/state: " + $_.Exception.Message)
}

Write-Host ""
$resMsg = "Result: " + $script:passes + " OK, " + $script:fails + " FAILED"
Write-Host $resMsg -ForegroundColor Cyan
if ($script:fails -gt 0) { exit 1 } else { exit 0 }
