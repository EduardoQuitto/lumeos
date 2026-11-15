# FASES_FALTANTES.md — Roadmap de Implementação do Lume OS (Fases 39.6 a 45)

Este documento lista **todas as fases restantes** para transformar o Lume OS de um projeto de planejamento com protótipos visuais em um **sistema operacional usável**. Segue a metodologia do `AGENTS.md`: fases sequenciais, nunca pular, cada tarefa com aceite testável, gate de fim de fase com suíte de testes + blockers 0.

---

## 0. Estado Atual (referência)

O repositório está em aproximadamente **10–15% de conclusão** em relação a um SO usável.

O que existe:
- Documentação extensa (`PRD.md`, `roadmap.yaml`, `VISION.md`, `AGENTS.md`, `MISSION-CONTROL.md`)
- 8 serviços Rust que compilam, mas são **stubs** (não fazem nada real)
- `Shell.qml` reescrito visualmente para parecer com `expectativa_do_projeto.jpg`, mas **não gerencia janelas reais** nem se conecta a serviços
- 9 ícones SVG criados em `design/icons/`
- Smoke tests em PowerShell (validação de estrutura, não de função)
- Build script `build.sh` que **não gera ISO bootável**
- Mission Control backend que lê `roadmap.yaml`, mas **não está rodando**

O que **não existe**: kernel, rootfs, init system, gerenciador de pacotes, D-Bus real, compositor/WM, instalador, ISO, aplicativos do sistema, segurança configurada, camada Windows funcional, CI que produza artefato.

---

## 1. Regra de Ouro

O sistema operacional final deve ficar igual à imagem de referência em `design/expectative/expectativa_do_projeto.jpg`:
- Wallpaper Aurora Peaks gradiente fluido
- Barra pílula inferior (48px, margem 8px)
- Janela Lume Files centralizada com vidro/blur raio 12
- Titlebar 40px, controles à direita
- Tray direita com Wi-Fi, som, bateria, relógio
- Sidebar Files com Home/Downloads/Pictures/Documents
- Grade Projects/Music/Assets

Wallpapers oficiais: `design/wallpapers-gen/aurora-peaks/{light,dark}/*.jpg`.

---

## 2. Fases Restantes (39 a 45)

---

### Fase 39 — Documentação e Release Notes

**Objetivo:** Alinhar documentação com a realidade do produto.

**Depende de:** Todas as fases anteriores.

**Tarefas:**

| ID | Descrição | Aceite |
|----|-----------|--------|
| 39.6 | Site de download publicado (`docs/site/index.md` com links reais) | Site acessível com links para ISOs |
| 39.7 | `docs/OPEN.md` atualizado com dúvidas resolvidas | Não há dúvidas bloqueadoras sem decisão |

**Gate:** Toda documentação está consistente com o código entregue; não há afirmações falsas de conclusão.

---

### Fase 40 — Passe de Performance Final

**Objetivo:** Atingir todos os budgets de performance definidos no PRD §11.

**Depende de:** Todas as fases anteriores.

**Tarefas:**

| ID | Métrica | Meta | Aceite |
|----|---------|------|--------|
| 40.1 | Boot até greeter (VM Prime) | <20 s | `tests/qemu/smoke.sh` mede <20s |
| 40.2 | Boot até greeter (real B) | <30 s | Teste em hardware real mede <30s |
| 40.3 | Idle Prime | ≤450 MB | `lume-performance report` mostra ≤450 MB |
| 40.4 | Idle Core | ≤350 MB | `lume-performance report` mostra ≤350 MB |
| 40.5 | Idle Lite | ≤250 MB | `lume-performance report` mostra ≤250 MB |
| 40.6 | Flyout open | ≤150 ms | Teste de abertura de flyouts mede ≤150 ms |
| 40.7 | ISO amd64 | ≤1,4 GB | `ls -lh out/lume-amd64.iso` ≤1,4 GB |
| 40.8 | ISO i386 | ≤900 MB | `ls -lh out/lume-lite-i386.iso` ≤900 MB |
| 40.9 | Animações Prime | 60 fps | Captura de tela mostra 60 fps estável |

**Gate:** Todos os budgets atingidos nos 3 tiers; `lume-performance report` exibe métricas dentro do orçamento.

---

### Fase 41 — i18n e Acessibilidade Completo

**Objetivo:** pt-BR e en-US 100% traduzidos; Orca, alto contraste, movimento reduzido funcionando.

**Depende de:** Fase 32 (aplicativos com textos traduzíveis).

**Tarefas:**

