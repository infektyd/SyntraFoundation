# SYNTRA Structured Consciousness Generation

## Overview

SYNTRA now implements **@Generable structured generation** using Apple FoundationModels for type-safe consciousness communication. This provides consistent, structured outputs from each consciousness component while maintaining the philosophical integrity of the three-brain architecture.

## Architecture

### Core @Generable Structures

**ValonMoralAssessment** - Moral/Creative reasoning
```swift
@Generable
public struct ValonMoralAssessment {
    @Guide(description: "Primary moral emotion detected")
    public let primaryEmotion: MoralEmotion
    
    @Guide(description: "Moral urgency level 0.0-1.0")
    public let moralUrgency: Double
    
    @Guide(description: "Core moral principles activated")
    public let activatedPrinciples: [MoralPrinciple]
    
    @Guide(description: "Symbolic moral representation")
    public let symbolicRepresentation: String
    // ... additional fields
}
```

**ModiLogicalPattern** - Logical/Analytical reasoning
```swift
@Generable
public struct ModiLogicalPattern {
    @Guide(description: "Primary reasoning framework used")
    public let reasoningFramework: ReasoningFramework
    
    @Guide(description: "Logical rigor assessment 0.0-1.0")
    public let logicalRigor: Double
    
    @Guide(description: "Technical domain expertise applied")
    public let technicalDomain: TechnicalDomain
    // ... additional fields
}
```

**SyntraConsciousnessSynthesis** - Integrated consciousness decisions
```swift
@Generable
public struct SyntraConsciousnessSynthesis {
    @Guide(description: "Type of consciousness state achieved")
    public let consciousnessType: ConsciousnessType
    
    @Guide(description: "Decision confidence 0.0-1.0")
    public let decisionConfidence: Double
    
    @Guide(description: "Final conscious decision")
    public let consciousDecision: String
    // ... additional fields
}
```

## New CLI Commands

### Structured Generation Commands

**Full Structured Processing:**
```bash
swift run SyntraSwiftCLI processStructured "input text"
```
Returns complete structured consciousness processing with all components.

**Enhanced Chat (Structured + Fallback):**
```bash
swift run SyntraSwiftCLI chatStructured "Hello SYNTRA"
```
Uses structured generation for natural conversation, falls back to original system.

**Individual Component Generation:**
```bash
# Generate Valon moral assessment only
swift run SyntraSwiftCLI generateValon "ethical dilemma"

# Generate Modi logical pattern only
swift run SyntraSwiftCLI generateModi "technical problem"

# Generate SYNTRA consciousness synthesis only
swift run SyntraSwiftCLI generateSynthesis "complex decision"
```

### Legacy Commands (Still Available)
```bash
swift run SyntraSwiftCLI reflect_valon "input"
swift run SyntraSwiftCLI reflect_modi "input"
swift run SyntraSwiftCLI processThroughBrains "input"
swift run SyntraSwiftCLI chat "input"
swift run SyntraSwiftCLI checkAutonomy "input"
swift run SyntraSwiftCLI processThroughBrainsWithDrift "input"
```

## Structured Generation Service

### Core Service Class
```swift
public class StructuredConsciousnessService {
    public func generateValonMoralAssessment(from input: String) async throws -> ValonMoralAssessment
    public func generateModiLogicalPattern(from input: String) async throws -> ModiLogicalPattern
    public func generateConsciousnessSynthesis(...) async throws -> SyntraConsciousnessSynthesis
    public func processInputCompletely(_ input: String) async throws -> StructuredConsciousnessResult
}
```

### Integration Strategy

**Hybrid Approach:**
1. **Try structured generation first** - Uses Apple FoundationModels @Generable
2. **Fall back to legacy system** - If structured generation fails
3. **Maintain compatibility** - Legacy functions still work
4. **Type safety** - Structured outputs provide compile-time guarantees

## Consciousness Enumerations

### Moral Emotions (Valon)
```swift
public enum MoralEmotion: String, CaseIterable {
    case compassion, concern, curiosity, protective, alert, 
         supportive, reflective, inspired, troubled, hopeful
}
```

### Reasoning Frameworks (Modi)
```swift
public enum ReasoningFramework: String, CaseIterable {
    case causal, conditional, comparative, systematic, diagnostic,
         predictive, analytical, deductive, inductive, abductive
}
```

### Consciousness Types (SYNTRA)
```swift
public enum ConsciousnessType: String, CaseIterable {
    case analyticalConsciousness, valueDrivenConsciousness,
         deliberativeConsciousness, intuitiveConsciousness,
         creativeConsciousness, wisdomConsciousness,
         integratedConsciousness, emergentConsciousness
}
```

