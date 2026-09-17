# WSL networking & devices — load for port-visibility questions, proxy failures, USB passthrough decisions, or model-sizing doubts

## Suggestion order (decide first)

Hardware-bound or identity-bound workloads are suggested to run on the **native Windows side** (`env-windows` routing): physical ADB/USB devices, serial/JTAG consoles, port-specific targets whose reachability depends on the host's network identity (enterprise ACLs pin the host MAC/IP). Everything below documents what's possible from inside WSL as *labeled fallbacks*, not suggestions.

## NAT vs mirrored matrix (facts for whoever ends up staying in WSL)

| Aspect | default (NAT) | `networkingMode=mirrored` (Win11 22H2+) |
|---|---|---|
| host → container/process ports | auto-forwarded, visible on Windows `localhost` | visible directly (shared stack); bind `0.0.0.0` if only `127.0.0.1` works from Windows |
| WSL process → host LAN device | through vEthernet + host NAT — often dropped by enterprise ACLs | shares host identity — generally reaches what the host reaches |
| `host.docker.internal` | works | works |
| Windows proxy settings | injected into env (`autoProxy`) | same leak, different plumbing |

Switch modes in `C:\Users\<you>\.wslconfig` ([wsl2] `networkingMode=…`), then `wsl --shutdown`; prove which mode is live with `wslinfo --networking-mode` (`nat` vs `mirrored`). Mirrored is the right answer for LAN-device work that genuinely must stay in WSL; on hardened corporate boxes it adds variables — test once, record the outcome in project `AGENTS.md`.

## Proxy leak (classic false alarm)

Symptom: browser fine, `curl`/tooling fail from WSL with proxy errors. Windows IE proxy settings are imported into WSL env when `autoProxy=true`. Diagnose and fix:

```bash
env | grep -i proxy                     # spot the imported vars
curl -sS --max-time 5 https://example.com && echo ok || curl -sS --max-time 5 --noproxy '*' https://example.com   # retry without proxy
# permanent fix: autoProxy=false in .wslconfig + wsl --shutdown (or unset per shell)
```

## IPv6

Dual-stack breakage (connects in browser, fails in tooling, or vice versa) → try disabling IPv6 in the distro netplan or the Windows adapter; record which knob fixed it. Don't chase it blindly: capture `ip addr` + failing command output first.

## GPU sizing vs memory cap

The `[wsl2] memory=` cap limits RAM available to WSL — including what models can load. Cap below model footprint → OOM kill or silent CPU fallback (much slower). Check the live total with `free -g` and keep cap ≥ model table rows from the `local-models` skill (+~2–4 GB headroom). No GPU at all: CPU inference still works, just size smaller.

## USB passthrough (`usbipd`) — labeled last resort

Only if the user insists on staying in WSL for a USB-device workflow. Costs stated plainly: extra service layer, admin rights, Win10/11, reattach after every reboot/driver change, and DFU/firmware flows remain flaky through the bridge — flashing still belongs on the Windows side.

```powershell
winget search usbipd            # pick the official entry (Daer/usbipd-win releases); verify id before install
usbipd enable                   # starts the Windows service
usbipd list -v                  # find the busid of the device
usbipd attach --wsl -b <busid>  # admin; device now appears inside WSL
usbipd detach -b <busid>        # give it back to Windows when done
```

If it misbehaves twice, stop: move the workload to native Windows per the routing table instead of debugging the bridge.
