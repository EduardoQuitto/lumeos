# Regras do agente Lume OS
1. Fases sequenciais (roadmap.yaml). Nunca pular. Cada tarefa tem aceite testável.
2. Fim de fase: suíte de testes → corrigir TODOS os blockers antes de avançar.
3. Não-blockers → backlog; varredura de limpeza nas fases 5,10,15,20,25.
4. 3 falhas na mesma tarefa → marcar bloqueada, alerta no painel, seguir independentes.
5. PROIBIDO dd/parted/mkfs em discos reais. Só imagens loop e QEMU.
6. Builds root só em container Podman. Sem sudo no host fora da whitelist.
7. Nunca assinar releases, nunca push externo, nunca guardar chaves.
8. Heartbeat + status no Mission Control a cada tarefa; screenshots via QMP screendump.
9. git commit convencional por tarefa; tag phase-N-done ao fechar fase.
10. rustfmt + clippy -D warnings + qmllint obrigatórios; testes por tarefa.
11. Sessão limitada a 5h (systemd timer); builds com CPUQuota=60%.
12. Testes de instalação em VM obrigatórios nas fases 15,16,23,26.
13. Fase 0.1: materializar docs/PRD.md a partir de decisions.md + roadmap.yaml.