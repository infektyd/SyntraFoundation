// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SyntraSwift",
    platforms: [
        .macOS("15.0"), // Required for FoundationModels
        .iOS(.v18)
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
        .executable(name: "SyntraSwiftCLI", targets: ["SyntraSwiftCLI"])
    ],
    targets: [
        .target(
            name: "Valon",
            dependencies: ["ConsciousnessStructures"],
            path: "swift/Valon"
        ),
        .target(
            name: "Modi",
            dependencies: ["ConsciousnessStructures"],
            path: "swift/Modi"
        ),
        .target(
            name: "Drift",
            path: "swift/Drift"
        ),
        .target(
            name: "MemoryEngine",
            dependencies: ["Valon", "Modi", "Drift"],
            path: "swift/MemoryEngine"
        ),
        .target(
            name: "ConsciousnessStructures",
            path: "swift/ConsciousnessStructures"
        ),
        .target(
            name: "BrainEngine",
            dependencies: ["Valon", "Modi", "Drift", "ConsciousnessStructures", "SyntraConfig"],
            path: "swift/BrainEngine"
        ),
         .target(
             name: "ConversationalInterface",
             dependencies: ["BrainEngine", "MoralDriftMonitoring", "MemoryEngine", "ConsciousnessStructures"],
             path: "swift/ConversationalInterface"
         ),
        .target(
            name: "MoralDriftMonitoring",
            dependencies: ["ConsciousnessStructures"],
            path: "swift/MoralDriftMonitoring"
        ),
        .target(
            name: "StructuredConsciousnessService",
            dependencies: ["ConsciousnessStructures", "MoralDriftMonitoring"],
            path: "swift/StructuredConsciousnessService"
        ),
        .target(
            name: "SyntraConfig",
            dependencies: [],
            path: "swift/SyntraConfig"
        ),
        .target(
            name: "MoralCore",
            dependencies: ["ConsciousnessStructures"],
            path: "swift/MoralCore"
        ),
        .target(
            name: "SyntraTools",
            dependencies: ["ConsciousnessStructures", "MoralCore", "StructuredConsciousnessService", "MoralDriftMonitoring"],
            path: "swift/SyntraTools"
        ),
        .target(
            name: "CognitiveDrift",
            dependencies: ["SyntraConfig", "Valon", "Modi", "Drift", "MemoryEngine"],
            path: "swift/CognitiveDrift"
        ),
        .executableTarget(
            name: "SyntraSwiftCLI",
            dependencies: [
                "Valon", "Modi", "Drift", "MemoryEngine", "BrainEngine",
                "ConsciousnessStructures", "MoralDriftMonitoring",
                "StructuredConsciousnessService", "SyntraConfig", "MoralCore"
            ],
            path: "swift",
            sources: ["Main/main.swift"]
        ),
        .testTarget(
            name: "SyntraSwiftTests",
            dependencies: ["Valon", "Modi", "Drift", "MemoryEngine", "BrainEngine", "SyntraConfig", "StructuredConsciousnessService"],
            path: "tests",
            exclude: ["__pycache__", "test_citation_handler.py", "test_config_toggle.py", "test_io_tools.py"]
        )
    ]
)

