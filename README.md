# WiFi Fix on MacBook Pro 2010 on Fedora Linux

**No WiFi showing up after installing Fedora on your MacBook Pro 2010? This guide will fix it in a few minutes.**

Tested on: MacBook Pro 13" Mid-2010 running Fedora Silverblue 44.  
Also works on: Fedora Workstation and most other Fedora-based systems.

---

## Is this guide for you?

You are in the right place if:

- You installed **Fedora Linux** on a **MacBook Pro 2010** (or similar Mac)
- There is **no WiFi option** anywhere — not in the top bar, not in Settings
- You are connected to internet only via an ethernet cable (or not at all)

The cause is simple: Fedora does not include the WiFi driver files for this MacBook out of the box. This guide installs them.

---

## Before you start

You will need:
- A working internet connection (plug in an ethernet cable if you have one)
- Your computer's login password

---

## Which version of Fedora do you have?

Not sure? Open the **Terminal** app and paste this:

```
cat /etc/os-release | grep VARIANT
```

- If it says `Silverblue` → follow **Option A** below
- If it says `Workstation` → follow **Option B** below

---

## Option A — Fedora Silverblue

Open the **Terminal** app and run the following commands **one at a time**.  
Copy each line, paste it into the terminal, and press **Enter**. Wait for it to finish before moving to the next.

**Step 1 — Enable extra software sources**

```
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

This may take a minute. When it says `Changes queued for next boot`, continue.

**Step 2 — Download and run the fix**

```
curl -fsSL https://raw.githubusercontent.com/vitaliebumbu/bcm4322-wifi-macbookpro-2010-fedora/main/scripts/fix-wifi-silverblue.sh -o /tmp/fix-wifi.sh
```

```
pkexec bash /tmp/fix-wifi.sh
```

> A **password dialog will pop up on your screen** — enter your login password and click OK.

**Step 3 — Check WiFi is working**

After the script finishes, look at the top-right corner of your screen. The WiFi icon should now appear. Click it and connect to your network!

> ⚠️ **Important:** This fix is temporary. If you restart your computer, you will need to run Step 2 again. For a permanent fix, see the section below.

---

## Option B — Fedora Workstation

Open the **Terminal** app and run the following commands **one at a time**.

**Step 1 — Enable extra software sources**

```
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

Type your password when asked and press Enter.

**Step 2 — Install the WiFi tool**

```
sudo dnf install b43-fwcutter
```

**Step 3 — Run the fix**

```
curl -fsSL https://raw.githubusercontent.com/vitaliebumbu/bcm4322-wifi-macbookpro-2010-fedora/main/scripts/fix-wifi-workstation.sh | sudo bash
```

**Step 4 — Check WiFi is working**

Look at the top-right corner of your screen. The WiFi icon should appear. Click it and connect!

> This fix is **permanent** — WiFi will keep working after restarts.

---

## Make the fix permanent on Silverblue

If you are on Fedora Silverblue and you do not want to repeat Step 2 after every restart, run this once:

```
curl -fsSL https://raw.githubusercontent.com/vitaliebumbu/bcm4322-wifi-macbookpro-2010-fedora/main/scripts/install-permanent.sh -o /tmp/install-permanent.sh
pkexec bash /tmp/install-permanent.sh
```

A password dialog will appear — enter your password. After this, WiFi will load automatically on every boot.

---

## Something went wrong?

**WiFi icon still not showing after the script finished:**
- Open Terminal and run: `nmcli device wifi list`
- If you see a list of networks, WiFi is working — just click the icon in the top bar

**"Command not found" error:**
- Make sure you copied the full command including all parts
- Try closing and reopening the Terminal, then run the command again

**Script failed with a download error:**
- Check that your ethernet cable is plugged in and you have internet access
- Try running the same command again

**Still stuck?** Open an [issue on this page](../../issues) and describe what happened. Include what the terminal printed.

---

## About this fix

The MacBook Pro 2010 uses a **Broadcom BCM4322** WiFi chip. Fedora includes the driver for this chip (`b43`) but not the firmware files it needs to operate — because those files have a proprietary license. This fix downloads and installs those firmware files so the driver can work.

| | |
|---|---|
| Machine | MacBook Pro 13" Mid-2010 (MacBookPro7,1) |
| WiFi chip | Broadcom BCM4322 |
| Fedora version tested | Fedora Silverblue 44 |

---

## License

MIT — free to use, share, and modify. See [LICENSE](LICENSE).
