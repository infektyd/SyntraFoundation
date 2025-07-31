// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "SyntraFoundation",
    platforms: [
        .macOS(.v26),
        .iOS(.v26)
    ],
    products: [
        .library(name: "SyntraFoundation", targets: ["Valon", "Modi", "Drift", "MemoryEngine", "ConsciousnessStructures", "BrainEngine", "ConversationalInterface", "StructuredConsciousnessService", "MoralDriftMonitoring", "SyntraConfig", "MoralCore", "SyntraTools", "SyntraCore", "CognitiveDrift", "ConflictResolver"]),
        .library(name: "SyntraSwift", targets: ["SyntraSwift"])
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
            name: "SyntraCore",
            dependencies: ["Valon", "Modi", "BrainEngine"],
            path: "Shared/Swift/SyntraCore"
        ),
// SyntraUI target removed - UI components moved to Shared/Sources/SyntraSwift/
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
            dependencies: [
                "ConsciousnessStructures", 
                "MoralCore", 
                "StructuredConsciousnessService", 
                "MoralDriftMonitoring", 
                "Valon", 
                "Modi", 
                "Drift", 
                "MemoryEngine", 
                "SyntraConfig"  // This should already be there
            ],
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
        .target(
            name: "SyntraSwift",
            dependencies: ["SyntraCore", "SyntraTools"],
            path: "Shared/Sources/SyntraSwift"
        ),
        .testTarget(
            name: "SyntraFoundationTests",
            dependencies: ["SyntraCore"],
            path: "Tests/SyntraFoundationTests"
        )
    ]
)