| ID | Descrição | Aceite |
|----|-----------|--------|
| 41.1 | Carregar traduções JSON no QML (pt-BR e en-US) | Shell exibe textos em português por padrão; alternar para en-US muda todos os textos |
| 41.2 | Formatos por locale (24h pt, 12h en) | Relógio exibe "10:09" em pt-BR; "10:09 AM" em en-US |
| 41.3 | Orca screen reader configurado e funcionando | `orca --version` retorna versão; leitor de tela anuncia elementos do shell |
| 41.4 | Alto contraste ativável | Alternar alto contraste muda materiais para Sólido com texto 1.25× |
| 41.5 | Movimento reduzido | Animações substituídas por fade 100 ms |
| 41.6 | Teclas aderência (sticky keys) | Configuração em `config/a11y/orca-config` aplicada |
| 41.7 | Navegação teclado total | Todas as funções acessíveis apenas com teclado |

**Gate:** `lume-i18n --lang pt-BR` e `lume-i18n --lang en-US` trocam idioma; `orca` roda e anuncia; alto contraste e movimento reduzido funcionam.

---

### Fase 42 — Polimento Visual e Regra de Ouro

**Objetivo:** Garantir que o SO fique igual à imagem de referência `expectativa_do_projeto.jpg`.

**Depende de:** Fase 31 (shell), Fase 32 (apps), Fase 41 (i18n).

**Tarefas:**

| ID | Descrição | Aceite |
|----|-----------|--------|
| 42.1 | Wallpaper Aurora Peaks light/dark pareado | Tema claro exibe `aurora-peaks_light.jpg`; tema escuro exibe `aurora-peaks_dark.jpg` |
| 42.2 | Barra pílula inferior idêntica à referência | Captura de tela compara com referência: layout idêntico, cor ΔE<3, raio ±1px |
| 42.3 | Janela Lume Files idêntica à referência | Sidebar esquerda, titlebar 40px, grade Projects/Music/Assets, controles à direita |
| 42.4 | Logo nas 6 variantes em uso correto | dark, light, mono-white, mono-ink, acento, simple <24px usadas nos locais corretos |
| 42.5 | Cursor Lume Arrow completo | 24/32/48 px + espera com arcos do logo girando |
| 42.6 | Zero anti-padrões (gradiente roxo em botões, sombras duras, ícones mistos, etc.) | Revisão visual não encontra anti-padrões do VISION.md §52 |
| 42.7 | pt/en sem truncamento | Todos os textos cabem nos espaços alocados |
| 42.8 | 12 superfícies × light/dark aprovadas pelo dono | Sign-off visual do dono em cada superfície |

**Gate:** Diff estrutural vs `design/references/` dentro da tolerância; dono dá sign-off visual por fase.

---

### Fase 43 — Suíte de Testes VM (Fase 26 do roadmap original)

**Objetivo:** Executar a suíte completa de testes em matriz QEMU.

**Depende de:** Fase 38 (testes básicos), Fase 40 (performance).

**Tarefas:**

| ID | Teste | Descrição | Aceite |
|----|-------|-----------|--------|
| 43.1 | Matriz QEMU completa | virtio-gpu+GL (Prime), qxl (Core), i386 VGA (Lite) | Todos os 3 modos executam a suíte completa |
| 43.2 | Instalação em disco vazio 20 GB | Instalador HD em VM | Instalação completa sem erros |
| 43.3 | Update + rollback | Aplicar update e forçar falha | Rollback automático + teste de update |
| 43.4 | Teste tamper verity | Modificar arquivo do sistema | Verity detecta bloqueio ou boot seguro |
| 43.5 | Escape sandbox | Tentar escapar de bwrap | Escape bloqueado |
| 43.6 | Screenshot diff por build | Comparar builds | Diff dentro da tolerância |

**Gate:** `tests/suite-vm/run-all-tests.sh` passa em todas as matrizes; blockers = 0.

---

### Fase 44 — Beta Release 0.1

**Objetivo:** Preparar e validar o release 0.1 (não assinado pelo agente, apenas preparado).

**Depende de:** Todas as fases anteriores (28-43).

**Tarefas:**

| ID | Descrição | Aceite |
|----|-----------|--------|
| 44.1 | QA hardware real (apenas documento/plano, execução pelo dono) | `docs/qa/qa-hardware.md` atualizado com resultados de QA |
| 44.2 | Documentação completa atualizada | Todos os docs consistentes com o código |
| 44.3 | Site de download publicado | Links para ISOs amd64/i386 |
| 44.4 | Release notes 0.1 | `docs/release-notes-0.1.md` descreve o release |
| 44.5 | Checksums e assinatura preparados (assinatura pelo dono) | Arquivos `.iso`, `.sha256`, `.minisign` prontos para assinatura do dono |

**Gate:** Todas as tarefas da fase 27 do roadmap original estão concluídas (exceto assinatura física, que é ação do dono).

---

### Fase 45 — Gate Final e Tag de Conclusão

**Objetivo:** Validar que o SO está usável e pronto para entrega.

