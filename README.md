# WiFi Fix on MacBook Pro 2010 (BCM4322) on Fedora Linux

> **Fix for missing WiFi on MacBook Pro 2010 (Broadcom BCM4322, 802.11a/b/g/n) on Fedora Silverblue, Fedora Workstation, and other modern Linux distributions.**

This fix was tested on an **Apple MacBook Pro 2010 (MacBookPro7,1 — 13", Mid-2010)** running **Fedora Silverblue 44**, but applies to any machine with a BCM4322 chip.

---

## Who is this for?

If you:
- Have a **Broadcom BCM4322** WiFi card (check with `lspci | grep -i net`)
- See **no WiFi option** in your network settings
- Are running **Fedora Silverblue**, Fedora Workstation, or a similar distribution
- See the `b43` driver loaded but no WiFi interface (`ip link show` shows no `wlan*`)

...this is the fix for you.

---

## The Problem

The `b43` kernel driver for Broadcom wireless chips is included in Fedora by default, but it requires **proprietary firmware** that is not shipped with the OS. Without the firmware, the driver loads silently and no WiFi interface appears.

```bash
# Driver is loaded:
lsmod | grep b43   # shows b43, bcma, mac80211...

# But no WiFi interface:
ip link show       # only lo and ethernet, no wlan0
nmcli device       # no wifi device listed

# And no firmware files:
ls /lib/firmware/b43/   # No such file or directory
```

The `b43-firmware` package no longer exists in RPM Fusion. The firmware must be extracted from a Broadcom proprietary driver using `b43-fwcutter`.

---

## Quick Fix

### Fedora Silverblue (immutable / OSTree)

```bash
# 1. Enable RPM Fusion (no sudo needed on Silverblue — uses D-Bus daemon)
rpm-ostree install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 2. Download and run the fix script (requires pkexec GUI password prompt)
curl -fsSL https://raw.githubusercontent.com/vitaliebumbu/bcm4322-wifi-fedora-silverblue/main/scripts/fix-wifi-silverblue.sh -o /tmp/fix-wifi.sh
pkexec bash /tmp/fix-wifi.sh
```

> **Note:** A GUI password dialog will appear. Enter your user password to authorize.
>
> **Important:** The fix uses `rpm-ostree usroverlay` which makes `/usr` temporarily writable.  
> **This resets on every reboot.** Run the script again after each reboot, or see [Permanent Fix](#permanent-fix) below.

---

### Fedora Workstation / Standard Fedora (mutable)

```bash
# 1. Enable RPM Fusion
sudo dnf install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 2. Install b43-fwcutter and download firmware
sudo dnf install b43-fwcutter
curl -fsSL https://raw.githubusercontent.com/vitaliebumbu/bcm4322-wifi-fedora-silverblue/main/scripts/fix-wifi-workstation.sh | sudo bash
```

---

## Scripts

| Script | Purpose |
|--------|---------|
| [`fix-wifi-silverblue.sh`](scripts/fix-wifi-silverblue.sh) | One-shot fix for Fedora Silverblue (uses usroverlay) |
| [`fix-wifi-workstation.sh`](scripts/fix-wifi-workstation.sh) | Fix for standard Fedora / mutable systems |

---

## Permanent Fix

On Silverblue, the usroverlay approach is lost on reboot. For a permanent solution, a systemd service can re-apply the firmware on every boot:

```bash
pkexec bash /path/to/scripts/install-permanent.sh
```

See [`scripts/install-permanent.sh`](scripts/install-permanent.sh) for details.

---

## Verification

After running the fix:

```bash
ip link show          # wlan0 should appear
nmcli device status   # wifi device should show "disconnected" (ready)
nmcli device wifi list  # scan and list nearby networks
```

---

## Hardware Tested

| Component | Details |
|-----------|---------|
| Machine | Apple MacBook Pro 7,1 |
| WiFi Chip | Broadcom BCM4322 (PCI ID: `14e4:432b`) |
| OS | Fedora Silverblue 44 |
| Kernel | 7.0.4-200.fc44.x86_64 |
| Driver | `b43` (in-kernel) |
| Firmware | Extracted from `broadcom-wl-6.30.163.46` via `b43-fwcutter` |

---

## Related Issues

- `b43-firmware` package removed from RPM Fusion → must extract manually
- `rpm-ostree usroverlay` required on Silverblue to write to `/usr/lib/firmware`
- RPM Fusion repos can be installed without `sudo` on Silverblue via D-Bus daemon
- `pkexec` works for root actions on Silverblue via GNOME polkit agent

---

## License

Scripts are released under the MIT License. See [LICENSE](LICENSE).
