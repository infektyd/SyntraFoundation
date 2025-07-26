import SwiftUI

@MainActor
public struct SyntraChatView: View {
    @State private var viewModel: SyntraChatViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    public init(config: SyntraConfig) {
        self._viewModel = State(initialValue: SyntraChatViewModel(config: config))
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messagesView
                inputSection
            }
            .navigationTitle("SYNTRA Chat")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    consciousnessIndicator
                }
                #else
                ToolbarItem {
                    consciousnessIndicator
                }
                #endif
            }
        }
    }
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                    
                    if viewModel.isProcessing {
                        TypingIndicatorView()
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 0) {
            if let error = viewModel.errorMessage {
                ErrorBannerView(message: error) {
                    Task { @MainActor in
                        viewModel.errorMessage = nil
                    }
                }
            }
            
            SyntraChatTextInput(
                text: $viewModel.currentInput,
                isProcessing: $viewModel.isProcessing,
                placeholder: "Ask SYNTRA anything..."
            ) {
                await viewModel.processMessage()
            }
            .padding()
        }
        .background(.regularMaterial)
    }
    
    // AGENTS.md: Three-brain consciousness indicator
    private var consciousnessIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(.blue)      // Valon (70%)
                .frame(width: 8, height: 8)
            Circle()
                .fill(.green)     // Modi (30%)
                .frame(width: 8, height: 8)
            Circle()
                .fill(.purple)    // SYNTRA Core
                .frame(width: 8, height: 8)
        }
        .opacity(viewModel.isProcessing ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.5).repeatForever(), value: viewModel.isProcessing)
    }
}

// Supporting Views - REAL IMPLEMENTATION
public struct MessageBubbleView: View {
    let message: SyntraMessage
    
    public var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.role == .user ? .blue : .gray.opacity(0.2))
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // AGENTS.md: Consciousness metrics display
                if let valon = message.valonInfluence, let modi = message.modiInfluence {
                    HStack(spacing: 8) {
                        Text("V: \(Int(valon * 100))%")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text("M: \(Int(modi * 100))%")
                            .font(.caption2)
                            .foregroundColor(.green)
                        if let drift = message.driftScore {
                            Text("D: \(String(format: "%.2f", drift))")
                                .font(.caption2)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            if message.role != .user {
                Spacer()
            }
        }
    }
}

public struct TypingIndicatorView: View {
    @State private var animationPhase = 0
    
    public var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(.gray)
                        .frame(width: 6, height: 6)
                        .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                            value: animationPhase
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                Task { @MainActor in
                    animationPhase = (animationPhase + 1) % 3
                }
            }
        }
    }
}

public struct ErrorBannerView: View {
    let message: String
    let onDismiss: () -> Void
    
    public var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
            Spacer()
            Button("Dismiss", action: onDismiss)
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.orange.opacity(0.1))
    }
} 