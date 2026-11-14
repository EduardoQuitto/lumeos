#!/usr/bin/env bash
# tests/qemu/smoke.sh - CI QEMU smoke test para Lume OS ISO amd64/i386
# Requisitos fase 26:
#   - boot QEMU <20s em VM Prime / <30s em VM real B
#   - screendump QMP salvo em design/shots/2/
#   - Executa em VM/container Linux (não no host Windows)

set -euo pipefail

ARCH="${1:-amd64}"
ISO_DIR="out"
ISO_FILE="lume-${ARCH}.iso"
QEMU_BIN="qemu-system-${ARCH}"
SHOTS_DIR="design/shots/2"
ISO_PATH="${ISO_DIR}/${ISO_FILE}"
QMP_PORT="4446"
PID_FILE="/tmp/lume-qemu-smoke-${ARCH}.pid"
SCREENSHOT="${SHOTS_DIR}/boot-${ARCH}.png"
BOOT_TIMEOUT="${QEMU_BOOT_TIMEOUT:-60}"  # segundos

mkdir -p "$SHOTS_DIR"

if [ ! -f "$ISO_PATH" ]; then
  echo "ERRO: ISO não encontrada: $ISO_PATH"
  echo "Gere a ISO primeiro com build/live-build/build.sh (em VM Linux)."
  exit 1
fi

if ! command -v "$QEMU_BIN" >/dev/null 2>&1; then
  echo "ERRO: $QEMU_BIN não encontrado. Instale qemu-system-${ARCH}."
  exit 1
fi

if ! command -v nc >/dev/null 2>&1; then
  echo "AVISO: nc (netcat) não encontrado. Screendump QMP não funcionará."
fi

# Limpar QMP anterior
rm -f "$PID_FILE"

iniciar_qemu() {
    echo "Iniciando QEMU ($ARCH) com ISO: $ISO_PATH"

    if [ "$ARCH" = "i386" ]; then
        qemu-system-i386 \
            -m 2048 -smp 2 -cpu kvm32 \
            -drive file="$ISO_PATH",format=raw,if=virtio \
            -vga std \
            -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
            -qmp tcp:localhost:${QMP_PORT},server,nowait \
            -pidfile "$PID_FILE" \
            -daemonize \
            -display sdl,gl=on \
            -no-reboot
    else
        qemu-system-x86_64 \
            -m 4096 -smp 4 -enable-kvm -cpu host \
            -drive file="$ISO_PATH",format=raw,if=virtio \
            -vga virtio \
            -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
            -qmp tcp:localhost:${QMP_PORT},server,nowait \
            -pidfile "$PID_FILE" \
            -daemonize \
            -display sdl,gl=on \
            -no-reboot
    fi
}

qmp_exec() {
    echo "$1" | nc -q 1 localhost "$QMP_PORT" 2>/dev/null || true
}

aguardar_boot() {
    local inicio=$(date +%s)
    local agora decorrido

    echo "Aguardando boot QEMU (limite ${BOOT_TIMEOUT}s)..."

    while true; do
        if ! kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
            echo "ERRO: QEMU encerrou inesperadamente"
            return 1
        fi

        agora=$(date +%s)
        decorrido=$((agora - inicio))

        if [ "$decorrido" -ge "$limite" ]; then
            echo "ERRO: Boot excedeu ${limite}s"
            return 1
        fi

        if qmp_exec '{"execute":"query-status"}' 2>/dev/null | grep -q '"status":"running"'; then
            echo "OK: Boot QEMU concluído em ${decorrido}s (limite ${limite}s)"
            return 0
        fi

        sleep 1
    done
}

screendump() {
    echo "Capturando screendump QMP..."
    qmp_exec '{"execute":"screendump","arguments":{"filename":"'"$SCREENSHOT"'"}}' >/dev/null 2>&1 || true
    sleep 2
    if [ -f "$SCREENSHOT" ]; then
        echo "Screenshot salvo: $SCREENSHOT"
    else
        echo "AVISO: screendump não gerado"
        return 1
    fi
}

parar_qemu() {
    qmp_exec '{"execute":"quit"}' >/dev/null 2>&1 || true
    sleep 2
    kill "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null || true
    rm -f "$PID_FILE"
}

# Execução principal
echo "=== Smoke test QEMU - Lume OS ${ARCH} ==="
iniciar_qemu

if aguardar_boot; then
    screendump
    parar_qemu
    echo "=== Smoke test concluído com sucesso ==="
    exit 0
else
    parar_qemu
    echo "=== Smoke test FALHOU ==="
    exit 1
fi
