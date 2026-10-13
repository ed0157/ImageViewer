#!/bin/bash
# Builds a universal (Apple Silicon + Intel) build/ImageViewer.app.
# Usage: VERSION=1.0.0 scripts/build.sh
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${VERSION:-0.0.0-dev}"
OUT="build"
APP="$OUT/ImageViewer.app"
CACHE="$OUT/swiftcache"  # inside the build folder, not a shared temp path

rm -rf "$OUT"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$OUT/obj" "$CACHE"

for ARCH in arm64 x86_64; do
    swiftc -O -parse-as-library -swift-version 5 \
        -target "$ARCH-apple-macos14.0" \
        -module-cache-path "$CACHE" \
        Sources/ImageViewer/*.swift \
        -o "$OUT/obj/ImageViewer-$ARCH"
done

lipo -create -output "$APP/Contents/MacOS/ImageViewer" \
    "$OUT/obj/ImageViewer-arm64" "$OUT/obj/ImageViewer-x86_64"

sed "s/__VERSION__/$VERSION/g" Resources/Info.plist > "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

# Ad-hoc signature. Without an Apple Developer ID the app is not notarized (see README).
codesign --force --options runtime --sign - "$APP"
codesign --verify --strict "$APP"

echo "Built $APP ($VERSION)"
lipo -info "$APP/Contents/MacOS/ImageViewer"
