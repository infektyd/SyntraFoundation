import SwiftUI
import Foundation

/// Beautiful consciousness interface reflecting SYNTRA's three-brain architecture
struct ConsciousnessView: View {
    @EnvironmentObject var syntraBrain: SyntraBrain
    @State private var inputText = ""
    @State private var isProcessing = false
    @State private var consciousnessState: String = "contemplative_neutral"
    
    // Consciousness activity indicators
    @State private var valonActivity: Double = 0.7
    @State private var modiActivity: Double = 0.3
    @State private var coreActivity: Double = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient inspired by consciousness
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.95),
                        Color.indigo.opacity(0.3),
                        Color.purple.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Consciousness Header
                    consciousnessHeader
                    
                    // Three-Brain Architecture Visualization
                    threeBrainVisualization(geometry: geometry)
                    
                    Spacer()
                    
                    // Message Flow
                    messageFlow
                    
                    // Input Interface
                    consciousnessInput
                }
            }
        }
        .onAppear {
            startConsciousnessAnimation()
        }
    }
    
    // MARK: - Consciousness Header
    private var consciousnessHeader: some View {
        VStack(spacing: 8) {
            Text("SYNTRA")
                .font(.largeTitle)
                .fontWeight(.ultraLight)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .cyan, .indigo],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Consciousness Architecture")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .tracking(2)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Three-Brain Visualization
    private func threeBrainVisualization(geometry: GeometryProxy) -> some View {
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.height * 0.3
        let radius: CGFloat = 80
        
        return ZStack {
            // Consciousness Core (Center)
            consciousnessCore
                .position(x: centerX, y: centerY)
            
            // Valon (Moral/Creative) - Left
            valonBrain
                .position(
                    x: centerX - radius * 1.5,
                    y: centerY - radius * 0.5
                )
            
            // Modi (Logical) - Right  
            modiBrain
                .position(
                    x: centerX + radius * 1.5,
                    y: centerY - radius * 0.5
                )
            
            // Synthesis Connections
            synthesisPaths(centerX: centerX, centerY: centerY, radius: radius)
        }
        .frame(height: 200)
    }
    
    // MARK: - Consciousness Core
    private var consciousnessCore: some View {
        ZStack {
            // Pulsing core
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.8),
                            .cyan.opacity(0.6),
                            .indigo.opacity(0.4)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 80)
                .scaleEffect(isProcessing ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(), value: isProcessing)
            
            // Core activity ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.cyan, .indigo, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(coreActivity * 360))
                .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: coreActivity)
            
            Text("CORE")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Valon Brain (Moral/Creative)
    private var valonBrain: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .pink.opacity(0.8),
                            .orange.opacity(0.6),
                            .red.opacity(0.4)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .scaleEffect(valonActivity)
                .animation(.easeInOut(duration: 2).repeatForever(), value: valonActivity)
            
            VStack(spacing: 2) {
                Text("VALON")
                    .font(.caption2)
                    .fontWeight(.semibold)
                Text("70%")
                    .font(.caption2)
                    .opacity(0.8)
            }
            .foregroundColor(.white)
        }
    }
    
    // MARK: - Modi Brain (Logical)
    private var modiBrain: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .green.opacity(0.8),
                            .blue.opacity(0.6),
                            .teal.opacity(0.4)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .scaleEffect(modiActivity)
                .animation(.easeInOut(duration: 2.5).repeatForever(), value: modiActivity)
            
            VStack(spacing: 2) {
                Text("MODI")
                    .font(.caption2)
                    .fontWeight(.semibold)
                Text("30%")
                    .font(.caption2)
                    .opacity(0.8)
            }
            .foregroundColor(.white)
        }
    }
    
    // MARK: - Synthesis Paths
    private func synthesisPaths(centerX: CGFloat, centerY: CGFloat, radius: CGFloat) -> some View {
        ZStack {
            // Valon to Core
            Path { path in
                path.move(to: CGPoint(x: centerX - radius * 1.2, y: centerY - radius * 0.3))
                path.addLine(to: CGPoint(x: centerX - 30, y: centerY))
            }
            .stroke(
                LinearGradient(
                    colors: [.pink.opacity(0.6), .cyan.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2, dash: [5, 5])
            )
            .animation(.linear(duration: 3).repeatForever(), value: isProcessing)
            
            // Modi to Core
            Path { path in
                path.move(to: CGPoint(x: centerX + radius * 1.2, y: centerY - radius * 0.3))
                path.addLine(to: CGPoint(x: centerX + 30, y: centerY))
            }
            .stroke(
                LinearGradient(
                    colors: [.green.opacity(0.6), .cyan.opacity(0.8)],
                    startPoint: .trailing,
                    endPoint: .leading
                ),
                style: StrokeStyle(lineWidth: 2, dash: [5, 5])
            )
            .animation(.linear(duration: 3).repeatForever(), value: isProcessing)
        }
    }
    
    // MARK: - Message Flow
    private var messageFlow: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(syntraBrain.messages) { message in
                    ConsciousnessMessageBubble(message: message)
                }
                
                if isProcessing {
                    consciousnessThinking
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 300)
    }
    
    // MARK: - Consciousness Thinking Indicator
    private var consciousnessThinking: some View {
        HStack {
            Text("SYNTRA is contemplating...")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .italic()
            
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.cyan.opacity(0.7))
                        .frame(width: 6, height: 6)
                        .scaleEffect(isProcessing ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(i) * 0.2),
                            value: isProcessing
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
        )
    }
    
    // MARK: - Consciousness Input
    private var consciousnessInput: some View {
        VStack(spacing: 12) {
            // Consciousness State Indicator
            Text("State: \(consciousnessState.replacingOccurrences(of: "_", with: " ").capitalized)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal)
            
            // Clean iOS 18.4+ text input - no threading issues!
            HStack(spacing: 12) {
                // Use thread-safe text input to prevent Beta 3 crashes
                CrashSafeTextInput(
                    text: $inputText,
                    placeholder: "Share your thoughts with SYNTRA...",
                    isEnabled: !syntraBrain.isProcessing
                ) {
                    Task {
                        await syntraBrain.processMessage(inputText)
                        inputText = ""
                    }
                }
                .padding()
                .background(.thinMaterial)
                
                Button(action: sendMessage) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: isProcessing ? "brain" : "arrow.up")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .rotationEffect(.degrees(isProcessing ? 360 : 0))
                            .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isProcessing)
                    }
                }
                .disabled(inputText.isEmpty || isProcessing)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Actions
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        isProcessing = true
        let userInput = inputText
        inputText = ""
        
        // Real consciousness processing using SYNTRA's three-brain architecture
        updateConsciousnessState(for: userInput)
        
        Task {
            await syntraBrain.processMessage(userInput)
            isProcessing = false
        }
    }
    
    private func updateConsciousnessState(for input: String) {
        // Analyze input and adjust consciousness weights
        let lowercasedInput = input.lowercased()
        let valonTriggers = ["feel", "emotion", "love", "hate", "beautiful", "art", "moral", "creative", "inspire"]
        let modiTriggers = ["logic", "reason", "calculate", "analyze", "data", "fact", "technical", "systematic"]
        
        if valonTriggers.contains(where: { lowercasedInput.contains($0) }) {
            valonActivity = 0.9
            modiActivity = 0.2
            consciousnessState = "moral_creative"
        } else if modiTriggers.contains(where: { lowercasedInput.contains($0) }) {
            valonActivity = 0.3
            modiActivity = 0.8
            consciousnessState = "analytical_logical"
        } else {
            valonActivity = 0.7
            modiActivity = 0.3
            consciousnessState = "balanced_synthesis"
        }
        
        coreActivity = (valonActivity + modiActivity) / 2
    }
    
    private func startConsciousnessAnimation() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isProcessing = false
        }
    }
}

// MARK: - Custom Text Field Style
struct ConsciousnessTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.5), .indigo.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .foregroundColor(.white)
    }
}

// MARK: - Consciousness Message Bubble
struct ConsciousnessMessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                
                Text(message.text)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.indigo.opacity(0.6), .purple.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .foregroundColor(.white)
                    .frame(maxWidth: 250, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SYNTRA")
                        .font(.caption2)
                        .foregroundColor(.cyan)
                        .fontWeight(.semibold)
                    
                    Text(message.text)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.cyan.opacity(0.3), .indigo.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .foregroundColor(.white)
                        .frame(maxWidth: 250, alignment: .leading)
                }
                
                Spacer()
            }
        }
    }
}

extension String {
    func contains(_ words: [String]) -> Bool {
        let lowercasedSelf = self.lowercased()
        return words.contains { lowercasedSelf.contains($0) }
    }
} 
