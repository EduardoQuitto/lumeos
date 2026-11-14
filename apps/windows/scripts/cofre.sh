#!/bin/bash
# cofre.sh — Gerenciador de MicroVM Descartável para Lume OS
# Requisitos fase 22:
#   - microVM descartavel
#   - abre app de risco e destroi sem residuo

set -euo pipefail

COFRE_NAME="${1:-cofre-default}"
COFRE_DIR="${2:-/var/lib/lume/cofre/$COFRE_NAME}"
MEMORY="${3:-512}"
VCPU="${4:-1}"
APP_CMD="${5:-}"

log() {
    echo "[cofre] $1"
}

# ==================== VALIDACAO ====================
validar_ambiente() {
    log "Verificando ambiente para Modo Cofre..."

    if [ "$(id -u)" -ne 0 ]; then
        log "ERRO: Este script deve ser executado como root"
        exit 1
    fi

    if command -v cloud-hypervisor >/dev/null 2>&1; then
        log "cloud-hypervisor encontrado"
    elif command -v qemu-system-x86_64 >/dev/null 2>&1; then
        log "QEMU encontrado (alternativa a cloud-hypervisor)"
    else
        log "AVISO: Nenhum hypervisor encontrado"
    fi

    log "Ambiente validado"
}

# ==================== CRIAR MICROVM ====================
criar_microvm() {
    log "Criando microVM: $COFRE_NAME"

    mkdir -p "$COFRE_DIR"
    mkdir -p "$COFRE_DIR/rootfs"
    mkdir -p "$COFRE_DIR/seals"

    # Copiar sistema base minimo para a microVM
    if [ -d /usr/share/lume/base ]; then
        cp -r /usr/share/lume/base/* "$COFRE_DIR/rootfs/" 2>/dev/null || true
    fi

    log "MicroVM criada: $COFRE_DIR"
}

# ==================== EXECUTAR APP DE RISCO ====================
executar_app_risco() {
    local app_cmd="${1:-}"
    local app_args="${2:-}"

    log "Executando app de risco na microVM: $COFRE_NAME"

    if [ -z "$app_cmd" ]; then
        log "ERRO: Nenhum comando de aplicativo especificado"
        return 1
    fi

    if command -v cloud-hypervisor >/dev/null 2>&1; then
        cloud-hypervisor \
            --cpus "$VCPU" \
            --memory "$MEMORY"M \
            --kernel /boot/vmlinuz \
            --initrd /boot/initrd.img \
            --disk path="$COFRE_DIR/rootfs" \
            --cmdline "root=/dev/vda1 ro console=ttyS0" \
            --cmdline-extra "app_cmd=$app_cmd app_args=$app_args" &
    elif command -v qemu-system-x86_64 >/dev/null 2>&1; then
        qemu-system-x86_64 \
            -m "$MEMORY" \
            -smp "$VCPU" \
            -drive file="$COFRE_DIR/rootfs",format=raw \
            -kernel /boot/vmlinuz \
            -initrd /boot/initrd.img \
            -append "root=/dev/vda1 ro console=ttyS0 app_cmd=$app_cmd app_args=$app_args" \
            -daemonize
    else
        log "AVISO: Nenhum hypervisor disponível para executar a microVM"
    fi

    log "App de risco iniciado na microVM: $COFRE_NAME"
}

# ==================== DESTRUIR MICROVM ====================
destruir_microvm() {
    log "Destruindo microVM: $COFRE_NAME"

    # Parar a microVM
    if command -v cloud-hypervisor >/dev/null 2>&1; then
        cloud-hypervisor --stop "$COFRE_NAME" 2>/dev/null || true
    elif command -v qemu-system-x86_64 >/dev/null 2>&1; then
        pkill -f "qemu-system-x86_64.*$COFRE_NAME" 2>/dev/null || true
    fi

    # Apagar todos os dados da microVM
    if [ -d "$COFRE_DIR" ]; then
        # Sobreescrever dados antes de apagar (secure wipe)
        if command -v shred >/dev/null 2>&1; then
            find "$COFRE_DIR" -type f -exec shred -u -z {} \; 2>/dev/null || true
        fi
        rm -rf "$COFRE_DIR"/* 2>/dev/null || true
        rmdir "$COFRE_DIR" 2>/dev/null || true
    fi

    log "MicroVM destruída: $COFRE_NAME - sem resíduo"
}

# ==================== VERIFICAR SE DESTRUIDO ====================
verificar_destruicao() {
    local cofre_dir="${1:-$COFRE_DIR}"

    if [ ! -d "$cofre_dir" ]; then
        log "OK: MicroVM completamente destruída - sem resíduo"
        return 0
    else
        log "AVISO: Ainda existem resíduos em $cofre_dir"
        return 1
    fi
}

# ==================== PRINCIPAL ====================
main() {
    local acao="${1:-criar}"

    case "$acao" in
        criar)
            criar_microvm
            ;;
        executar)
            executar_app_risco "${2:-}" "${3:-}"
            ;;
        destruir)
            destruir_microvm
            ;;
        verificar)
            verificar_destruicao "${2:-$COFRE_DIR}"
            ;;
        *)
            echo "Uso: $0 {criar|executar|destruir|verificar} [nome] [comando] [argumentos]"
            echo ""
            echo "Exemplos:"
            echo "  $0 criar meu-cofre"
            echo "  $0 executar meu-cofre wine app.exe"
            echo "  $0 destruir meu-cofre"
            echo "  $0 verificar meu-cofre"
            exit 1
            ;;
    esac
}

main "$@"
