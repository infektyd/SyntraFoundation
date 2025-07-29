// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SyntraFoundation",
    platforms: [
        .macOS(.v26),
        .iOS(.v26)
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