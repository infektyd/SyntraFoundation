// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "SyntraFoundation",
    platforms: [
        .macOS(.v26),
        .iOS(.v26)
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
        .executable(name: "syntra-api-server", targets: ["SyntraAPILayer"]),
    ],
    targets: [
        // MARK: - Core Consciousness Modules
        .target(name: "Valon", dependencies: ["ConsciousnessStructures"], path: "Shared/Swift/Valon"),
        .target(name: "Modi", dependencies: ["ConsciousnessStructures"], path: "Shared/Swift/Modi"),
        .target(name: "Drift", path: "Shared/Swift/Drift"),
        .target(name: "MemoryEngine", dependencies: ["Valon", "Modi", "Drift"], path: "Shared/Swift/MemoryEngine"),
        .target(name: "ConsciousnessStructures", path: "Shared/Swift/ConsciousnessStructures"),
        .target(name: "BrainEngine", dependencies: ["Valon", "Modi", "Drift", "ConsciousnessStructures", "SyntraConfig", "SyntraTools"], path: "Shared/Swift/BrainEngine"),
        .target(name: "SyntraCore", dependencies: ["Valon", "Modi", "BrainEngine"], path: "Shared/Swift/SyntraCore"),
        .target(name: "ConversationalInterface", dependencies: ["BrainEngine", "MoralDriftMonitoring", "MemoryEngine", "ConsciousnessStructures", "SyntraTools"], path: "Shared/Swift/ConversationalInterface"),
        .target(name: "MoralDriftMonitoring", dependencies: ["ConsciousnessStructures"], path: "Shared/Swift/MoralDriftMonitoring"),
        .target(name: "StructuredConsciousnessService", dependencies: ["ConsciousnessStructures", "MoralDriftMonitoring"], path: "Shared/Swift/StructuredConsciousnessService"),
        .target(name: "SyntraConfig", dependencies: [], path: "Shared/Swift/SyntraConfig"),
        .target(name: "MoralCore", dependencies: ["ConsciousnessStructures"], path: "Shared/Swift/MoralCore"),
        .target(name: "SyntraTools", dependencies: ["ConsciousnessStructures", "MoralCore", "StructuredConsciousnessService", "MoralDriftMonitoring", "Valon", "Modi", "Drift", "MemoryEngine", "SyntraConfig"], path: "Shared/Swift/SyntraTools"),
        .target(name: "CognitiveDrift", dependencies: ["SyntraConfig", "Valon", "Modi", "Drift", "MemoryEngine", "ConsciousnessStructures", "ConflictResolver"], path: "Shared/Swift/CognitiveDrift"),
        .target(name: "ConflictResolver", dependencies: ["ConsciousnessStructures"], path: "Shared/Swift/ConflictResolver"),
        
        // MARK: - SyntraSwift with added dependencies
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

        // MARK: - Executable CLI Target
        .executableTarget(
            name: "SyntraSwiftCLI",
            dependencies: ["SyntraCore", "ConversationalInterface"],
            path: "SyntraSwiftCLI"
        ),

        // MARK: - External API Layer (macOS-only for Process class)
        .target(
            name: "SyntraWrappers",
            path: "Wrappers"
        ),
        .executableTarget(
            name: "SyntraAPILayer",
            dependencies: ["SyntraWrappers"],
            path: "APIs"
        ),

        // MARK: - Test Target
        .testTarget(
            name: "SyntraFoundationTests",
            dependencies: ["SyntraCore"],
            path: "Tests/SyntraFoundationTests"
        ),
    ]
)

