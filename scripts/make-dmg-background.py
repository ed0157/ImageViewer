#!/usr/bin/env python3
"""Draws the installer window background (Resources/dmg-background.tiff).

Needs Pillow (`pip install pillow`) and macOS `tiffutil`. The result is committed, so this only
needs re-running when the design changes. The window is 660x430 points; a 2x copy is drawn too.
"""
import os
import subprocess
import tempfile

from PIL import Image, ImageDraw, ImageFont

W, H = 660, 430
APP_X, APPS_X, ICON_Y = 170, 490, 190  # icon centres in points (must match dmg-settings.py)

TOP, BOTTOM = (237, 231, 255), (214, 204, 252)
NAVY, PURPLE, CORAL, CYAN = (30, 20, 80), (110, 80, 220), (240, 120, 100), (90, 210, 240)


def font(size, bold=False):
    paths = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for path in paths:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def draw(scale):
    w, h = W * scale, H * scale
    img = Image.new("RGB", (w, h))
    px = ImageDraw.Draw(img)
    for y in range(h):
        t = y / (h - 1)
        px.line([(0, y), (w, y)], fill=tuple(int(TOP[i] + (BOTTOM[i] - TOP[i]) * t) for i in range(3)))

    # Soft corner stripes echoing the README banner.
    px.polygon([(0, 0), (150 * scale, 0), (0, 150 * scale)], fill=(200, 188, 250))
    px.line([(w - 90 * scale, h), (w, h - 90 * scale)], fill=CYAN, width=8 * scale)
    px.line([(w - 130 * scale, h), (w, h - 130 * scale)], fill=CORAL, width=5 * scale)

    title = "Install ImageViewer"
    px.text((w / 2, 52 * scale), title, font=font(30 * scale, True), fill=NAVY, anchor="mm")

    # Arrow from the app icon to the Applications shortcut.
    y = ICON_Y * scale
    x0, x1 = (APP_X + 78) * scale, (APPS_X - 78) * scale
    px.line([(x0, y), (x1 - 14 * scale, y)], fill=PURPLE, width=7 * scale)
    px.polygon(
        [(x1, y), (x1 - 26 * scale, y - 18 * scale), (x1 - 26 * scale, y + 18 * scale)], fill=PURPLE
    )

    px.text((w / 2, 318 * scale), "Drag ImageViewer into Applications", font=font(18 * scale, True), fill=NAVY, anchor="mm")
    px.text(
        (w / 2, 352 * scale),
        "If macOS blocks it: System Settings > Privacy & Security > Open Anyway",
        font=font(12 * scale),
        fill=(70, 55, 140),
        anchor="mm",
    )
    return img


def main():
    out = os.path.join(os.path.dirname(__file__), "..", "Resources", "dmg-background.tiff")
    with tempfile.TemporaryDirectory() as tmp:
        one, two = os.path.join(tmp, "bg.png"), os.path.join(tmp, "bg@2x.png")
        draw(1).save(one, dpi=(72, 72))
        draw(2).save(two, dpi=(144, 144))
        subprocess.run(["tiffutil", "-cathidpicheck", one, two, "-out", out], check=True)
    print("Created", os.path.normpath(out))


if __name__ == "__main__":
    main()
