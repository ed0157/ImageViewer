// Draws the app icon and writes an .iconset folder. Run with:
//   swift scripts/make_icon.swift build/AppIcon.iconset
// then convert it with: iconutil -c icns build/AppIcon.iconset -o Resources/AppIcon.icns
import AppKit

let outputDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "build/AppIcon.iconset"

func draw(size s: CGFloat) {
    // Rounded square inset to match the macOS icon grid.
    let body = CGRect(x: s * 0.1, y: s * 0.1, width: s * 0.8, height: s * 0.8)
    let shape = NSBezierPath(roundedRect: body, xRadius: s * 0.18, yRadius: s * 0.18)
    let gradient = NSGradient(
        starting: NSColor(red: 0.22, green: 0.48, blue: 0.98, alpha: 1),
        ending: NSColor(red: 0.04, green: 0.14, blue: 0.42, alpha: 1)
    )
    gradient?.draw(in: shape, angle: -90)

    // White photo glyph in the middle.
    let config = NSImage.SymbolConfiguration(pointSize: s * 0.42, weight: .medium)
        .applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
    guard let glyph = NSImage(systemSymbolName: "photo.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(config) else { return }
    let g = glyph.size
    glyph.draw(in: CGRect(x: s / 2 - g.width / 2, y: s / 2 - g.height / 2, width: g.width, height: g.height))
}

func png(pixels: Int) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    draw(size: CGFloat(pixels))
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

// iconutil expects these exact file names.
let entries: [(name: String, pixels: Int)] = [
    ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024),
]

try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
for entry in entries {
    try png(pixels: entry.pixels).write(to: URL(fileURLWithPath: outputDir).appendingPathComponent(entry.name))
}
print("Wrote \(entries.count) images to \(outputDir)")
