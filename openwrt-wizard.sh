#!/bin/bash
set -e

WORKDIR=$(pwd)
FILES_DIR="$WORKDIR/uci-defaults"
CONFIG_FILE="$WORKDIR/build-config.json"

mkdir -p "$FILES_DIR"

# --- Dependency check ---
for cmd in dialog jq; do
  command -v $cmd >/dev/null 2>&1 || {
    echo "ERROR: '$cmd' is not installed"
    exit 1
  }
done

HEIGHT=15
WIDTH=70

dialog --clear --title "OpenWrt Firmware Wizard" \
  --msgbox "This wizard will generate:\n\n• UCI default scripts\n• build-config.json\n• Correct OpenWrt structure" \
  $HEIGHT $WIDTH

# --- Builder URL ---
BUILDER_URL=$(dialog --inputbox \
"Image Builder URL:" 10 90 \
"https://downloads.openwrt.org/releases/24.10.5/targets/ramips/mt7620/openwrt-imagebuilder-24.10.5-ramips-mt7620.Linux-x86_64.tar.zst" \
3>&1 1>&2 2>&3)

# --- Profile ---
PROFILE=$(dialog --inputbox \
"Device profile:" 8 50 \
"xiaomi_miwifi-mini" \
3>&1 1>&2 2>&3)

# --- Packages ---
PACKAGES=$(dialog --inputbox \
"Packages (space-separated):" 10 90 \
"luci kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan usb-modeswitch comgt luci-proto-3g" \
3>&1 1>&2 2>&3)

# --- Wi-Fi settings ---
SSID_24=$(dialog --inputbox "2.4 GHz SSID:" 8 40 "OpenWrt_24G" 3>&1 1>&2 2>&3)
SSID_5=$(dialog --inputbox "5 GHz SSID:" 8 40 "OpenWrt_5G" 3>&1 1>&2 2>&3)

WIFI_PASS=$(dialog --inputbox \
"Wi-Fi password (VISIBLE):" 8 40 \
"12345678" \
3>&1 1>&2 2>&3)

# --- Root password ---
ROOT_PASS=$(dialog --inputbox \
"Root password (VISIBLE):" 8 40 \
"root" \
3>&1 1>&2 2>&3)

# --- Confirmation ---
dialog --yesno \
"Confirm configuration:\n\nProfile: $PROFILE\nSSID 2.4G: $SSID_24\nSSID 5G: $SSID_5\n\nGenerate files?" \
15 70

# --- 10-wifi-defaults ---
cat > "$FILES_DIR/10-wifi-defaults" <<EOF
#!/bin/sh

# Enable radios
uci set wireless.radio0.disabled='0'
uci set wireless.radio1.disabled='0'

# 2.4 GHz
uci set wireless.@wifi-iface[0].ssid='$SSID_24'
uci set wireless.@wifi-iface[0].encryption='psk2'
uci set wireless.@wifi-iface[0].key='$WIFI_PASS'

# 5 GHz
uci set wireless.@wifi-iface[1].ssid='$SSID_5'
uci set wireless.@wifi-iface[1].encryption='psk2'
uci set wireless.@wifi-iface[1].key='$WIFI_PASS'

uci commit wireless
wifi reload

exit 0
EOF

# --- 20-root-password ---
cat > "$FILES_DIR/20-root-password" <<EOF
#!/bin/sh

echo -e "$ROOT_PASS\\n$ROOT_PASS" | passwd root

exit 0
EOF

chmod +x "$FILES_DIR/"*

# --- build-config.json ---
cat > "$CONFIG_FILE" <<EOF
{
  "builder_url": "$BUILDER_URL",
  "profile": "$PROFILE",
  "packages": "$PACKAGES"
}
EOF

dialog --msgbox \
"✅ Done!\n\nGenerated:\n• uci-defaults/\n• build-config.json\n\nYou can now run the Docker builder." \
12 70

clear