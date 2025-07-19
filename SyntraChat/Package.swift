// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SyntraChat",
    platforms: [
        .macOS(.v15) // CRITICAL: SystemLanguageModel requires macOS 15+
    ],
    products: [
        .executable(name: "SyntraChat", targets: ["SyntraChat"])
    ],
    targets: [
        .executableTarget(
            name: "SyntraChat",
            path: ".",
            sources: [
                "SyntraChatApp.swift",
                "ContentView.swift", 
                "SyntraBrain.swift",
                "Message.swift"
            ]
        )
    ]
)