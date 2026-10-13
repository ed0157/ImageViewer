#!/bin/bash
# Rebuilds Resources/AppIcon.icns from Resources/AppIcon.png (a 1024x1024 image).
# Usage: scripts/make-icon.sh
set -euo pipefail

cd "$(dirname "$0")/.."

SET="build/AppIcon.iconset"
rm -rf "$SET"
mkdir -p "$SET"

for SIZE in 16 32 128 256 512; do
    sips -z "$SIZE" "$SIZE" Resources/AppIcon.png --out "$SET/icon_${SIZE}x${SIZE}.png" >/dev/null
    sips -z "$((SIZE * 2))" "$((SIZE * 2))" Resources/AppIcon.png --out "$SET/icon_${SIZE}x${SIZE}@2x.png" >/dev/null
done

iconutil -c icns "$SET" -o Resources/AppIcon.icns
rm -rf "$SET"
echo "Wrote Resources/AppIcon.icns"
