// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SyntraFoundation",
    platforms: [
        .macOS ("26.0"), // Required for FoundationModels
        .iOS ("26.0")
    ],
    products: [
        .library(name: "Valon", targets: ["Valon"]),
        .library(name: "Modi", targets: ["Modi"]),
        .library(name: "Drift", targets: ["Drift"]),
        .library(name: "MemoryEngine", targets: ["MemoryEngine"]),
        .library(name: "ConsciousnessStructures", targets: ["ConsciousnessStructures"]),
        .library(name: "BrainEngine", targets: ["BrainEngine"]),
        .library(name: "ConversationalInterface", targets: ["ConversationalInterface"]),
        .library(name: "StructuredConsciousnessService", targets: ["StructuredConsciousnessService"]),
        .library(name: "MoralDriftMonitoring", targets: ["MoralDriftMonitoring"]),
        .library(name: "SyntraConfig", targets: ["SyntraConfig"]),
        .library(name: "MoralCore", targets: ["MoralCore"]),
        .library(name: "SyntraTools", targets: ["SyntraTools"]),
        .library(name: "CognitiveDrift", targets: ["CognitiveDrift"]),
        .library(name: "ConflictResolver", targets: ["ConflictResolver"]),
        .executable(name: "SyntraSwiftCLI", targets: ["SyntraSwiftCLI"])
    ],
    targets: [
        .target(
            name: "Valon",
            dependencies: ["ConsciousnessStructures"],
            path: "Shared/Swift/Valon"
        ),
        .target(
            name: "Modi",
            dependencies: ["ConsciousnessStructures"],
            path: "Shared/Swift/Modi"
        ),
        .target(
            name: "Drift",
            path: "Shared/Swift/Drift"
        ),
        .target(
            name: "MemoryEngine",
            dependencies: ["Valon", "Modi", "Drift"],
            path: "Shared/Swift/MemoryEngine"
        ),
        .target(
            name: "ConsciousnessStructures",
            path: "Shared/Swift/ConsciousnessStructures"
        ),
        .target(
            name: "BrainEngine",
            dependencies: ["Valon", "Modi", "Drift", "ConsciousnessStructures", "SyntraConfig", "SyntraTools"],
            path: "Shared/Swift/BrainEngine"
        ),
         .target(
             name: "ConversationalInterface",
             dependencies: ["BrainEngine", "MoralDriftMonitoring", "MemoryEngine", "ConsciousnessStructures", "SyntraTools"],
             path: "Shared/Swift/ConversationalInterface"
         ),
        .target(
            name: "MoralDriftMonitoring",
            dependencies: ["ConsciousnessStructures"],
            path: "Shared/Swift/MoralDriftMonitoring"
        ),
        .target(
            name: "StructuredConsciousnessService",
            dependencies: ["ConsciousnessStructures", "MoralDriftMonitoring"],
            path: "Shared/Swift/StructuredConsciousnessService"
        ),
        .target(
            name: "SyntraConfig",
            dependencies: [],
            path: "Shared/Swift/SyntraConfig"
        ),
        .target(
            name: "MoralCore",
            dependencies: ["ConsciousnessStructures"],
            path: "Shared/Swift/MoralCore"
        ),
        .target(
            name: "SyntraTools",
            dependencies: ["ConsciousnessStructures", "MoralCore", "StructuredConsciousnessService", "MoralDriftMonitoring", "Valon", "Modi", "Drift", "MemoryEngine"],
            path: "Shared/Swift/SyntraTools"
        ),
        .target(
            name: "CognitiveDrift",
            dependencies: ["SyntraConfig", "Valon", "Modi", "Drift", "MemoryEngine", "ConsciousnessStructures", "ConflictResolver"],
            path: "Shared/Swift/CognitiveDrift"
        ),
        .target(
            name: "ConflictResolver",
            dependencies: ["ConsciousnessStructures"],
            path: "Shared/Swift/ConflictResolver"
        ),
        .executableTarget(
            name: "SyntraSwiftCLI",
            dependencies: [
                "Valon", "Modi", "Drift", "MemoryEngine", "BrainEngine",
                "ConsciousnessStructures", "MoralDriftMonitoring",
                "StructuredConsciousnessService", "SyntraTools", "SyntraConfig", "MoralCore", "ConversationalInterface"
            ],
            path: "Shared/Swift/Main",
            sources: ["main.swift"]
        ),
    ]
)
