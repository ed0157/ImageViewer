# Image Viewer

A small macOS image viewer modeled on Preview. Open one image and step through the rest of its folder with the keyboard.

## Requirements

- macOS 14 (Sonoma) or newer
- Xcode command line tools (for building)

## Install

```bash
./scripts/bundle.sh
cp -R build/ImageViewer.app /Applications/
```

The script builds a release binary, packages it as `build/ImageViewer.app`, and signs it ad hoc.

## Features

- **Folder browsing:** open any image and every image in its folder is loaded in Finder's sort order.
- **Keyboard:** ← → ↑ ↓ or Space for next, Shift+Space for previous, Home and End for first and last.
- **Zoom:** toolbar buttons, ⌘= / ⌘- to zoom, ⌘0 for fit. Scroll when zoomed in.
- **Rotate:** ⌘R rotates clockwise. The display changes only; the file on disk is not modified.
- **Share:** toolbar share button opens the standard macOS share menu.
- **Info:** ⌘I opens a panel with name, folder, format, pixel size, color model, resolution, camera, file size and modified date.
- **Open:** ⌘O, drag and drop, or double-click an image in Finder once the app is set as the default.

Videos are not shown; only formats macOS reports as images appear in the folder.

## Project layout

```
Package.swift                     Swift package manifest
Sources/ImageViewer/
  ImageViewerApp.swift            app entry point, menu commands, Finder open handling
  ContentView.swift               image canvas, toolbar, status bar, info panel
  ViewerModel.swift               folder listing, navigation, zoom, rotation, file info
Resources/
  Info.plist                      bundle metadata and document types
  AppIcon.icns                    app icon
scripts/
  bundle.sh                       build and package the .app
  make_icon.swift                 regenerate the app icon
```

## Regenerate the icon

```bash
swift scripts/make_icon.swift build/AppIcon.iconset
iconutil -c icns build/AppIcon.iconset -o Resources/AppIcon.icns
```

## Known limits

- No pinch-to-zoom gesture yet.
- No editing, cropping or printing.
- Large folders are listed in full when you open an image.
