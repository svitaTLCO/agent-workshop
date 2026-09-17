# Linux toolchains reference — load when installing language runtimes, build systems, or GPU acceleration stacks

## Stance

- System-level tools (git, gh, curl, jq, docker engine + toolkit) → **distro packages**, always. Never curl-pipe installers for anything the repo ships.
- Application runtimes (pinned versions per project) → exactly **one version manager per language per machine** (same rule as `env-windows`): volta *or* nvm, pyenv *or* system python + venv, rustup for Rust, stock Go with `go env GOPATH` bin on PATH. Two managers of one runtime = shadowing bugs.
- Build toolchain baseline per distro: Ubuntu/Debian `build-essential pkg-config`, Fedora/RHEL `gcc-c++ make pkgconf-pkg-config`, Arch `base-devel`. Add `cmake ninja-build` only when a project needs them.

## Decision ladder

1. Distro package → 2. Version manager (volta/pyenv/rustup/cargo/go) → 3. Source build against system deps (record steps in project `AGENTS.md`) → 4. Container builder: keep the host clean for one-off/heavy builds —
   ```bash
   docker run --rm -v "$PWD":/work -w /work golang:1.23 go build ./...
   ```

## GPU acceleration — name the real silicon first

```bash
lspci | grep -Ei 'vga|3d controller'    # what is actually in the box before picking a stack
```

- **NVIDIA**: driver from the **distro repo only** (Ubuntu: `sudo ubuntu-drivers install`; Fedora/RHEL/Arch: vendor packages via your PM), reboot, prove with `nvidia-smi`. CUDA toolkit is separate from the driver: distro repo or NVIDIA's `.deb`/`.rpm`, never the `.run` on repos with their own driver packaging; match its major version to the framework. Containers: `nvidia-container-toolkit`, acceptance check `docker run --gpus all nvidia/cuda:12.x-base nvidia-smi`.
- **AMD Radeon** (ROCm is Linux-first-class here): kernel driver ships in the distro (`amdgpu`); user-space runtime via your PM (e.g. Fedora `rocm-opencl-runtime`, Ubuntu the `rocm-*` metapackages) for HIP-based runtimes. Prove with `rocminfo` listing the device. llama.cpp/Ollama: use the ROCm/HIP build where published, otherwise the **Vulkan** build (`vulkan-tools` → `vulkaninfo --summary` proves the path). Expect model coverage one release behind CUDA — say so instead of promising parity.
- **Intel** (Arc discrete or iGPU): default safe lane is the **Vulkan** build against the mesa ANV driver (`vulkan-tools` proof as above). SYCL/oneAPI (`intel-oneapi-basekit` via Intel's apt/yum repo) only when a runtime explicitly wants it — it's heavy; don't pre-install. An iGPU alone is not an accelerator for sizing purposes: treat the box as CPU-level per `local-models`.
- No usable GPU in any lane: CPU inference still works; don't chase "cuda"/"hip"/"vulkan" errors without re-running the enumeration above.