**Depende de:** Fase 44.

**Tarefas:**

| ID | Descrição | Aceite |
|----|-----------|--------|
| 45.1 | Suíte completa de testes verde | Todos os smoke tests passam; nenhum blocker |
| 45.2 | Instalação em VM aprovada | Disco vazio 20 GB, LUKS+A/B, boot após reinício |
| 45.3 | Visual aprovado pelo dono | Sign-off em todas as 12 superfícies × light/dark |
| 45.4 | Performance dentro do orçamento | Boot, idle, flyout, ISO dentro das metas |
| 45.5 | Segurança aprovada | Escudo Lume com todos os itens ATIVO; testes de tamper passam |
| 45.6 | Tag `lume-os-0.1-ready` criada | Tag no git marcando o ponto de release |

**Gate:** Suíte completa verde; blockers = 0; sign-off visual do dono; tag criada.

---

## 3. Resumo das Fases (28 a 45)

| Fase | Nome | Objetivo Principal | Depende de |
|------|------|-------------------|------------|
| 28 | Sistema Base Real | Rootfs Debian funcional | — |
| 29 | D-Bus e Ponte QML ↔ Rust | Comunicação entre shell e serviços | 28 |
| 30 | Serviços Rust Funcionais | Lógica real, não stubs | 29 |
| 31 | Shell QML Funcional | Compositor, janelas, snap, alt-tab, overview | 28, 29 |
| 32 | Aplicativos do Sistema | Files, Settings, Store, Terminal, etc. | 31 |
| 33 | Instalador HD e Disco | Instalação LUKS+A/B em VM | 28, 30, 36 |
| 34 | Segurança Lume Shield | Verity, lockdown, AppArmor, seccomp, nftables, LUKS, cofre | 30, 33 |
| 35 | Camada Windows | Wine+NTSYNC, garrafas bwrap, 3 apps, Steam/Proton | 34 |
| 36 | Build e CI (ISO real) | ISO amd64/i386 bootável | 28, 33, 34 |
| 37 | Mission Control em Produção | Painel :7777 rodando | 29 |
| 38 | Testes e Validação VM | Matriz QEMU, instalação, update, segurança | 36, 37 |
| 39 | Documentação e Release Notes | Docs consistentes com código | Todas anteriores |
| 40 | Passe de Performance Final | Budgets de boot/idle/flyout/ISO | Todas anteriores |
| 41 | i18n e Acessibilidade Completo | pt/en 100%, Orca, alto contraste, movimento reduzido | 32 |
| 42 | Polimento Visual (Regra de Ouro) | Igual a expectativa_do_projeto.jpg | 31, 32, 41 |
| 43 | Suíte de Testes VM (Fase 26) | Matriz completa + instalação + update + segurança | 38 |
| 44 | Beta Release 0.1 | QA, docs, site, release notes | Todas anteriores |
| 45 | Gate Final e Tag | SO usável, sign-off, tag criada | Todas anteriores |

---

## 4. Critério de "SO Usável" (Definição de Pronto)

O Lume OS será considerado um **sistema operacional usável** quando:

1. **ISO bootável** em USB ou DVD, amd64 (≤1,4 GB) ou i386 (≤900 MB)
2. **Instalação em disco vazio** de 20 GB em VM ou hardware real, com LUKS2 e slots A/B
3. **Boot até greeter** <20s (VM Prime) / <30s (real B)
4. **Desktop funcional** com barra pílula, menu iniciar, flyouts, janelas, snap, alt-tab, overview — igual à `expectativa_do_projeto.jpg`
5. **Aplicativos abrem** e executam suas funções (Files, Settings, Store, Terminal, etc.)
6. **Idle RAM** dentro do orçamento (450/350/250 MB Prime/Core/Lite)
7. **Atualização A/B com rollback** funciona e é reversível
8. **Segurança** com verity, lockdown, AppArmor, seccomp, nftables, LUKS2
9. **Documentação consistente** com o código entregue
10. **Sign-off visual do dono** em todas as superfícies

---

## 5. Próximos Passos Imediatos

Para iniciar a implementação, executar na ordem:

1. **Fase 28** — Criar `build/rootfs/debootstrap-rootfs.sh` e testar debootstrap em VM Linux
2. **Fase 29** — Adicionar `zbus`/`dbus` aos serviços e implementar exposição via D-Bus
3. **Fase 30** — Substituir stubs por lógica real em todos os serviços Rust
4. **Fase 31** — Integrar compositor (labwc/Hyprland) e fazer Shell.qml gerenciar janelas reais
5. **Fase 36** — Reescrever `build.sh` para gerar ISO real

Cada fase deve ser validada com sua suíte de testes antes de avançar para a próxima, conforme `AGENTS.md` regra #2.
