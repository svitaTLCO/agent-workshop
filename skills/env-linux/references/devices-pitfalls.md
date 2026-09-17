# Linux devices & pitfalls reference — load when output looks garbled, devices misbehave, or two runtimes fight over PATH

## Hardware-bound work runs natively here

USB serial/JTAG and physical ADB devices attach directly (`/dev/ttyUSB*`, `/dev/ttyACM*`, openocd/pyocd see the bus). This box owns the hardware — no passthrough bridge, no WSL exit, unlike the Windows home. Android SDK + `adb devices` are first-class too; route embedded/IoT and mobile-device workloads here.

## Stable device naming (udev)

`/dev/ttyUSB0` indices shuffle between reconnects — never hardcode them. Persistent symlink recipe:

```bash
udevadm info -a -n /dev/ttyUSB0 | grep -E 'ATTRS\{(idVendor|idProduct|serial)\}'   # find stable attrs
cat > /etc/udev/rules.d/99-mydevice.rules <<'EOF'
SUBSYSTEM=="tty", ATTRS{idVendor}=="1a2b", ATTRS{idProduct}=="0001", GROUP="dialout", MODE="0660", SYMLINK+="iot/dev1"
EOF
sudo udevadm control --reload && sudo udevadm trigger && sudo usermod -aG dialout "$USER"   # re-login after group change
ls -l /dev/iot/dev1                                                                         # proof
```

Replug (not just reload) to confirm the symlink sticks; record the final path in project `AGENTS.md`.

## Encoding / locale

Trap: `LANG` unset or `C` → non-ASCII tool output mojibakes and some libraries assume ASCII paths. Fix (no `locale-gen` needed): put `export LANG=C.UTF-8` in your rc **after** the interactive guard; prove with `locale charmap` → `UTF-8`. Keep it UTF-8 in agent sessions or byte-exact file writes start lying about encoding.

## PATH shadowing

Multiple runtimes (distro + managers) → the *first* entry silently wins:

```bash
type -aP node          # every hit, in resolution order
command -v node        # the winner — pin THIS path in unit files/scripts
```

Caveat: on merged-usr distros (`/bin` → `/usr/bin`) `type -aP` lists the *same* binary twice. Compare realpaths before declaring a conflict:

```bash
type -aP node | xargs -r -n1 readlink -f | sort -u   # >1 lines = genuine shadowing
```

Same pattern for `python3` and `cargo`. If two entries point at different real files, remove the dead one from PATH (usually an old manager bin dir left in rc) rather than ordering around it.

## Ports & firewalls

Localhost ports need no config. For inbound reachability (remote agent tunnels, LAN clients): check `sudo ufw status` / `nft list ruleset` and allow only the specific source — do not open 0.0.0.0 on dev boxes behind corporate networks.

## Headless

No `$DISPLAY` is normal on servers: prefer headless flags; `xvfb-run <cmd>` only for genuinely GUI-bound one-offs. Don't install X on a server box unless a workload requires it and says so in `AGENTS.md`.
