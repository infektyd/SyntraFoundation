// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SyntraChat",
    platforms: [
        // SwiftUI Chat UI and SyntraConfig require macOS 26.0+ and iOS 26.0+
        .macOS(.v26),
        .iOS(.v26)
    ],
    products: [
        .executable(name: "SyntraChat", targets: ["SyntraChat"])
    ],
    dependencies: [
        // Main SyntraFoundation package
        .package(name: "SyntraFoundation", path: "../"),
    ],
    targets: [
        .executableTarget(
            name: "SyntraChat",
            dependencies: [
                .product(name: "SyntraTools", package: "SyntraFoundation")
            ],
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
