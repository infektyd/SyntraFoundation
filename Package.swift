// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SyntraFoundation",
    platforms: [
        .iOS(.v17),        // Modern syntax - NOT .v17 vs "17.0"
        .macOS(.v14)       // Required for FoundationModels
    ],
    products: [
        .executable(name: "SyntraSwiftCLI", targets: ["SyntraSwiftCLI"]),
        .library(name: "SyntraSwift", targets: ["SyntraSwift"])
    ],
    targets: [
        .target(
            name: "SyntraSwift",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency"),
                .unsafeFlags([
                    "-Xfrontend", "-warn-concurrency"
                ])
            ]
        ),
        .executableTarget(
            name: "SyntraSwiftCLI",
            dependencies: ["SyntraSwift"],
            path: "swift/Main",  // CLAUDE.md: Isolate to Main directory
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SyntraSwiftTests",
            dependencies: ["SyntraSwift"]
        )
    ]
)
