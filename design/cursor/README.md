# Cursor Lume Arrow — especificações

## Variantes
- `lume-arrow-24.svg` — 24px, ponta suave, cor acento `#3E8EF7`, núcleo tinta `#0E1116`
- `lume-arrow-32.svg` — 32px, mesma geometria
- `lume-arrow-48.svg` — 48px, mesma geometria
- `lume-arrow-wait.svg` — espera: arcos do logo girando (animação SVG, 1.2s loop)

## Design
- Seta com ponta suave (não afiada demais)
- Núcleo circular no centro (referência ao círculo central do logo)
- Cores da paleta Lume: acento `#3E8EF7`, tinta `#0E1116`
- Formato fonte: SVG (converter para .cur/.ani na integração do shell)

## Uso
- Cursor padrão da sessão Lume (todos os tiers)
- Estado de espera = arcos do logo girando (confere identidade visual)
- Hover lift 2px, press scale .98 (aplicado no shell QML, não no cursor em si)
