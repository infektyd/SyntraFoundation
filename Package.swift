// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SyntraSwift",
    platforms: [
        .macOS(.v15), // Primary target - falls back to non-FoundationModels types
        .iOS(.v18)
    ],
    products: [
        .library(name: "Valon", targets: ["Valon"]),
        .library(name: "Modi", targets: ["Modi"]),
        .library(name: "Drift", targets: ["Drift"]),
        .library(name: "MemoryEngine", targets: ["MemoryEngine"]),
        .library(name: "ConsciousnessStructures", targets: ["ConsciousnessStructures"]),
        .library(name: "BrainEngine", targets: ["BrainEngine"]),
        // .library(name: "ConversationalInterface", targets: ["ConversationalInterface"]),
        .library(name: "StructuredConsciousnessService", targets: ["StructuredConsciousnessService"]),
        .library(name: "MoralDriftMonitoring", targets: ["MoralDriftMonitoring"]),
        .library(name: "SyntraConfig", targets: ["SyntraConfig"]),
        .library(name: "MoralCore", targets: ["MoralCore"]),
        // .library(name: "SyntraTools", targets: ["SyntraTools"]),
        .library(name: "CognitiveDrift", targets: ["CognitiveDrift"]),
        .executable(name: "SyntraSwiftCLI", targets: ["SyntraSwiftCLI"])
    ],
    targets: [
        .target(
            name: "Valon",
            dependencies: ["ConsciousnessStructures"],
            path: "Sources/Valon"
        ),
        .target(
            name: "Modi",
            dependencies: ["ConsciousnessStructures"],
            path: "Sources/Modi"
        ),
        .target(
            name: "Drift",
            path: "Sources/Drift"
        ),
        .target(
            name: "MemoryEngine",
            dependencies: ["Valon", "Modi", "Drift"],
            path: "Sources/MemoryEngine"
        ),
        .target(
            name: "ConsciousnessStructures",
            path: "Sources/ConsciousnessStructures"
        ),
        .target(
            name: "BrainEngine",
            dependencies: ["Valon", "Modi", "Drift", "ConsciousnessStructures", "SyntraConfig"],
            path: "Sources/BrainEngine"
        ),
        // .target(
        //     name: "ConversationalInterface",
        //     dependencies: ["BrainEngine", "MoralDriftMonitoring", "MemoryEngine", "ConsciousnessStructures"],
        //     path: "Sources/ConversationalInterface"
        // ),
        .target(
            name: "MoralDriftMonitoring",
            dependencies: ["ConsciousnessStructures"],
            path: "Sources/MoralDriftMonitoring"
        ),
        .target(
            name: "StructuredConsciousnessService",
            dependencies: ["ConsciousnessStructures", "MoralDriftMonitoring"],
            path: "Sources/StructuredConsciousnessService"
        ),
        .target(
            name: "SyntraConfig",
            dependencies: [],
            path: "Sources/SyntraConfig"
        ),
        .target(
            name: "MoralCore",
            dependencies: ["ConsciousnessStructures"],
            path: "Sources/MoralCore"
        ),
        // .target(
        //     name: "SyntraTools",
        //     dependencies: ["ConsciousnessStructures", "MoralCore"],
        //     path: "Sources/SyntraTools"
        // ),
        .target(
            name: "CognitiveDrift",
            dependencies: ["SyntraConfig", "Valon", "Modi", "Drift", "MemoryEngine"],
            path: "Sources/CognitiveDrift"
        ),
        .executableTarget(
            name: "SyntraSwiftCLI",
            dependencies: [
                "Valon", "Modi", "Drift", "MemoryEngine", "BrainEngine",
                "ConsciousnessStructures", "MoralDriftMonitoring",
                "StructuredConsciousnessService"
            ],
            path: "swift"
        ),
        .testTarget(
            name: "SyntraSwiftTests",
            dependencies: ["Valon", "Modi", "Drift", "MemoryEngine", "BrainEngine", "SyntraConfig"],
            path: "Tests",
            exclude: ["__pycache__", "test_citation_handler.py", "test_config_toggle.py", "test_io_tools.py"]
        )
    ]
)

