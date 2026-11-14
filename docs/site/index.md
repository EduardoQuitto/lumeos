# Lume OS - SO Linux Leve e Premium

## Visão Geral

O **Lume OS** é um sistema operacional Linux leve, imutável na base e com visual premium (estrutura Windows 11 + física/materiais macOS), desenvolvido para devolver vida a PCs fracos e rodar em pendrive persistente, RAM ou HD. Diferencial: mesma elegância em 3 tiers de hardware com ~1/5 da RAM do Windows 11.

## Edições

| Edição | Arq. | Alvo | Materiais | Idle |
|--------|------|------|-----------|
| **Lite** | i386 (PAE) | P4, 1–2 GB, GPU 2004–09 | Vidro-lite se GL≥2.1, senão Sólido | ≤250 MB |
| **Core** | amd64 | <4 GB ou GPU sem GLES3.2/VA-API | Névoa + Sólido + sombras | ≤350 MB |
| **Prime** | amd64 | ≥4 GB + GLES3.2 | Vidro + Névoa + Sólido | ≤450 MB |

## Recursos Principais

- **Base Imutável**: SquashFS+verity com update A/B e rollback automático
- **Persistência LUKS2**: Pendrive persistente com criptografia
- **Visual Premium**: Barra pílula, janelas de vidro, materiais (Vidro/Névoa/Sólido)
- **Segurança**: LUKS2, verity, AppArmor, seccomp, nftables, Secure Boot
- **Shell**: Quickshell (Qt6/QML) para Prime/Core, lite-host (X11 + picom) para Lite
- **Aplicativos**: Files, Settings, Store, Terminal, Task Manager, Security Center, Updates, Editor, Viewer, PDF, Calc, Screenshot, Welcome, Backup, Bottles, Greeter/Lock

## Como Instalar

1. Baixe a ISO da edição desejada
2. Grave em um pendrive com Rufus, Etcher ou Ventoy
3. Inicie pelo pendrive
4. Siga o OOBE (primeira execução)
5. Aproveite o Lume OS!

## Documentação

- [PRD](docs/PRD.md) - Documento de Requisitos do Produto
- [VISION](docs/VISION.md) - Visão do Produto
- [Mission Control](docs/MISSION-CONTROL.md) - Especificação do Painel de Controle
- [roadmap.yaml](roadmap.yaml) - Roadmap de Desenvolvimento

---

**Lume OS** - CalVer 2026.11 • Release 0.1 Beta
