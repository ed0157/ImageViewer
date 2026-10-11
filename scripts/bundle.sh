#!/bin/bash
# Builds the viewer and packages it as build/ImageViewer.app
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release

APP="build/ImageViewer.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp ".build/release/ImageViewer" "$APP/Contents/MacOS/ImageViewer"
cp "Resources/Info.plist" "$APP/Contents/Info.plist"
cp "Resources/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
codesign --force --sign - "$APP"

echo "Built $APP"
