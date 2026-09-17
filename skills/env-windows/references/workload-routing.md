# Windows workload routing reference — load when deciding WHERE to run a task, or when a tool "can't find" devices/SDKs

## The rule

The environment follows the toolchain and hardware, not the other way around. Before starting a task ask two questions:

1. Where is the primary toolchain installed? (Android Studio → that side; VS+MSVC → that side; generic Node/Python/Rust → wherever the user develops)
2. Does the task touch physical/network equipment? (USB device, serial console, LAN-attached PLC/router → the host where the port/interface exists)

If the toolchain is not installed yet, install it in the home the user chose: presenting WSL as an option with its trade-offs (faster FS, real GNU userspace) is allowed; telling them to move is not. If both answers point one way, run the whole task there; cross the boundary only for read-only artifacts (logs in, binaries out).

## Android (native pwsh)

- Canonical layout: SDK at `%LOCALAPPDATA%\Android\Sdk` (projects pin it via `local.properties sdk.dir=`), `adb` from platform-tools on PATH, caches in `%USERPROFILE%\.gradle` / `.android`. Keep checkouts on NTFS (`C:\dev`, `D:`) — a Gradle build reading the SDK through `/mnt/c` pays the 9P tax on every file.
- One adb server, started once on the Windows side: `adb start-server`, prove with `adb devices`. Never spawn a second adb inside WSL — it binds its own localhost:5037 and sees zero devices.
- Escape hatch if a WSL-side process must drive adb: host bind + remote client (security caveat: listening on all interfaces in an office network):
  ```powershell
  # Windows side (one-time, trusted networks only)
  adb -a -P 5037 start-server
  # WSL side: <host-ip> = default gateway from `ip route show default`
  adb -H <host-ip> -P 5037 devices
  ```
- Emulator hypervisor (WHPX/HAXM) is host-side too — don't launch emulators from WSL.

## Embedded / IoT, serial & firewalled LAN (native pwsh)

- Devices attach to the host USB bus / NIC, so they appear as COM ports on Windows: enumerate with `[IO.Ports.SerialPort]::GetPortNames()`. Nothing in WSL sees them without explicit passthrough config that most machines don't have.
- WSL2's default NAT mode traverses `vEthernet` + host NAT — enterprise firewalls typically ACL the host MAC/IP only, so WSL-originated traffic to device IPs (PLCs, routers, SBCs) silently drops. Mirrored networking mode shares the host stack and works better, but adds variables on hardened corporate boxes. Default: native.
- Tooling goes native: esptool/pyocd/st-link-cli/jlink in a venv or winget/official installer on the pwsh side; never flash from WSL.
- Long-lived raw serial protocols need a real TTY — drive them from PuTTY/Tera Term or a dedicated terminal session, not the agent shell (non-tty stdin breaks framing/timeouts).

## Crossing the boundary deliberately

- Move finished artifacts across (`Copy-Item` ↔ `cp`), never edit the same source tree from both sides simultaneously via `/mnt`.
- Tasks needing both worlds (firmware + companion dashboard) become two explicit phases; record the phase boundary in project `AGENTS.md` so the next session doesn't guess.
