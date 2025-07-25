// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SyntraFoundation",
    platforms: [
        .macOS(.v15),
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SyntraFoundation",
            targets: ["SyntraFoundation"]),
        .executable(
            name: "SyntraSwift", 
            targets: ["SyntraSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-foundation", branch: "main"),
        // WebAssembly host runtime support
        .package(url: "https://github.com/swiftwasm/WasmKit.git", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SyntraFoundation",
            dependencies: [
                .product(name: "FoundationEssentials", package: "swift-foundation"),
                "WasmKit",
            ],
            path: "SyntraFoundation/Sources"),
        .executableTarget(
            name: "SyntraSwift",
            dependencies: [
                "SyntraFoundation",
                .product(name: "FoundationEssentials", package: "swift-foundation"),
                "WasmKit",
            ],
            path: "swift/Main"),
        .testTarget(
            name: "SyntraFoundationTests",
            dependencies: ["SyntraFoundation"],
            path: "SyntraFoundation/Tests"),
    ]
)
