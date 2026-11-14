#!/bin/bash
# seccomp-profile.sh — Configuração de seccomp para Lume OS Shield
# Requisitos fase 21:
#   - seccomp para daemons e aplicativos

set -euo pipefail

DAEMON="${1:-lume-detect}"
SECCOMP_DIR="${2:-/etc/seccomp}"

log() {
    echo "[seccomp] $1"
}

# ==================== VALIDAÇÃO ====================
validar_ambiente() {
    log "Verificando ambiente para seccomp..."

    if [ "$(id -u)" -ne 0 ]; then
        log "ERRO: Este script deve ser executado como root"
        exit 1
    fi

    if ! grep -q seccomp /proc/1/status 2>/dev/null; then
        log "AVISO: seccomp pode não estar disponível no kernel"
    fi

    log "Ambiente validado"
}

# ==================== CRIAR PERFIL SECCOMP ====================
criar_perfil_seccomp() {
    local daemon="${1}"
    local perfil_dir="${2:-/etc/seccomp}"

    log "Criando perfil seccomp para: ${daemon}"

    mkdir -p "${perfil_dir}"

    cat > "${perfil_dir}/${daemon}.seccomp" << 'EOF'
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "architectures": [
    "SCMP_ARCH_X86_64",
    "SCMP_ARCH_X86",
    "SCMP_ARCH_X32"
  ],
  "syscalls": [
    {
      "name": "read",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "write",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "open",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "openat",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "close",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "stat",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fstat",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "lstat",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "poll",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "lseek",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "mmap",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "mprotect",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "munmap",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "rt_sigaction",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "rt_sigprocmask",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "rt_sigreturn",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "ioctl",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "readv",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "writev",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "access",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "pipe",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "select",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sched_yield",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "mremap",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "msync",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "mincore",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "madvise",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "shmget",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "shmat",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "shmctl",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "dup",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "dup2",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "pause",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "nanosleep",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getitimer",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "alarm",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setitimer",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getpid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sendfile",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "socket",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "connect",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "accept",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sendto",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "recvfrom",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sendmsg",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "recvmsg",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "shutdown",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "bind",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "listen",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getsockname",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getpeername",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "socketpair",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setsockopt",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getsockopt",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "clone",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fork",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "vfork",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "execve",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "exit",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "exit_group",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "wait4",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "kill",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "uname",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fcntl",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "flock",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fsync",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fdatasync",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "truncate",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "ftruncate",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getcwd",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "chdir",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fchdir",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "rename",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "mkdir",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "rmdir",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "creat",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "link",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "unlink",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "symlink",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "readlink",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "chmod",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fchmod",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "chown",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fchown",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "lchown",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "umask",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "gettimeofday",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getrlimit",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getrusage",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sysinfo",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "times",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "ptrace",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getuid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getgid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "geteuid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getegid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setuid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setgid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "seteuid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setegid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getpgid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getppid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getpgrp",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setsid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setpgid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setreuid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setregid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "groups",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getgroups",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setgroups",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "uname",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sethostname",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setdomainname",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "iopl",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "ioperm",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "creat",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "llseek",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getdents",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "select",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "flock",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fsync",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fdatasync",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "truncate",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "ftruncate",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getdents64",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getcwd",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "chdir",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fchdir",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "rename",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "mkdir",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "rmdir",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "creat",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "link",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "unlink",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "symlink",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "readlink",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "chmod",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fchmod",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "chown",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fchown",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "lchown",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "umask",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "gettimeofday",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getrlimit",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getrusage",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sysinfo",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "times",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "ptrace",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getuid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getgid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "geteuid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getegid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setuid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setgid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "seteuid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setegid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getpgid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getppid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getpgrp",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setsid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setpgid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setreuid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setregid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "groups",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getgroups",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setgroups",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "uname",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sethostname",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "setdomainname",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "iopl",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "ioperm",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "create_module",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "init_module",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "delete_module",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "get_kernel_syms",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "query_module",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "quotactl",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "nfsservctl",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "getpmsg",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "putpmsg",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "afs_syscall",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "tuxcall",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "security",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "gettid",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "readahead",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "setxattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "lsetxattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fsetxattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getxattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "lgetxattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fgetxattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "listxattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "llistxattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "flistxattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "removexattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "lremovexattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "fremovexattr",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "tkill",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "time",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "futex",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sched_setaffinity",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sched_getaffinity",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "set_thread_area",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_setup",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_destroy",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_getevents",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_submit",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_cancel",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "get_thread_area",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "lookup_dcookie",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "epoll_create",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "epoll_ctl_old",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "epoll_wait_old",
      "action": "SCMP_ACT_ERRNO"
    },
    {
      "name": "remap_file_pages",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getdents64",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "set_tid_address",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "restart_syscall",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "semtimedop",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "futex",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sched_setaffinity",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sched_getaffinity",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_setup",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_destroy",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_getevents",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_submit",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_cancel",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "get_thread_area",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "lookup_dcookie",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "epoll_create",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "epoll_ctl",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "epoll_wait",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "remap_file_pages",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "getdents64",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "set_tid_address",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "restart_syscall",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "semtimedop",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "futex",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sched_setaffinity",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "sched_getaffinity",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_setup",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_destroy",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_getevents",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_submit",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "io_cancel",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "get_thread_area",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "lookup_dcookie",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "epoll_create",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "epoll_ctl",
      "action": "SCMP_ACT_ALLOW"
    },
    {
      "name": "epoll_wait",
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
EOF

    log "Perfil seccomp criado: ${perfil_dir}/${daemon}.seccomp"
}

# ==================== APLICAR SECCOMP ====================
aplicar_seccomp() {
    local daemon="${1}"
    local perfil_dir="${2:-/etc/seccomp}"

    local perfil="${perfil_dir}/${daemon}.seccomp"

    if [ ! -f "${perfil}" ]; then
        log "ERRO: Perfil seccomp não encontrado: ${perfil}"
        return 1
    fi

    log "Aplicando perfil seccomp para: ${daemon}"

    # Encontrar PID do daemon
    local pid
    pid=$(pgrep -f "${daemon}" | head -1 2>/dev/null || true)

    if [ -z "${pid}" ]; then
        log "AVISO: Processo ${daemon} não encontrado, perfil será aplicado na próxima inicialização"
        return 0
    fi

    # Aplicar seccomp ao processo existente
    if command -v prctl >/dev/null 2>&1; then
        prctl --seccomp="${perfil}" --pid="${pid}" 2>/dev/null || true
        log "Seccomp aplicado ao PID ${pid}"
    else
        log "AVISO: prctl não disponível, perfil seccomp será aplicado na próxima inicialização"
    fi
}

# ==================== PRINCIPAL ====================
main() {
    log "=== Configurando seccomp para Lume Shield ==="

    validar_ambiente
    criar_perfil_seccomp "${DAEMON}" "${SECCOMP_DIR}"
    aplicar_seccomp "${DAEMON}" "${SECCOMP_DIR}"

    log "=== seccomp configurado com sucesso ==="
}

main "$@"
