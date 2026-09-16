#!/usr/bin/env bash
# Probe machine + tools. Output KEY=value lines. No secrets printed.
set -u
os=$(uname -s 2>/dev/null || echo unknown)
arch=$(uname -m 2>/dev/null || echo unknown)
is_wsl=0; grep -qi microsoft /proc/version 2>/dev/null && is_wsl=1
is_container=0; [ -f /.dockerenv ] && is_container=1
shell_now="${SHELL:-unknown}"
ram_gb="unknown"
if [ -f /proc/meminfo ]; then ram_gb=$(( $(awk '/MemTotal/{print $2}' /proc/meminfo) / 1024 / 1024 )); fi
has(){ command -v "$1" >/dev/null 2>&1 && echo 1 || echo 0; }
echo "OS=$os"; echo "ARCH=$arch"; echo "SHELL=$shell_now"
echo "IS_WSL=$is_wsl"; echo "IS_CONTAINER=$is_container"; echo "RAM_GB=$ram_gb"
echo "HAS_RTK=$(has rtk)"; echo "HAS_OLLAMA=$(has ollama)"; echo "HAS_DOCKER=$(has docker)"
echo "HAS_GH=$(has gh)"; echo "HAS_NODE=$(has node)"; echo "HAS_PYTHON=$(has python3)"