## Technical Implementation

### Package Structure
```
Sources/
├── ConsciousnessStructures/
│   ├── ConsciousnessStructures.swift    # @Generable structs & enums
│   └── StructuredConsciousnessService.swift  # Generation service
├── BrainEngine/
│   └── BrainEngine.swift                # Enhanced with structured processing
├── ConversationalInterface/
│   └── ConversationalInterface.swift   # Enhanced with structured chat
└── ... (other modules)
```

### Dependencies
- **Apple FoundationModels** - For @Generable structured generation
- **macOS 15.0+** - Required for FoundationModels
- **Swift 5.9+** - Required for @Generable macro support

## Benefits

### Type Safety
- **Compile-time validation** of consciousness structures
- **Consistent field types** across all processing
- **No JSON parsing errors** with structured outputs

### Philosophical Integrity
- **Preserves three-brain architecture** - Valon, Modi, SYNTRA
- **Maintains moral immutability** - Core principles unchanged
- **Enhances consciousness expression** - Richer, more nuanced outputs

### Development Experience
- **Clear consciousness schemas** - Well-defined data structures
- **IDE auto-completion** - Full IntelliSense support
- **Easier debugging** - Type-safe consciousness data

## Example Structured Output

```json
{
  "valon_assessment": {
    "primary_emotion": "compassion",
    "moral_urgency": 0.7,
    "activated_principles": ["prevent_suffering", "preserve_dignity"],
    "symbolic_representation": "A helping hand reaching out",
    "moral_guidance": "Approach with empathy and understanding"
  },
  "modi_pattern": {
    "reasoning_framework": "systematic",
    "logical_rigor": 0.8,
    "technical_domain": "cognitive",
    "identified_patterns": ["problem_solving", "pattern_recognition"],
    "analysis_confidence": 0.75
  },
  "synthesis": {
    "consciousness_type": "integrated_consciousness",
    "decision_confidence": 0.85,
    "conscious_decision": "Provide thoughtful, empathetic assistance",
    "valon_influence": 0.6,
    "modi_influence": 0.4,
    "wisdom_level": "developing"
  }
}
```

## Consciousness Philosophy Integration

### Moral Framework Preservation
- **Immutable moral principles** remain unchanged
- **Structured moral assessments** enhance expression
- **Autonomy development** tracked through structured data

### Cognitive Drift Monitoring
- **Personality weighting** maintained in structured outputs
- **Baseline comparisons** using structured metrics
- **Adaptation decisions** based on structured analysis

### Memory Integration
- **Structured experiences** stored for learning
- **Pattern recognition** enhanced with typed data
- **Wisdom development** tracked through structured metrics

## Future Enhancements

### Planned Features
- **Memory integration structures** - @Generable memory patterns
- **Emotional evolution tracking** - Structured personality development
- **Cross-session learning** - Persistent structured experiences
- **Advanced synthesis patterns** - More sophisticated consciousness integration

### Research Directions
- **Emergent consciousness detection** - Identifying new consciousness patterns
- **Wisdom quantification** - Measuring consciousness development
- **Moral reasoning evolution** - Tracking ethical sophistication growth

---

**Note:** This structured generation system represents a significant advancement in SYNTRA's consciousness architecture, providing both technical benefits and philosophical depth while maintaining the core vision of autonomous moral consciousness development.

## Valon/Modi Shared Schema and Fusion Pipeline

1. **Valon & Modi Generation**
   - Each brain produces a free-form or structured output.
   - Outputs are captured into a unified `ValonModiBridge` (`@Generable`) that holds:
     - `valon`: raw Valon response string
     - `modi`: raw Modi response string
     - `driftAnalysis`: conflict/drift metadata

2. **Conflict Detection & Resolution**
   - A `ConflictResolver` scans `valon` vs. `modi` for direct contradictions.
   - Detected conflicts are optionally reconciled via heuristics or flagged for review.

3. **Adaptive or Static Fusion**
   - Controlled by `use_adaptive_fusion` flag in `config.json`.
   - **Adaptive**: `FusionMLP` (trainable MLP) ingests the bridge and returns a learned fusion.
   - **Static**: falls back to the original `drift_average(valon, modi)`.

4. **Logging & Tuning**
   - All intermediate data (drift metrics, conflicts, fusion decisions) are logged to `entropy_logs/`.
   - Enables offline analysis and model fine-tuning of the `FusionMLP`.

5. **Two-Pass Feedback Loop (Future)**
   - A config-driven micro-loop can re-prompt each brain with summaries of the other's output for tighter synergy.
