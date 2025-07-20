// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SyntraChat",
    platforms: [
        // SwiftUI Chat UI and SyntraConfig require macOS 26.0+
        .macOS("26.0")
    ],
    products: [
        .executable(name: "SyntraChat", targets: ["SyntraChat"])
    ],
    dependencies: [
        // Local config package for runtime toggles
        .package(path: "../swift/SyntraConfig"),
    ],
    targets: [
        .executableTarget(
            name: "SyntraChat",
            dependencies: ["SyntraConfig"],
            path: ".",
            sources: [
                "SyntraChatApp.swift",
                "ContentView.swift",
                "SettingsPanel.swift",
                "SyntraBrain.swift",
                "Message.swift",
            ]
        )
    ]
)
