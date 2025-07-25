// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SyntraCoreWasm",
    platforms: [
        .macOS("26.0"),
        .iOS("26.0"),
    ],
    products: [
        .executable(name: "SyntraCoreWasm", targets: ["SyntraCoreWasm"]),
        .library(name: "SyntraWasmLib", targets: ["SyntraWasmLib"]),
    ],
    dependencies: [
        // Add minimal dependencies suitable for WebAssembly
        .package(url: "https://github.com/swiftwasm/WasmKit.git", from: "0.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "SyntraCoreWasm",
            dependencies: ["SyntraWasmLib"],
            swiftSettings: [
                .define("WASM_TARGET"),
                .unsafeFlags(["-Xfrontend", "-function-sections"]),
            ]
        ),
        .target(
            name: "SyntraWasmLib",
            dependencies: [],
            swiftSettings: [
                .define("WASM_TARGET"),
                .unsafeFlags(["-Xfrontend", "-function-sections"]),
            ]
        ),
        .testTarget(
            name: "SyntraWasmTests",
            dependencies: ["SyntraWasmLib"]
        ),
    ]
) 