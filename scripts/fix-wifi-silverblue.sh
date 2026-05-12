#!/bin/bash
# Fix BCM4322 WiFi on Fedora Silverblue
# Run via: pkexec bash fix-wifi-silverblue.sh
set -e

FIRMWARE_URL="https://web.archive.org/web/20240224140024/http://www.lwfinger.com/b43-firmware/broadcom-wl-6.30.163.46.tar.bz2"
FIRMWARE_FILE="/tmp/broadcom-wl-6.30.163.46.tar.bz2"
FIRMWARE_OBJ="broadcom-wl-6.30.163.46.wl_apsta.o"

echo "[1/4] Making /usr writable via usroverlay..."
rpm-ostree usroverlay

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
echo ""
nmcli device status 2>/dev/null || true
echo ""
echo "NOTE: This fix is temporary (lost on reboot)."
echo "Run this script again after each reboot, or install the permanent service."
