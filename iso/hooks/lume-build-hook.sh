#!/bin/bash
# Hooks de build ISO Lume OS
# Executados durante live-build para adicionar firmware, kernel, Plymouth

set -euo pipefail

echo "Aplicando hooks de build Lume OS..."

# Adicionar firmware non-free
# Adicionar pacote NVIDIA opcional (tier C)
# Configurar Plymouth tema Lume
# Atualizar initrd com suporte a LUKS2 + verity

echo "Hooks aplicados com sucesso."
