// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SyntraChatIOS",
    platforms: [
        .iOS("16.0") // Support iOS 16+ for wide compatibility while future-proofing for iOS 26
    ],
    products: [
        .executable(name: "SyntraChatIOS", targets: ["SyntraChatIOS"])
    ],
    dependencies: [
        // Main SyntraFoundation package with all consciousness modules
        .package(name: "SyntraFoundation", path: "../"),
    ],
    targets: [
        .executableTarget(
            name: "SyntraChatIOS",
            dependencies: [
                .product(name: "SyntraTools", package: "SyntraFoundation"),
                .product(name: "SyntraConfig", package: "SyntraFoundation"),
                .product(name: "ConsciousnessStructures", package: "SyntraFoundation")
            ],
            path: ".",
            sources: [
                "SyntraChatIOSApp.swift",
                "ContentView.swift", 
                "ChatView.swift",
                "SettingsView.swift",
                "SyntraBrain.swift",
                "Message.swift",
                "IOSNativeComponents.swift"
            ],
            resources: [
                .process("Info.plist"),
                .process("Assets.xcassets")
            ]
        )
    ]
) 