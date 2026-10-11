// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ImageViewer",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ImageViewer",
            path: "Sources/ImageViewer"
        )
    ]
)
