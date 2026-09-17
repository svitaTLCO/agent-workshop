#!/usr/bin/env bash
# Probe machine + tools. Output KEY=value lines. No secrets printed.
set -u
raw_os=$(uname -s 2>/dev/null || echo unknown)
case "$raw_os" in Darwin) os=darwin ;; Linux) os=linux ;; MINGW*|MSYS*|CYGWIN*) os=windows ;; *) os="$raw_os" ;; esac
arch=$(uname -m 2>/dev/null || echo unknown)
[ "$os" = "darwin" ] && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" = "1" ] && arch=arm64
is_wsl=0; grep -qi microsoft /proc/version 2>/dev/null && is_wsl=1
is_container=0; [ -f /.dockerenv ] && is_container=1
shell_now="${SHELL:-unknown}"
ram_gb="unknown"
if [ -f /proc/meminfo ]; then ram_gb=$(( $(awk '/MemTotal/{print $2}' /proc/meminfo) / 1024 / 1024 ))
elif [ "$os" = "darwin" ]; then ram_gb=$(( ($(sysctl -n hw.memsize 2>/dev/null || echo 0)) / 1073741824 ))
fi
[ "$ram_gb" = "0" ] && ram_gb="unknown"
distro=unknown
if [ -f /etc/os-release ]; then distro=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
elif [ "$os" = "darwin" ]; then distro="macos-$(sysctl -n kern.osproductversion 2>/dev/null || echo unknown)"; fi
has_systemd=0; command -v systemctl >/dev/null 2>&1 && has_systemd=1
if [ "$os" = "darwin" ]; then gpu=apple
elif command -v nvidia-smi >/dev/null 2>&1; then gpu=nvidia
else
  gpu=none
  if command -v lspci >/dev/null 2>&1; then
    gpus=$(lspci 2>/dev/null | grep -Ei 'vga|3d controller' || true)
    echo "$gpus" | grep -qi nvidia && gpu=nvidia
    [ "$gpu" = none ] && echo "$gpus" | grep -Eqi 'advanced micro devices|\[amd/ati\]' && gpu=amd
    [ "$gpu" = none ] && echo "$gpus" | grep -qi 'intel corporation' && gpu=intel
  fi
fi
npu=0; [ "$os" = "darwin" ] && [ "$arch" = "arm64" ] && npu=1
mac_kind=""; mac_chip=""; cpu_cores=""
if [ "$os" = "darwin" ]; then
  cpu_cores=$(sysctl -n hw.physicalcpu 2>/dev/null || echo unknown)
  chip=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || true)
  case "${chip:-}" in *Apple*) mac_kind=apple-silicon ;; *) mac_kind=intel ;; esac
  mac_chip="${chip:-unknown}"
fi
has(){ command -v "$1" >/dev/null 2>&1 && echo 1 || echo 0; }
echo "OS=$os"; echo "ARCH=$arch"; echo "DISTRO=$distro"; echo "SHELL=$shell_now"
echo "IS_WSL=$is_wsl"; echo "IS_CONTAINER=$is_container"; echo "RAM_GB=$ram_gb"
echo "MAC_KIND=$mac_kind"; echo "MAC_CHIP=$mac_chip"; echo "CPU_CORES=$cpu_cores"
echo "HAS_SYSTEMD=$has_systemd"; echo "GPU=$gpu"; echo "NPU=$npu"
echo "HAS_RTK=$(has rtk)"; echo "HAS_OLLAMA=$(has ollama)"; echo "HAS_DOCKER=$(has docker)"
echo "HAS_GH=$(has gh)"; echo "HAS_NODE=$(has node)"; echo "HAS_PYTHON=$(has python3)"
