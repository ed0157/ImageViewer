<h1 align="center">
  <img src="docs/readme-banner.png" alt="Image Viewer: open one image, explore the folder" width="100%">
</h1>

A small macOS image viewer modeled on Preview. Open one image and step through the rest of its folder with the keyboard.

It reads your images and never changes them. Rotating, for example, only changes what is shown on screen.

## Features

- **Folder browsing.** Open any image and every image in its folder is loaded in Finder's sort order.
- **Keyboard.** ← → ↑ ↓ or Space for next, Shift+Space for previous, Home and End for first and last.
- **Zoom.** Toolbar buttons, ⌘= and ⌘- to zoom, ⌘0 for fit. Scroll when zoomed in.
- **Rotate.** ⌘R rotates clockwise. The file on disk is not modified.
- **Set as Desktop Picture.** From the *Image* menu.
- **Share.** The toolbar share button opens the standard macOS share menu.
- **Info.** ⌘I opens a panel with name, folder, format, pixel size, color model, resolution, camera, file size and modified date.
- **Open.** ⌘O, drag and drop, or double-click an image in Finder once the app is set as the default.
- **No network code.** The app does not talk to the internet. The source is a few short files, so you can check.

Videos are not shown; only formats macOS reports as images appear in the folder. Image decoding is done by macOS itself.

## Install

Requires macOS 14 (Sonoma) or later. Runs on Apple Silicon and Intel.

1. Download the latest `ImageViewer-<version>.dmg` from [Releases](../../releases).
2. Open it and drag **ImageViewer** into **Applications**.
3. Open Image Viewer. macOS will block the first launch, so follow [First launch warning](#first-launch-warning) below.

### First launch warning

Image Viewer is not notarized by Apple, so the first time you open it macOS says *"Apple could not verify ImageViewer is free of malware"*. Click **Done** (not *Move to Trash*), then allow it once:

1. Open **System Settings → Privacy & Security** and scroll down to the Security section.
2. Next to *"ImageViewer" was blocked*, click **Open Anyway** and enter your password.
3. Open Image Viewer again and confirm.

On macOS 14 and earlier, right-clicking the app and choosing **Open** also works.

Only do this for a download from this repository's Releases page. The command below turns off the macOS check for this one app, so run it only after you have verified the download (see next section):

```bash
xattr -dr com.apple.quarantine /Applications/ImageViewer.app
```

This only needs to be done once per install.

### Verify your download

Each release includes a `.sha256` file that lists the `.dmg` and the `.zip`. Put it in the same folder as the file you downloaded and check just that file:

```bash
cd ~/Downloads && grep '\.dmg' ImageViewer-<version>.sha256 | shasum -a 256 -c
```

It should print `OK`. (For the zip, use `grep '\.zip'` instead.) This catches a damaged or incomplete download. It cannot prove who built the file, because the checksum is published next to the download, so only download from this repository.

## Good to know

- **Not sandboxed.** Image Viewer is signed with the hardened runtime but is not an App Sandbox app. It has no network code, but that comes from the source, not from a sandbox.
- **Default app.** The app is registered as an alternate viewer for images. To make it the default, choose *Get Info* on an image in Finder, pick Image Viewer under *Open with*, and click *Change All…*.
- **Large folders** are listed in full when you open an image.
- **Not included yet:** pinch-to-zoom, editing, cropping and printing.

## Why you can trust it, and its limits

- The whole app is a few readable Swift files (`Sources/ImageViewer/`) with no third-party code in it.
- There is no network code. Your images never leave your Mac.
- The release build runs on GitHub from this source. Its GitHub Actions are pinned to exact commits and its one build dependency is pinned with hashes.
- The code is MIT licensed, but it has not had an outside audit.

To report a vulnerability, see [SECURITY.md](SECURITY.md).

## Build from source

You need macOS with the Xcode command line tools (`xcode-select --install`).

```bash
scripts/build.sh              # builds build/ImageViewer.app (universal)
scripts/package.sh            # builds the .dmg, .zip and .sha256 in build/
```

`package.sh` needs `python3` and an internet connection, because it installs the pinned, hash-checked [dmgbuild](https://github.com/dmgbuild/dmgbuild) (and its two dependencies, `ds_store` and `mac_alias`, all MIT licensed) into `build/venv`. These are build tools only and are not shipped in the app.

Set `VERSION=1.2.3` to stamp a version number. Without it the build is labelled `0.0.0-dev`.

```
Sources/ImageViewer/
  ImageViewerApp.swift   app entry point, menu commands, Finder open handling
  ContentView.swift      image canvas, toolbar, status bar, info panel
  ViewerModel.swift      folder listing, navigation, zoom, rotation, file info
Resources/               Info.plist and the app icon
scripts/                 build, package and icon scripts
```

To rebuild the icon from `Resources/AppIcon.png`, run `scripts/make-icon.sh`.

## Releases

GitHub builds the installer and publishes it as a release. Any of these starts it:

- change the number in the `VERSION` file (for example to `1.0.1`) and merge it into `main`;
- open the **Actions** tab, choose **Release**, click **Run workflow**, and type a version such as `1.0.0`; or
- push a tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Only the maintainer can start a release.

Every push and pull request also runs a build (`.github/workflows/ci.yml`) and attaches the installer as a downloadable artifact (not for pull requests from forks).

Releases are ad-hoc signed only. Notarizing them needs a paid Apple Developer account.

## License

The source code and documentation are released under the MIT licence. See [LICENSE](LICENSE).

The app icon and the README banner (`Resources/AppIcon.png`, `Resources/AppIcon.icns` and `docs/readme-banner.png`) are © 2026 ed0157, all rights reserved. They are **not** covered by the MIT licence (see [NOTICE.md](NOTICE.md)). Please do not reuse them without permission.
