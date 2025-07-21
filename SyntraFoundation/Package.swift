// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SyntraFoundation",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
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