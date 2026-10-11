import AppKit
import SwiftUI

@main
struct ImageViewerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Window("Image Viewer", id: "main") {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open…") { ViewerModel.shared.chooseFile() }
                    .keyboardShortcut("o")
            }
            CommandMenu("Image") {
                Button("Rotate Clockwise") { ViewerModel.shared.rotateClockwise() }
                    .keyboardShortcut("r")
                Button("Set as Desktop Picture") { ViewerModel.shared.setAsWallpaper() }
                Divider()
                Button("Zoom In") { ViewerModel.shared.zoomIn() }
                    .keyboardShortcut("=")
                Button("Zoom Out") { ViewerModel.shared.zoomOut() }
                    .keyboardShortcut("-")
                Button("Actual Size / Fit") { ViewerModel.shared.resetZoom() }
                    .keyboardShortcut("0")
            }
        }
    }
}

/// Receives files opened from Finder (double-click or "Open With").
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        Task { @MainActor in ViewerModel.shared.open(url) }
    }
}
