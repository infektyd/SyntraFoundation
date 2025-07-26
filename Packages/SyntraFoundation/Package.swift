// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SyntraFoundation",
    platforms: [
        .macOS("26.0"),
        .iOS("26.0")
    ],
    products: [
        .library(name: "SyntraFoundation", targets: ["SyntraCore"])
    ],
    targets: [
        .target(
            name: "SyntraCore",
            path: "Sources/SyntraCore"
        ),
        .testTarget(
            name: "SyntraFoundationTests", 
            dependencies: ["SyntraCore"],
            path: "Tests"
        )
    ]
) 