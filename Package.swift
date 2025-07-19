// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SyntraSwift",
    platforms: [
        .macOS(.v15),  // Changed from 26.0 to 15 for Foundation Models compatibility
        .iOS(.v18)     // Added iOS support
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
        .executable(name: "SyntraSwiftCLI", targets: ["SyntraSwiftCLI"]),
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
        .target(name: "Drift", path: "Sources/Drift"),
        .target(
            name: "MemoryEngine",
            dependencies: ["Valon", "Modi", "Drift"],
            path: "Sources/MemoryEngine"
        ),
        .target(
            name: "ConsciousnessStructures",
            dependencies: [],
            path: "Sources/ConsciousnessStructures"
        ),
        .target(
            name: "BrainEngine",
            dependencies: ["Valon", "Modi", "Drift", "ConsciousnessStructures"],
            path: "Sources/BrainEngine"
        ),
        .target(
            name: "ConversationalInterface",
            dependencies: ["BrainEngine", "MoralDriftMonitoring", "MemoryEngine", "ConsciousnessStructures"],
            path: "Sources/ConversationalInterface"
        ),
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
        .executableTarget(
            name: "SyntraSwiftCLI",
            dependencies: [
                "Valon", "Modi", "Drift", "MemoryEngine",
                "ConsciousnessStructures", "MoralDriftMonitoring", 
                "StructuredConsciousnessService"
            ],
            path: "swift"
        ),
        .testTarget(
            name: "SyntraSwiftTests",
            dependencies: ["SyntraSwiftCLI", "Valon", "Modi", "Drift", "MemoryEngine"],
            path: "Tests"
        ),
    ]
)
