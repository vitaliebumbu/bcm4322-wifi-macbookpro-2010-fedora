# MacBook Pro 2010 on Fedora Linux — Complete Fix Guide

**Everything that needs fixing after installing Fedora on a MacBook Pro 2010 (13", Mid-2010), explained in plain English.**

Tested on: MacBook Pro 13" Mid-2010 (MacBookPro7,1) — Fedora Silverblue 44.  
Also works on: Fedora Workstation.

---

## What this guide fixes

| Problem | Status |
|---------|--------|
| No WiFi showing up | ✅ Fixed |
| Camera shows green image | ✅ Fixed |
| Everything on screen looks too big | ✅ Fixed |
| Fans running too loud / CPU overheating | ✅ Fixed |
| GPU glitches and screen corruption | ✅ Fixed |
| Keyboard backlight not working | ✅ Fixed |
| Poor battery life | ✅ Fixed |

---

## Before you start

You need:
- A working internet connection (use an ethernet cable if WiFi is not working yet)
- Your login password

Open the **Terminal** app. You will paste commands into it one step at a time.

---

## Which version of Fedora do you have?

Paste this into the terminal and press Enter:

```
cat /etc/os-release | grep VARIANT
```

- If it shows **Silverblue** → use the commands marked 🔵 **Silverblue**
- If it shows **Workstation** → use the commands marked 🟢 **Workstation**

---

---

# Fix 1 — WiFi (no WiFi option at all)

The WiFi chip in this MacBook (Broadcom BCM4322) needs extra driver files that Fedora does not include by default.

**Step 1 — Enable extra software sources**

🔵 Silverblue:
```
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

🟢 Workstation:
```
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

**Step 2 — Run the WiFi fix**

🔵 Silverblue:
```
curl -fsSL https://raw.githubusercontent.com/vitaliebumbu/bcm4322-wifi-macbookpro-2010-fedora/main/scripts/fix-wifi-silverblue.sh -o /tmp/fix-wifi.sh && pkexec bash /tmp/fix-wifi.sh
```

> A password window will appear on screen — type your password and click OK.

🟢 Workstation:
```
curl -fsSL https://raw.githubusercontent.com/vitaliebumbu/bcm4322-wifi-macbookpro-2010-fedora/main/scripts/fix-wifi-workstation.sh | sudo bash
```

**How to know it worked:** The WiFi icon appears in the top bar. Click it and connect to your network.

> ⚠️ Silverblue only: this fix resets when you restart. See [Make fixes survive restarts](#make-fixes-survive-restarts) below.

---

---

# Fix 2 — Camera (green or broken image)

The built-in camera needs a small driver file (firmware) that must be copied from a macOS installation. Without it, the camera shows a green or distorted image.

**What you need:** A macOS installation on another partition, or a macOS installer USB drive.

**Step 1 — Find the macOS driver file**

On macOS (or on the macOS partition if you dual boot), the file you need is located at:

```
/System/Library/Extensions/IOUSBFamily.kext/Contents/PlugIns/AppleUSBVideoSupport.kext/Contents/MacOS/AppleUSBVideoSupport
```

Copy that file to a USB drive and bring it to your Fedora session. Save it somewhere easy to find, for example your Downloads folder.

**Step 2 — Install the extraction tool**

🔵 Silverblue:
```
rpm-ostree install isight-firmware-tools
```

🟢 Workstation:
```
sudo dnf install isight-firmware-tools
```

Then restart your computer.

**Step 3 — Extract and install the firmware**

Replace `/home/yourname/Downloads/AppleUSBVideoSupport` with the actual path where you saved the file:

```
pkexec ift-extract --apple-driver /home/yourname/Downloads/AppleUSBVideoSupport
```

Unplug and re-plug the camera (or restart) and the camera should now show normal colors.

**No macOS available?** You can download the firmware file from Apple's website as part of a macOS software update package. Search online for `AppleUSBVideoSupport isight.fw extract` for community guides on how to get it without a Mac.

---

---

# Fix 3 — Everything looks too big on screen

The screen is running at the correct resolution (1280×800), but GNOME's default font size can feel large on a 13" display. This makes everything slightly bigger than it needs to be.

**Quick fix — make text and UI slightly smaller:**

```
gsettings set org.gnome.desktop.interface text-scaling-factor 0.85
```

If that feels too small, try `0.9` instead:

```
gsettings set org.gnome.desktop.interface text-scaling-factor 0.9
```

To go back to the default:

```
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
```

**More control:** Install GNOME Tweaks for a visual slider to adjust this:

🔵 Silverblue:
```
rpm-ostree install gnome-tweaks
```

🟢 Workstation:
```
sudo dnf install gnome-tweaks
```

Open it from the app menu → **Fonts** → adjust **Scaling Factor**.

---

---

# Fix 4 — Fans and overheating

By default, Fedora does not know how to properly control the fans on a MacBook. The fans may run too slow (causing the laptop to overheat and slow down) or too loud.

**Step 1 — Install the MacBook fan controller**

🔵 Silverblue:
```
rpm-ostree install mbpfan
```

🟢 Workstation:
```
sudo dnf install mbpfan
```

Restart your computer after installing.

**Step 2 — Enable it to start automatically**

```
pkexec systemctl enable --now mbpfan
```

**How to know it worked:** The laptop runs cooler and quieter. The fans speed up smoothly when you do heavy work and slow down when idle.

---

---

# Fix 5 — GPU glitches and screen corruption

The graphics chip (NVIDIA GeForce 320M) uses the open-source `nouveau` driver on Linux. This driver has a known issue with this chip that can cause occasional screen glitches. The fix is to add a boot option that disables a problematic feature.

**Step 1 — Add the boot option**

🔵 Silverblue:
```
sudo rpm-ostree kargs --append=nouveau.runpm=0
```

🟢 Workstation:
```
sudo grubby --args="nouveau.runpm=0" --update-kernel=ALL
```

**Step 2 — Restart**

After restarting, screen corruption and GPU glitches should be gone or much less frequent.

---

---

# Fix 6 — Keyboard backlight

The keyboard backlight is detected by the system (`smc::kbd_backlight`) but may not respond to the `Fn` brightness keys out of the box.

**Control it manually from the terminal:**

Check current brightness (0–255):
```
cat /sys/class/leds/smc\:\:kbd_backlight/brightness
```

Set brightness (replace `100` with any value from 0 to 255):
```
pkexec bash -c 'echo 100 > /sys/class/leds/smc\:\:kbd_backlight/brightness'
```

Set to 0 to turn it off, 255 for maximum.

**For automatic control with Fn keys,** install `pommed` (if available for your Fedora version) or use a GNOME extension like **Brightness Control**.

---

---

# Fix 7 — Battery life

By default Fedora does not apply any power-saving settings. This can cut your battery life significantly. The fix installs a power management tool.

🔵 Silverblue:
```
rpm-ostree install power-profiles-daemon
```

🟢 Workstation:
```
sudo dnf install power-profiles-daemon
```

After restarting, you can switch between Power Saver, Balanced, and Performance from the top-right power menu in GNOME.

---

---

# Make fixes survive restarts

On Fedora Silverblue, some fixes (WiFi firmware, keyboard backlight) are lost when you restart, because parts of the system reset to their original state.

To install a service that re-applies everything automatically on every boot:

```
curl -fsSL https://raw.githubusercontent.com/vitaliebumbu/bcm4322-wifi-macbookpro-2010-fedora/main/scripts/install-permanent.sh -o /tmp/install-permanent.sh && pkexec bash /tmp/install-permanent.sh
```

A password window will appear — enter your password.

After this, WiFi will come back automatically after every restart.

---

---

## Something went wrong?

**WiFi icon not showing after the fix:**
Open the terminal and run:
```
nmcli device wifi list
```
If you see a list of networks, WiFi is working — just look for the icon in the top bar.

**"Command not found" error:**
Make sure you copied the entire command, including all the parts before and after the web address.

**pkexec password window not appearing:**
Make sure you are logged in to the desktop (not a text-only session). The password window is graphical and will not appear in a remote or text session.

**Camera still green after the fix:**
Make sure you used the correct path to the `AppleUSBVideoSupport` file and that the extraction step finished without errors.

**Still stuck?** [Open an issue](../../issues) and describe what happened, including what the terminal showed.

---

## Hardware in this machine

| Component | Details |
|-----------|---------|
| Machine | Apple MacBook Pro 13" Mid-2010 (MacBookPro7,1) |
| CPU | Intel Core 2 Duo P8600 @ 2.4GHz |
| GPU | NVIDIA GeForce 320M (MCP89) |
| WiFi | Broadcom BCM4322 |
| Camera | Apple iSight (05ac:8507) |
| Audio | Cirrus CS4206 |
| Ethernet | Broadcom BCM5764M |
| Bluetooth | Broadcom BCM2046 |
| Tested on | Fedora Silverblue 44, Kernel 7.0.4 |

---

## License

MIT — free to use, share, and modify. See [LICENSE](LICENSE).
