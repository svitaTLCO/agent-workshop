# Profiles

| Profile | Modules | Machine |
|---------|---------|---------|
| `minimal` | agent-onboard, env-detect, context-diet | any |
| `power` | minimal + shell-rtk, mcp-essentials, memory-system | any dev box |
| `windows-native` | power + env-windows | native Win32, no WSL dependency |
| `windows-wsl` | power + env-wsl | WSL2 |
| `mac-npu` | power + env-macos, local-models | Apple Silicon 32GB+ |
| `airgapped` | minimal + env-macos/env-linux, local-models | offline |
