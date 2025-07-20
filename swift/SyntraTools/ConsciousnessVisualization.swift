import SwiftUI
import FoundationModels

// CONSCIOUSNESS VISUALIZATION
// Real-time SwiftUI interface for SYNTRA consciousness states
// Implements streaming updates with modern Apple design principles

@available(macOS "26.0", *)
public struct ConsciousnessView: View {
    @State private var engine: ModernConsciousnessEngine
    @State private var currentInput = ""
    @State private var streamingState: ModernConsciousnessEngine.ConsciousnessState.PartiallyGenerated?
    @State private var isStreamingMode = true
    @State private var showAdvancedControls = false
    @State private var selectedTools: Set<String> = []
    @State private var errorMessage: String?
    
    private let availableTools = ["retrieve_memory", "analyze_patterns", "analyze_emotional_state", "assess_consciousness_state"]
    
    public init() {
        do {
            let consciousnessEngine = try ModernConsciousnessEngine()
            self._engine = State(initialValue: consciousnessEngine)
        } catch {
            // Fallback initialization - will show error in UI
            self._engine = State(initialValue: try! ModernConsciousnessEngine())
        }
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Main consciousness visualization
                consciousnessVisualization
                
                Spacer()
                
                // Advanced controls toggle
                advancedControlsSection
                
                // Input area
                inputArea
                
                // Error display
                if let error = errorMessage {
                    errorDisplay(error)
                }
            }
            .padding()
            .navigationTitle("SYNTRA Consciousness")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAdvancedControls.toggle() }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
    
    private var consciousnessVisualization: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let state = streamingState {
                streamingVisualization(state)
            } else if let state = engine.currentState {
                completeVisualization(state)
            } else {
                initialVisualization
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 8)
        )
    }
    
    private func streamingVisualization(_ state: ModernConsciousnessEngine.ConsciousnessState.PartiallyGenerated) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Consciousness State")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if engine.isProcessing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text(engine.processingStage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Awareness Level (streams first)
            if let awareness = state.awarenessLevel {
                awarenessLevelView(awareness)
            } else {
                placeholderView("Analyzing awareness level...")
            }
            
            // Emotional State
            if let emotion = state.emotionalState {
                // Handle PartiallyGenerated emotional state
                if let fullEmotion = try? emotion.generated() {
                    emotionalStateView(fullEmotion)
                } else {
                    placeholderView("Processing emotional state...")
                }
            } else {
                placeholderView("Processing emotional state...")
            }
            
            // Active Processes
            if let processes = state.activeProcesses {
                activeProcessesView(processes)
            } else {
                placeholderView("Identifying active processes...")
            }
            
            // Integration Quality
            if let integration = state.integrationQuality {
                integrationQualityView(integration)
            } else {
                placeholderView("Calculating integration quality...")
            }
            
            // Internal Dialogue (streams progressively)
            if let dialogue = state.internalDialogue {
                internalDialogueView(dialogue)
            } else {
                placeholderView("Generating internal dialogue...")
            }
            
            // Confidence Level
            if let confidence = state.confidence {
                confidenceView(confidence)
            } else {
                placeholderView("Assessing confidence...")
            }
        }
    }
    
    private func completeVisualization(_ state: ModernConsciousnessEngine.ConsciousnessState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Consciousness State")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let lastUpdate = engine.lastUpdate {
                    Text(lastUpdate.formatted(.relative(presentation: .numeric)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            awarenessLevelView(state.awarenessLevel)
            emotionalStateView(state.emotionalState)
            activeProcessesView(state.activeProcesses)
            integrationQualityView(state.integrationQuality)
            internalDialogueView(state.internalDialogue)
            confidenceView(state.confidence)
            
            // Additional complete state info
            if !state.moralInsights.isEmpty {
                moralInsightsView(state.moralInsights)
            }
            
            if !state.logicalAnalysis.isEmpty {
                logicalAnalysisView(state.logicalAnalysis)
            }
            
            if !state.emergentPatterns.isEmpty {
                emergentPatternsView(state.emergentPatterns)
            }
        }
    }
    
    private var initialVisualization: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("SYNTRA Consciousness")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Consciousness state initializing...")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Provide a stimulus to begin consciousness processing")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    // MARK: - Component Views
    
    private func awarenessLevelView(_ level: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Awareness Level")
                    .font(.headline)
                Spacer()
                Text("\(level, specifier: "%.2f")")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            ProgressView(value: level, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: awarenessColor(level)))
                .animation(.easeInOut(duration: 0.5), value: level)
        }
    }
    
    private func emotionalStateView(_ emotion: ModernConsciousnessEngine.EmotionalProfile) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Emotional State")
                    .font(.headline)
                Spacer()
                Text(emotion.stability)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(emotion.primaryEmotion.capitalized)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(emotionColor(emotion.primaryEmotion))
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Intensity")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(emotion.intensity, specifier: "%.1f")")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            if !emotion.triggers.isEmpty {
                Text("Triggers: \(emotion.triggers.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func activeProcessesView(_ processes: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Active Processes")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120))
            ], spacing: 8) {
                ForEach(processes, id: \.self) { process in
                    Text(process.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private func integrationQualityView(_ quality: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Integration Quality")
                    .font(.headline)
                Spacer()
                Text("\(quality, specifier: "%.2f")")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            ProgressView(value: quality, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: integrationColor(quality)))
                .animation(.easeInOut(duration: 0.5), value: quality)
        }
    }
    
    private func internalDialogueView(_ dialogue: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Internal Dialogue")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(dialogue.enumerated()), id: \.offset) { index, thought in
                    HStack(alignment: .top) {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(thought)
                            .font(.body)
                            .italic()
                            .multilineTextAlignment(.leading)
                    }
                    .transition(.slide.combined(with: .opacity))
                }
            }
        }
    }
    
    private func confidenceView(_ confidence: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Confidence")
                    .font(.headline)
                Spacer()
                Text(confidenceDescription(confidence))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: confidence, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: confidenceColor(confidence)))
                .animation(.easeInOut(duration: 0.5), value: confidence)
        }
    }
    
    private func moralInsightsView(_ insights: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Moral Insights (Valon)")
                .font(.headline)
                .foregroundColor(.purple)
            
            ForEach(insights, id: \.self) { insight in
                Text("• \(insight)")
                    .font(.caption)
                    .foregroundColor(.purple.opacity(0.8))
            }
        }
    }
    
    private func logicalAnalysisView(_ analysis: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Logical Analysis (Modi)")
                .font(.headline)
                .foregroundColor(.green)
            
            ForEach(analysis, id: \.self) { item in
                Text("• \(item)")
                    .font(.caption)
                    .foregroundColor(.green.opacity(0.8))
            }
        }
    }
    
    private func emergentPatternsView(_ patterns: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Emergent Patterns")
                .font(.headline)
                .foregroundColor(.orange)
            
            ForEach(patterns, id: \.self) { pattern in
                Text("• \(pattern)")
                    .font(.caption)
                    .foregroundColor(.orange.opacity(0.8))
            }
        }
    }
    
    private func placeholderView(_ text: String) -> some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Input Interface
    
    private var inputArea: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Enter stimulus or thought...", text: $currentInput, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                
                Button(action: processInput) {
                    Image(systemName: isStreamingMode ? "play.fill" : "arrow.right.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .disabled(engine.isProcessing || currentInput.isEmpty)
            }
            
            HStack {
                Toggle("Streaming Mode", isOn: $isStreamingMode)
                    .font(.caption)
                
                Spacer()
                
                if engine.isProcessing {
                    Text("Processing...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var advancedControlsSection: some View {
        Group {
            if showAdvancedControls {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enhanced Processing Tools")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 180))
                    ], spacing: 8) {
                        ForEach(availableTools, id: \.self) { tool in
                            Toggle(toolDisplayName(tool), isOn: Binding(
                                get: { selectedTools.contains(tool) },
                                set: { if $0 { selectedTools.insert(tool) } else { selectedTools.remove(tool) } }
                            ))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(selectedTools.contains(tool) ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                .transition(.slide.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showAdvancedControls)
    }
    
    private func errorDisplay(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(error)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Actions
    
    private func processInput() {
        guard !currentInput.isEmpty else { return }
        
        let input = currentInput
        currentInput = ""
        errorMessage = nil
        
        Task {
            do {
                if isStreamingMode {
                    // Use streaming for real-time updates
                    let stream = engine.streamConsciousnessUpdates(stimulus: input)
                    
                    for await partialState in stream {
                        await MainActor.run {
                            streamingState = partialState
                        }
                    }
                    
                    // Clear streaming state when complete
                    await MainActor.run {
                        streamingState = nil
                    }
                } else {
                    // Use standard processing
                    if selectedTools.isEmpty {
                        _ = try await engine.processConsciousnessUpdate(stimulus: input)
                    } else {
                        _ = try await engine.processWithToolEnhancement(
                            stimulus: input,
                            useTools: Array(selectedTools)
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func awarenessColor(_ level: Double) -> Color {
        switch level {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
    
    private func emotionColor(_ emotion: String) -> Color {
        switch emotion.lowercased() {
        case "curious", "excited": return .blue
        case "contemplative", "focused": return .purple
        case "calm": return .green
        case "confused": return .orange
        default: return .primary
        }
    }
    
    private func integrationColor(_ quality: Double) -> Color {
        switch quality {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
    
    private func confidenceDescription(_ confidence: Double) -> String {
        switch confidence {
        case 0.9...1.0: return "Very High"
        case 0.8..<0.9: return "High"
        case 0.6..<0.8: return "Moderate"
        case 0.4..<0.6: return "Low"
        default: return "Very Low"
        }
    }
    
    private func toolDisplayName(_ tool: String) -> String {
        switch tool {
        case "retrieve_memory": return "Memory Retrieval"
        case "analyze_patterns": return "Pattern Analysis"
        case "analyze_emotional_state": return "Emotional Analysis"
        case "assess_consciousness_state": return "State Assessment"
        default: return tool.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

// MARK: - Preview

@available(macOS "26.0", *)
struct ConsciousnessView_Previews: PreviewProvider {
    static var previews: some View {
        ConsciousnessView()
            .frame(width: 800, height: 600)
    }
}
