import Foundation

public struct EnhancedMetrics: Sendable {
    public let minValue: Double
    public let maxValue: Double
    public let count: Int
    public let average: Double
    public let standardDeviation: Double
    public let entropy: Double
    public let driftScore: Double
    
    // Enhanced consciousness metrics
    public let syntraActivations: Int
    public let totalDetections: Int
    public let activationEntropy: Double
    public let patternEntropy: Double
    
    public init(
        minValue: Double,
        maxValue: Double,
        count: Int,
        average: Double,
        standardDeviation: Double,
        entropy: Double,
        driftScore: Double,
        syntraActivations: Int,
        totalDetections: Int,
        activationEntropy: Double,
        patternEntropy: Double
    ) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.count = count
        self.average = average
        self.standardDeviation = standardDeviation
        self.entropy = entropy
        self.driftScore = driftScore
        self.syntraActivations = syntraActivations
        self.totalDetections = totalDetections
        self.activationEntropy = activationEntropy
        self.patternEntropy = patternEntropy
    }
}

public struct ModiAnalysis: Sendable {
    public let probabilities: [String: Double]
    public let entropy: Double
    public let prior: [String: Double]
    public let posterior: [String: Double]
    public let likelihood: [String: Double]
    
    public init(probabilities: [String: Double], entropy: Double, prior: [String: Double], posterior: [String: Double], likelihood: [String: Double]) {
        self.probabilities = probabilities
        self.entropy = entropy
        self.prior = prior
        self.posterior = posterior
        self.likelihood = likelihood
    }
}

public struct ValonAnalysis: Sendable {
    public let evaluation: String
    public let emotionalWeight: Double
    
    public init(evaluation: String, emotionalWeight: Double) {
        self.evaluation = evaluation
        self.emotionalWeight = emotionalWeight
    }
}

public struct FlatJSONResponse: Sendable {
    public let modiAnalysis: ModiAnalysis
    public let valonAnalysis: ValonAnalysis
    public let metrics: [String: Double]
    public let timestamp: Date
    
    public init(modiAnalysis: ModiAnalysis, valonAnalysis: ValonAnalysis, metrics: [String: Double], timestamp: Date) {
        self.modiAnalysis = modiAnalysis
        self.valonAnalysis = valonAnalysis
        self.metrics = metrics
        self.timestamp = timestamp
    }
}
