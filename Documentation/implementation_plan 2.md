# Implementation Plan

[Overview]
Enhance Modi's Bayesian calculations and consciousness metrics tracking, then expose through a flat JSON API endpoint while maintaining iOS 16+ compatibility and atomic concurrency safety.

[Types]  
Add new types for flat JSON responses and enhanced metrics:

```swift
public struct FlatJSONResponse: Sendable {
    public let modiAnalysis: [String: Any]
    public let valonAnalysis: [String: Any]
    public let metrics: [String: Double]
    public let timestamp: Date
}

public struct EnhancedMetrics: Sendable {
    public let minValue: Double
    public let maxValue: Double
    public let count: Int
    public let average: Double
    public let standardDeviation: Double
    public let entropy: Double
    public let driftScore: Double
}
```

[Files]
- Modi.swift: Refactor Bayesian calculations
- ConsciousnessMemory.swift: Enhance metrics tracking
- SyntraCLIWrapper.swift: Add new endpoint
- Tests/SyntraFoundationTests.swift: Add test cases

[Functions]
- Modi.swift:
  - Add `calculateEnhancedBayesian()` using Algorithms package
  - Add `calculateEntropy()` helper
  - Update `calculateQuantitativeMetrics()`

- ConsciousnessMemory.swift:
  - Add `getEnhancedMetrics()` combining all metrics
  - Add entropy calculation to drift tracking

- SyntraCLIWrapper.swift:
  - Add `getEnhancedAnalysis()` returning FlatJSONResponse
  - Add JSON serialization helpers

[Classes]
- No new classes needed
- Enhance existing Modi and ConsciousnessMemoryManager

[Dependencies]
- Existing swift-algorithms (v1.2.0) sufficient
- No new dependencies required

[Testing]
- Add tests for:
  - Flat JSON serialization
  - Enhanced Bayesian calculations
  - Metrics aggregation
  - Concurrency safety

[Implementation Order]
1. Refactor Modi.swift Bayesian calculations
2. Enhance ConsciousnessMemory.swift metrics
3. Implement flat JSON API endpoint
4. Add comprehensive test coverage
5. Update documentation
