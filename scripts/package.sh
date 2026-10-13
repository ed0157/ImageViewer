#!/bin/bash
# Packages build/ImageViewer.app into a DMG installer and a zip, plus SHA-256 checksums.
# Run scripts/build.sh first. Usage: VERSION=1.0.0 scripts/package.sh
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${VERSION:-0.0.0-dev}"
OUT="build"
APP="$OUT/ImageViewer.app"
DMG="$OUT/ImageViewer-$VERSION.dmg"
ZIP="$OUT/ImageViewer-$VERSION.zip"
VENV="$OUT/venv"

[ -d "$APP" ] || { echo "Missing $APP. Run scripts/build.sh first." >&2; exit 1; }

# dmgbuild lays out the installer window (background, icon positions) without needing Finder.
# It is installed from a pinned, hash-checked list, as wheels only, so a changed or
# malicious package on PyPI cannot slip into the installer.
rm -rf "$VENV"
python3 -m venv "$VENV"
"$VENV/bin/pip" install --quiet --require-hashes --only-binary=:all: --no-deps \
    -r scripts/requirements-dmg.txt

rm -f "$DMG"
"$VENV/bin/dmgbuild" -s scripts/dmg-settings.py -D app="$APP" "ImageViewer" "$DMG"

ditto -c -k --keepParent "$APP" "$ZIP"

(cd "$OUT" && shasum -a 256 "ImageViewer-$VERSION.dmg" "ImageViewer-$VERSION.zip" > "ImageViewer-$VERSION.sha256")

echo "Created:"
ls -lh "$DMG" "$ZIP" "$OUT/ImageViewer-$VERSION.sha256"
