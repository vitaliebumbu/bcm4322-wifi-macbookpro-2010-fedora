#!/bin/bash
# Fix BCM4322 WiFi on standard Fedora (mutable filesystem)
# Run via: curl -fsSL <url> | sudo bash
set -e

FIRMWARE_URL="https://web.archive.org/web/20240224140024/http://www.lwfinger.com/b43-firmware/broadcom-wl-6.30.163.46.tar.bz2"
FIRMWARE_FILE="/tmp/broadcom-wl-6.30.163.46.tar.bz2"
FIRMWARE_OBJ="broadcom-wl-6.30.163.46.wl_apsta.o"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo bash $0"
    exit 1
fi

echo "[1/4] Installing b43-fwcutter..."
dnf install -y b43-fwcutter

echo "[2/4] Downloading Broadcom firmware..."
if [ ! -f "/tmp/$FIRMWARE_OBJ" ]; then
    curl -L -o "$FIRMWARE_FILE" "$FIRMWARE_URL"
    tar xjf "$FIRMWARE_FILE" -C /tmp
fi

echo "[3/4] Extracting firmware to /usr/lib/firmware..."
mkdir -p /usr/lib/firmware
b43-fwcutter -w /usr/lib/firmware "/tmp/$FIRMWARE_OBJ"

echo "[4/4] Reloading b43 driver..."
modprobe -r b43 2>/dev/null || true
modprobe b43

echo ""
echo "Done! WiFi interface status:"
ip link show | grep -E "wlan|wlp"
nmcli device status 2>/dev/null || true
echo ""
echo "The fix is permanent — firmware survives reboots."
