import AppKit
import ImageIO
import UniformTypeIdentifiers

/// File and image details shown in the info panel.
struct ImageInfo {
    var fileName = ""
    var folder = ""
    var fileSize: Int64?
    var modified: Date?
    var format: String?
    var pixelWidth: Int?
    var pixelHeight: Int?
    var colorModel: String?
    var dpi: Double?
    var camera: String?

    init(url: URL) {
        fileName = url.lastPathComponent
        folder = url.deletingLastPathComponent().path

        let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
        fileSize = values?.fileSize.map { Int64($0) }
        modified = values?.contentModificationDate

        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return }
        if let type = CGImageSourceGetType(source) as String?, let utType = UTType(type) {
            format = utType.localizedDescription
        }
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] ?? [:]
        pixelWidth = properties[kCGImagePropertyPixelWidth] as? Int
        pixelHeight = properties[kCGImagePropertyPixelHeight] as? Int
        colorModel = properties[kCGImagePropertyColorModel] as? String
        dpi = properties[kCGImagePropertyDPIWidth] as? Double
        let tiff = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any]
        camera = tiff?[kCGImagePropertyTIFFModel] as? String
    }
}

/// Holds the folder of images around the opened file and the state of the one on screen.
@MainActor
final class ViewerModel: ObservableObject {
    static let shared = ViewerModel()

    @Published private(set) var files: [URL] = []
    @Published private(set) var index = 0
    @Published private(set) var displayImage: NSImage?
    /// Clockwise quarter turns applied to the current image.
    @Published private(set) var rotation = 0
    /// Multiplier on top of fit-to-window. 1 means fit.
    @Published private(set) var zoom: CGFloat = 1
    @Published private(set) var info: ImageInfo?

    private var sourceImage: NSImage?

    var currentURL: URL? {
        files.indices.contains(index) ? files[index] : nil
    }

    // MARK: - Opening

    func open(_ url: URL) {
        let target = url.standardizedFileURL
        let folder = target.deletingLastPathComponent()
        let siblings = (try? FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.contentTypeKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        files = siblings
            .map { $0.standardizedFileURL }
            .filter(Self.isImage)
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }

        if !files.contains(target) {
            files = [target]
        }
        index = files.firstIndex(of: target) ?? 0
        zoom = 1
        load()
    }

    func chooseFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            open(url)
        }
    }

    // MARK: - Navigation

    func next() { goTo(index + 1) }
    func previous() { goTo(index - 1) }
    func first() { goTo(0) }
    func last() { goTo(files.count - 1) }

    private func goTo(_ newIndex: Int) {
        guard files.indices.contains(newIndex), newIndex != index else { return }
        index = newIndex
        zoom = 1
        load()
    }

    // MARK: - Zoom and rotation

    func zoomIn() { zoom = min(zoom * 1.25, 8) }
    func zoomOut() { zoom = max(zoom / 1.25, 0.1) }
    func resetZoom() { zoom = 1 }

    func rotateClockwise() {
        rotation = (rotation + 1) % 4
        updateDisplay()
    }

    // MARK: - Private

    private func load() {
        rotation = 0
        guard let url = currentURL else {
            sourceImage = nil
            displayImage = nil
            info = nil
            return
        }
        sourceImage = NSImage(contentsOf: url)
        info = ImageInfo(url: url)
        updateDisplay()
    }

    private func updateDisplay() {
        displayImage = sourceImage.map { Self.rotate($0, quarterTurns: rotation) }
    }

    private static func isImage(_ url: URL) -> Bool {
        let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType
        return type?.conforms(to: .image) ?? false
    }

    private static func rotate(_ image: NSImage, quarterTurns: Int) -> NSImage {
        guard quarterTurns != 0 else { return image }
        let size = image.size
        let swapped = quarterTurns % 2 == 1
        let newSize = swapped ? NSSize(width: size.height, height: size.width) : size

        return NSImage(size: newSize, flipped: false) { rect in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            context.translateBy(x: rect.midX, y: rect.midY)
            // Negative angle is clockwise in an unflipped coordinate system.
            context.rotate(by: -CGFloat(quarterTurns) * .pi / 2)
            image.draw(in: CGRect(x: -size.width / 2, y: -size.height / 2,
                                  width: size.width, height: size.height))
            return true
        }
    }
}
