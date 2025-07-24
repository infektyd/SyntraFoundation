// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SyntraCLITest",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        .executable(name: "syntra-cli", targets: ["SyntraCLIExecutable"]),
        .library(name: "SyntraCLILib", targets: ["SyntraCLILib"]),
    ],
    dependencies: [
        // Foundation Models for Apple's on-device LLM
    ],
    targets: [
        // Library target containing all the core logic (testable)
        .target(
            name: "SyntraCLILib",
            dependencies: [],
            path: "Sources/SyntraCLILib",
            swiftSettings: [
                .enableUpcomingFeature("FoundationModels")
            ]
        ),
        // Executable target with minimal main.swift (calls library)
        .executableTarget(
            name: "SyntraCLIExecutable",
            dependencies: ["SyntraCLILib"],
            path: "Sources/SyntraCLIExecutable"
        ),
        // Test target testing the library
        .testTarget(
            name: "SyntraCLITestTests",
            dependencies: ["SyntraCLILib"],
            path: "Tests"
        ),
    ]
) 