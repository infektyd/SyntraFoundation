// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "SyntraVaporServer",
    platforms: [
       .macOS(.v26)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 📚 SyntraFoundation library with SyntraKit
        .package(name: "SyntraFoundation", path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "SyntraVaporServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "SyntraKit", package: "SyntraFoundation"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SyntraVaporServerTests",
            dependencies: [
                .target(name: "SyntraVaporServer"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
