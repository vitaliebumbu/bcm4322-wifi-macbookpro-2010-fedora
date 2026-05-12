#!/bin/bash
# Install a systemd service that re-applies the BCM4322 WiFi firmware on every boot.
# Required on Fedora Silverblue because usroverlay changes are lost on reboot.
# Run via: pkexec bash install-permanent.sh
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Please run via: pkexec bash $0"
    exit 1
fi

FIRMWARE_URL="https://web.archive.org/web/20240224140024/http://www.lwfinger.com/b43-firmware/broadcom-wl-6.30.163.46.tar.bz2"
FIRMWARE_OBJ="broadcom-wl-6.30.163.46.wl_apsta.o"

# Download firmware to a persistent location
echo "[1/4] Downloading firmware to /var/lib/b43-firmware..."
mkdir -p /var/lib/b43-firmware
if [ ! -f "/var/lib/b43-firmware/$FIRMWARE_OBJ" ]; then
    curl -L -o "/tmp/broadcom-wl.tar.bz2" "$FIRMWARE_URL"
    tar xjf /tmp/broadcom-wl.tar.bz2 -C /tmp
    cp "/tmp/$FIRMWARE_OBJ" "/var/lib/b43-firmware/"
fi

echo "[2/4] Writing boot service..."
cat > /etc/systemd/system/bcm4322-wifi-firmware.service <<'SERVICE'
[Unit]
Description=BCM4322 WiFi Firmware Loader
After=local-fs.target
Before=NetworkManager.service
DefaultDependencies=no

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c '\
    rpm-ostree usroverlay && \
    b43-fwcutter -w /usr/lib/firmware /var/lib/b43-firmware/broadcom-wl-6.30.163.46.wl_apsta.o && \
    modprobe -r b43 || true && \
    modprobe b43'

[Install]
WantedBy=multi-user.target
SERVICE

echo "[3/4] Enabling service..."
systemctl daemon-reload
systemctl enable bcm4322-wifi-firmware.service

echo "[4/4] Running service now..."
systemctl start bcm4322-wifi-firmware.service

echo ""
echo "Permanent fix installed. WiFi firmware will be loaded on every boot."
ip link show | grep -E "wlan|wlp"
