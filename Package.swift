 // swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "SyntraFoundation",
    platforms: [
        .macOS(.v26),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SyntraFoundation",
            targets: [
                "Valon", "Modi", "Drift", "MemoryEngine", "ConsciousnessStructures",
                "BrainEngine", "ConversationalInterface", "StructuredConsciousnessService",
                "MoralDriftMonitoring", "SyntraConfig", "MoralCore", "SyntraTools",
                "SyntraCore", "CognitiveDrift", "ConflictResolver"
            ]
        ),
        .library(name: "SyntraSwift", targets: ["SyntraSwift"]),
        .executable(name: "SyntraSwiftCLI", targets: ["SyntraSwiftCLI"]),
        .executable(name: "syntra-api-server", targets: ["SyntraAPILayer"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.3")
    ],
    targets: [
        // Core Consciousness Modules
        .target(name: "Valon", dependencies: ["ConsciousnessStructures"], path: "Shared/Swift/Valon"),
        .target(name: "Modi", 
            dependencies: [
                "ConsciousnessStructures",
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Numerics", package: "swift-numerics")
            ],
            path: "Shared/Swift/Modi"),
        .target(name: "Drift", path: "Shared/Swift/Drift"),
        .target(name: "MemoryEngine", 
            dependencies: [
                "Valon",
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Atomics", package: "swift-atomics")
            ],
            path: "Shared/Swift/MemoryEngine"),
        .target(name: "ConsciousnessStructures", path: "Shared/Swift/ConsciousnessStructures"),
        .target(name: "BrainEngine", dependencies: ["Valon", "Modi", "Drift", "ConsciousnessStructures", "SyntraConfig", "SyntraTools"], path: "Shared/Swift/BrainEngine"),
        .target(name: "SyntraCore", dependencies: ["Valon", "Modi"], path: "Shared/Swift/SyntraCore"),
        .target(name: "ConversationalInterface", dependencies: ["BrainEngine", "MoralDriftMonitoring", "MemoryEngine", "ConsciousnessStructures", "SyntraTools"], path: "Shared/Swift/ConversationalInterface"),
        .target(name: "MoralDriftMonitoring", dependencies: ["ConsciousnessStructures"], path: "Shared/Swift/MoralDriftMonitoring"),
        .target(name: "StructuredConsciousnessService", dependencies: ["ConsciousnessStructures", "MoralDriftMonitoring"], path: "Shared/Swift/StructuredConsciousnessService"),
        .target(name: "SyntraConfig", dependencies: [], path: "Shared/Swift/SyntraConfig"),
        .target(name: "MoralCore", dependencies: ["ConsciousnessStructures"], path: "Shared/Swift/MoralCore"),
        .target(name: "SyntraTools", 
            dependencies: [
                "SyntraCore",
                "ConsciousnessStructures", 
                "MoralCore", 
                "StructuredConsciousnessService", 
                "MoralDriftMonitoring", 
                "Valon", 
                "Modi", 
                "Drift", 
                "MemoryEngine", 
                "SyntraConfig",
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "Numerics", package: "swift-numerics")
            ], 
            path: "Shared/Swift/SyntraTools"),
        .target(name: "CognitiveDrift", dependencies: ["SyntraConfig", "Valon", "Modi", "Drift", "MemoryEngine", "ConsciousnessStructures", "ConflictResolver"], path: "Shared/Swift/CognitiveDrift"),
        .target(name: "ConflictResolver", dependencies: ["ConsciousnessStructures"], path: "Shared/Swift/ConflictResolver"),
        
        // SyntraSwift with added dependencies
        .target(
            name: "SyntraSwift",
            dependencies: [
                "SyntraCore",
                "SyntraTools",
                "BrainEngine",
                "ConversationalInterface",
                "ConsciousnessStructures",
                "MemoryEngine"
            ],
            path: "Shared/Sources/SyntraSwift"
        ),

        // Executable CLI Target
        .executableTarget(
            name: "SyntraSwiftCLI",
            dependencies: ["SyntraCore", "ConversationalInterface", "SyntraTools"],
            path: "SyntraSwiftCLI"
        ),

        // External API Layer (macOS-only)
        .target(
            name: "SyntraWrappers",
            dependencies: [
                "SyntraTools",
                "Modi",
                .product(name: "Atomics", package: "swift-atomics")
            ],
            path: "Wrappers"
        ),
        .executableTarget(
            name: "SyntraAPILayer",
            dependencies: ["SyntraWrappers", "SyntraTools"],
            path: "APIs"
        ),
        // Test Target
        .testTarget(
            name: "SyntraFoundationTests",
            dependencies: [
                "SyntraCore", 
                "SyntraTools",
                "MemoryEngine",
                "ConsciousnessStructures",
                .product(name: "Atomics", package: "swift-atomics")
            ],
            path: "Tests/SyntraFoundationTests"
        )
    ]
)
