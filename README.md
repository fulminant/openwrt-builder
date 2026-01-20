# OpenWrt Custom Firmware Builder (Docker + Wizard)

This project helps you build a **custom OpenWrt firmware** using the official **OpenWrt Image Builder**, with:

- Wi-Fi enabled by default (2.4 GHz + 5 GHz)
- Predefined Wi-Fi SSID & password
- Predefined root password
- Additional packages preinstalled
- Fully automated Docker build
- Interactive terminal wizard (buttons, menus)

Works on **Linux, macOS, Windows**.

---

## Requirements

- Docker
- Docker Compose
- `dialog` and `jq` (only for running the wizard)

### Install wizard dependencies

**Ubuntu / Debian**
```bash
sudo apt install dialog jq
```

**macOS**
```bash
brew install dialog jq
```

---

## Quick Start

### 1. Run the configuration wizard

```bash
./openwrt-wizard.sh
```

The wizard will:
- Ask for device profile
- Ask for Image Builder URL
- Ask for Wi-Fi SSIDs and password
- Ask for root password
- Generate all required files automatically

Generated files:
```
files/etc/uci-defaults/
  ├── 10-wifi-defaults
  └── 20-root-password
build-config.json
```

---

### 2. Build firmware using Docker

```bash
docker-compose build
docker-compose run --rm builder
```

---

### 3. Get the firmware

After the build finishes, firmware images will be available in:

```
./output/
```

These files are ready to be flashed to your router.

---

## What gets configured automatically

### Wi-Fi
- Both radios enabled
- 2.4 GHz and 5 GHz SSIDs
- WPA2-PSK encryption
- Wi-Fi active after factory reset

### Root access
- Root password set on first boot

### Packages
Configured via `build-config.json`, for example:
```
luci
kmod-usb-serial
kmod-usb-serial-option
kmod-usb-serial-wwan
usb-modeswitch
comgt
luci-proto-3g
```

---

## Device example

Tested with:
- **Xiaomi MiWiFi Mini**
- Target: `ramips/mt7620`

---

## Notes

- All custom settings are applied using `/etc/uci-defaults`
- Scripts run **once on first boot**, even after hard reset
- Passwords are visible during wizard input (by design)
- Build runs in a case-sensitive filesystem inside Docker

---

## Roadmap

Planned improvements:
- Image size safety checks (16 MB flash devices)
- Modem (3G/4G) configuration wizard
- Package selection with checkboxes

---

## License

MIT
