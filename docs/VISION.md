# VISION.md — Como o Lume OS deve parecer ao final

## Protocolo de referências
- design/references/*.png são ALVOS visuais do dono (mockups), não assets para copiar.
  Layout, composição e proporções vêm deles; os assets finais são originais (PRD §4).
- Mapeamento em design/references/manifest.yaml, ex.:
  {superficie: desktop, arquivo: desktop-prime.png, tiers: [prime], temas: [light, dark]}
- A cada build, o agente gera screenshots QMP em design/shots/<fase>/<superficie>-<tema>.png
  e compara com a referência: diff ESTRUTURAL (posições, raios, cores, hierarquia), não
  pixel-perfect de wallpaper. Tolerância: layout idêntico, cor ΔE<3, raio ±1 px.
- Conflito referência×PRD: PRD vence em função/segurança/perf; referência vence em estética.
  Registrar em OPEN.md. Sign-off visual do dono por fase = gate estético no Mission Control.

## Sensação geral
"Vidro calmo sobre luz": desktop limpo, uma barra pílula, janelas de vidro flutuando,
movimento de mola, nada gritando. Premium não é gradiente em tudo.

## Superfícies — alvo final
1. Desktop: wallpaper do pack pareado claro/escuro automático; ícones off; barra pílula
   48 px/margem 8/ícones 28/dot 3 px; tray cluster; relógio 2 linhas por locale.
2. Janela (Files = canário): vidro + sidebar tingida, raio 12, titlebar 40 com controles à
   direita, toolbar+breadcrumb, sombra 2 camadas, borda interna 1 px; abrir scale .96→1 mola.
3. Flyouts: 4 painéis (redes, quick settings, volume, calendário+notificações), raio 16,
   vidro, slide 12 px, abrir <150 ms.
4. Iniciar: 640×560 centralizado sobre a barra; busca no topo; grid 6×3; recentes; rodapé
   usuário+energia.
5. Toasts: topo-direita, 360 px, stack 3, 2 ações.
6. Overview/alt-tab/snap: thumbnails centralizados; 4 layouts no hover do maximizar.
7. Greeter/lock: wallpaper escurecido+blur, relógio grande, avatar central, senha em pílula.
8. OOBE: cartão central de vidro sobre o wallpaper; passos idioma/teclado/rede/usuário/
   criptografia/tier/Essenciais.
9. Settings/Store/Security/Updates: nav esquerda 240 px vidro-lite + conteúdo papel/tinta;
   cards raio 12; badges de tier.
10. Terminal: fundo tinta 90% opaco (legibilidade > vidro), JetBrains Mono 13, starship
    2 linhas, abas, quake.
11. Energia/update: Plymouth fundo tinta + arcos do logo girando + texto pt/en + progresso.
12. Instalador/criador USB: mesmos cartões do OOBE; logo no header.

## Claro/escuro e wallpapers
Tema do sistema troca o wallpaper para a variante pareada do pack (wallpapers.yaml).
Vidro adapta o tint; contraste mínimo AA; alto contraste = material Sólido.

## Por tier (mesmo produto, nunca "outro sistema")
Prime: vidro + molas + overview completo. Core: Névoa/Sólido + sombras + fades.
Lite: mesmos tokens/ícones/fontes; picom blur leve se GL≥2.1; alt-tab em lista.

## Micro-detalhes
Cursor Lume Arrow (espera = arcos do logo); hover lift 2 px; press scale .98; focus ring
2 px; ruído 2% no vidro; um único set de ícones; strings pt sem truncamento.

## Anti-padrões (rejeitar na revisão)
Gradiente roxo em todo botão · ícones de estilos misturados · sombra dura de 1 camada ·
cantos inconsistentes · cinza claro sobre claro · animação linear · emoji como ícone ·
assets Apple/Microsoft · wallpaper saturado gritando sob o vidro.

## Checklist de aceite visual (fase 27)
[ ] 12 superfícies × light/dark aprovadas pelo dono
[ ] diff estrutural dentro da tolerância vs referências
[ ] pack claro/escuro pareado funcionando
[ ] logo nas 6 variantes em uso correto
[ ] cursor completo em todos os estados
[ ] 60 fps Prime / fades Core / Lite digno
[ ] zero anti-padrões · pt/en sem truncamento