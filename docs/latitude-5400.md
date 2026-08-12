# Dell Latitude 5400 notes

## What this machine is

A 14" Intel laptop with integrated graphics and 16 GB RAM. Fine for editors, browsers, Docker, and light local models. Poor for gaming and heavy GPU training.

## Graphics

Use Ubuntu's Mesa stack. Do **not** install NVIDIA drivers. Intel UHD 620 is supported out of the box on 22.04/24.04.

## Power

- `power-profiles-daemon` with **balanced** by default
- `powerprofilesctl set performance` when plugged in and compiling
- TLP is not installed (it fights this daemon)
- GNOME: suspend on battery after idle; do not suspend on AC (so a compile can finish)

## Memory

zram gives compressed swap in RAM. That is more appropriate here than a huge disk swap. Swappiness is left at Ubuntu default.

## Storage

If an SSD/NVMe is detected, `fstrim.timer` is enabled. Do not add exotic I/O schedulers.

## What was not changed

- CPU frequency driver (intel_pstate as Ubuntu ships it)
- Spectre/Meltdown mitigations
- Custom kernel
- Undervolt utilities

## Firmware

Dell firmware updates via `fwupd` when Dell publishes them:

```bash
fwupdmgr get-updates
# review, then: sudo fwupdmgr update
```

Not run automatically.
