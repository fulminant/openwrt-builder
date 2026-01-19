#!/bin/bash
set -e

CONFIG_FILE=${CONFIG_FILE:-/config/build-config.json}
HOST_OUTPUT=${HOST_OUTPUT:-/host-output}  # optional host folder

# Validate config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Config file $CONFIG_FILE not found"
    exit 1
fi

# Parse JSON config
BUILDER_URL=$(jq -r '.builder_url' "$CONFIG_FILE")
PROFILE=$(jq -r '.profile' "$CONFIG_FILE")
PACKAGES=$(jq -r '.packages' "$CONFIG_FILE")

# Validate mandatory fields
if [[ -z "$BUILDER_URL" || -z "$PROFILE" || -z "$PACKAGES" ]]; then
    echo "ERROR: builder_url, profile, and packages must be provided in build-config.json"
    exit 1
fi

# Validate uci-defaults directory
if [[ ! -d /uci-defaults ]]; then
    echo "ERROR: /uci-defaults directory must be mounted with user default configs"
    exit 1
fi

echo "Starting OpenWrt build..."
echo "Builder URL: $BUILDER_URL"
echo "Profile: $PROFILE"
echo "Packages: $PACKAGES"

# Download Image Builder
FILENAME=$(basename "$BUILDER_URL")
wget -q "$BUILDER_URL" -O "$FILENAME"

# Detect file extension and extract
case "$FILENAME" in
    *.tar.xz)
        tar -xf "$FILENAME"
        ;;
    *.tar.zst)
        tar -I zstd -xf "$FILENAME"
        ;;
    *)
        echo "ERROR: Unsupported file extension for $FILENAME"
        exit 1
        ;;
esac

# Enter extracted folder
DIRNAME=$(tar -tf "$FILENAME" | head -1 | cut -f1 -d"/")
cd "$DIRNAME"

# Copy user-provided defaults
mkdir -p files/etc/uci-defaults

if [[ -d /uci-defaults ]]; then
    echo "Copying user scripts into files/etc/uci-defaults..."
    cp -a /uci-defaults/* files/etc/uci-defaults/
else
    echo "WARNING: /uci-defaults directory not found, skipping custom files copy"
fi

# Build firmware
make image PROFILE="$PROFILE" PACKAGES="$PACKAGES" FILES=files/

# Copy firmware to Docker volume
cp -r bin/targets/* /output/
echo "Firmware copied to /output (Docker volume)"

# Copy firmware to host folder if mounted
if [[ -d "$HOST_OUTPUT" ]]; then
    cp -r /output/* "$HOST_OUTPUT/"
    echo "Firmware copied to host folder $HOST_OUTPUT"
fi