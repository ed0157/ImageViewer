import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject private var model = ViewerModel.shared
    @FocusState private var focused: Bool
    @State private var showInfo = false

    var body: some View {
        VStack(spacing: 0) {
            canvas
            statusBar
        }
        .frame(minWidth: 480, minHeight: 360)
        .inspector(isPresented: $showInfo) {
            InfoPanel(info: model.info)
                .inspectorColumnWidth(min: 220, ideal: 260, max: 360)
        }
        .toolbar { toolbarItems }
        .focusable()
        .focused($focused)
        .focusEffectDisabled()
        .onAppear { focused = true }
        .onKeyPress(keys: [.leftArrow, .upArrow]) { _ in
            model.previous()
            return .handled
        }
        .onKeyPress(keys: [.rightArrow, .downArrow]) { _ in
            model.next()
            return .handled
        }
        .onKeyPress(keys: [.space]) { press in
            press.modifiers.contains(.shift) ? model.previous() : model.next()
            return .handled
        }
        .onKeyPress(keys: [.home]) { _ in
            model.first()
            return .handled
        }
        .onKeyPress(keys: [.end]) { _ in
            model.last()
            return .handled
        }
        .onDrop(of: [.fileURL], isTargeted: nil, perform: handleDrop)
    }

    @ViewBuilder
    private var canvas: some View {
        if let image = model.displayImage {
            GeometryReader { geo in
                let size = CGSize(width: max(image.size.width, 1), height: max(image.size.height, 1))
                let fit = min(1, geo.size.width / size.width, geo.size.height / size.height)
                let scale = fit * model.zoom

                ScrollView([.horizontal, .vertical]) {
                    Image(nsImage: image)
                        .resizable()
                        .interpolation(.high)
                        .frame(width: size.width * scale, height: size.height * scale)
                        .frame(minWidth: geo.size.width, minHeight: geo.size.height)
                }
            }
        } else {
            VStack(spacing: 8) {
                Text("Open an image with ⌘O, or drop one here")
                    .font(.title3)
                Text("Use ← → or Space to move through the folder")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var statusBar: some View {
        HStack {
            if let url = model.currentURL {
                Text("\(model.index + 1) of \(model.files.count)")
                Text(url.lastPathComponent)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            if let size = model.displayImage?.size {
                Text("\(Int(size.width)) × \(Int(size.height))")
            }
            Text(model.zoom == 1 ? "Fit" : "\(Int((model.zoom * 100).rounded()))%")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Button { model.previous() } label: {
                Label("Previous", systemImage: "chevron.left")
            }
            .disabled(model.index == 0)

            Button { model.next() } label: {
                Label("Next", systemImage: "chevron.right")
            }
            .disabled(model.index >= model.files.count - 1)
        }

        ToolbarItemGroup {
            Button { model.zoomOut() } label: {
                Label("Zoom Out", systemImage: "minus.magnifyingglass")
            }
            Button { model.resetZoom() } label: {
                Label("Actual Size", systemImage: "1.magnifyingglass")
            }
            Button { model.zoomIn() } label: {
                Label("Zoom In", systemImage: "plus.magnifyingglass")
            }

            Button { model.rotateClockwise() } label: {
                Label("Rotate", systemImage: "rotate.right")
            }

            if let url = model.currentURL {
                ShareLink(item: url)
            }

            Button { model.setAsWallpaper() } label: {
                Label("Set as Wallpaper", systemImage: "photo.on.rectangle")
            }
            .disabled(model.currentURL == nil)

            Button { showInfo.toggle() } label: {
                Label("Info", systemImage: "info.circle")
            }
            .keyboardShortcut("i")
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        _ = provider.loadObject(ofClass: URL.self) { url, _ in
            guard let url else { return }
            Task { @MainActor in ViewerModel.shared.open(url) }
        }
        return true
    }
}

/// Side panel with the file and image details, like Preview's Inspector.
struct InfoPanel: View {
    let info: ImageInfo?

    var body: some View {
        Form {
            if let info {
                Section {
                    row("Name", info.fileName)
                    row("Folder", info.folder)
                }
                Section {
                    row("Format", info.format)
                    row("Dimensions", dimensions)
                    row("Color model", info.colorModel)
                    row("Resolution", info.dpi.map { "\(Int($0)) dpi" })
                }
                Section {
                    row("Camera", info.camera)
                    row("File size", info.fileSize.map {
                        ByteCountFormatter.string(fromByteCount: $0, countStyle: .file)
                    })
                    row("Modified", info.modified?.formatted(date: .abbreviated, time: .shortened))
                }
            } else {
                Text("No image selected")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private var dimensions: String? {
        guard let width = info?.pixelWidth, let height = info?.pixelHeight else { return nil }
        return "\(width) × \(height) pixels"
    }

    @ViewBuilder
    private func row(_ title: String, _ value: String?) -> some View {
        if let value {
            LabeledContent(title, value: value)
        }
    }
}
