#!/usr/bin/env bash
set -euo pipefail

ARCH="${1:-amd64}"
ISO_DIR="out"
ISO_FILE="lume-${ARCH}.iso"
QEMU_ARCH="x86_64"
[ "$ARCH" = "i386" ] && QEMU_ARCH="i386"

ISO_PATH="${ISO_DIR}/${ISO_FILE}"
SHOTS_DIR="design/shots/0"
mkdir -p "$SHOTS_DIR"

if [ ! -f "$ISO_PATH" ]; then
  echo "ISO não encontrada: $ISO_PATH"
  exit 1
fi

QMP_PORT="4446"
PID_FILE="/tmp/lume-qemu-${ARCH}.pid"
SCREENSHOT="${SHOTS_DIR}/boot-${ARCH}.png"

iniciar_qemu() {
  if [ "$QEMU_ARCH" = "i386" ]; then
    qemu-system-i386 \
      -m 2048 -smp 2 -cpu kvm32 \
      -drive file="$ISO_PATH",format=raw,if=virtio \
      -vga std \
      -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
      -qmp tcp:localhost:${QMP_PORT},server,nowait \
      -pidfile "$PID_FILE" \
      -daemonize \
      -display sdl,gl=on &
  else
    qemu-system-x86_64 \
      -m 4096 -smp 4 -enable-kvm -cpu host \
      -drive file="$ISO_PATH",format=raw,if=virtio \
      -vga virtio \
      -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
      -qmp tcp:localhost:${QMP_PORT},server,nowait \
      -pidfile "$PID_FILE" \
      -daemonize \
      -display sdl,gl=on &
  fi
}

aguardar_boot() {
  local inicio=$(date +%s)
  while true; do
    if ! kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
      echo "QEMU encerrou inesperadamente"
      return 1
    fi
    local agora=$(date +%s)
    local decorrido=$((agora - inicio))
    if [ "$decorrido" -ge 30 ]; then
      echo "Boot excedeu 30s"
      return 1
    fi
    if qmp_exec '{"execute":"query-status"}' 2>/dev/null | grep -q '"status":"running"'; then
      echo "Boot OK em ${decorrido}s"
      return 0
    fi
    sleep 1
  done
}

qmp_exec() {
  echo "$1" | nc -q 1 localhost "$QMP_PORT" 2>/dev/null || true
}

screendump() {
  qmp_exec '{"execute":"screendump","arguments":{"filename":"'"$SCREENSHOT"'"}}' >/dev/null 2>&1 || true
  if [ -f "$SCREENSHOT" ]; then
    echo "Screenshot salvo: $SCREENSHOT"
  else
    echo "Aviso: screendump não gerado"
  fi
}

parar_qemu() {
  qmp_exec '{"execute":"quit"}' >/dev/null 2>&1 || true
  sleep 2
  kill "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null || true
  rm -f "$PID_FILE"
}

iniciar_qemu
if aguardar_boot; then
  screendump
  parar_qemu
  exit 0
else
  parar_qemu
  exit 1
fi
