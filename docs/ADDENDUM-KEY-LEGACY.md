# ADDENDUM — Pendrive-chave + tier do i5-7400/650Ti
## Pendrive-chave (amplia f28/f29)
- exFAT do Ventoy carrega: ISO + persistence.dat + lume-web.url + guia + keyfile.
- Gateway web autentica por keyfile do pendrive (ou FIDO2) + PIN; sessão efêmera;
  snapshot opcional criptografado com a mesma chave. Sem chave = sem sessão.
- Aceite f29: Chromebook/PC travado abre aba, insere chave, usa Lume completo <90 s.
## Legacy NVIDIA (amplia f18/f25)
- Empacotar driver 470.xx legacy (Kepler) como opção pós-instalação; nouveau blacklist.
- Limiar Prime reavaliado com driver proprietário: 650 Ti + 8 GB => PRIME visual.
- Teste de aceite f25 nessa máquina real: idle <=450 MB, Hyprland 60 fps, GFN 1080p60,
  boot <20 s. Registrar resultados no painel como tier "prime-legacy".
- Honestidade no README: 4c/4t não iguala 16 threads em carga pesada; o ganho é
  remover o desperdício do SO, não criar CPU.