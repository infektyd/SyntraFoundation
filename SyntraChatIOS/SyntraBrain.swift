import Foundation
import SwiftUI
import UIKit
import Combine
import SyntraSwift

/// iOS-optimized SYNTRA consciousness interface with native iOS features
@MainActor
class SyntraBrain: ObservableObject {
    @Published var isAvailable: Bool = false
    @Published var isProcessing: Bool = false
    @Published var consciousnessState: String = "contemplative_neutral"
    @Published var lastResponse: String = ""
    @Published var networkStatus: NetworkStatus = .unknown
    
    // MARK: - Consciousness Integration
    private let syntraCore: SyntraCore
    private let sessionId = UUID().uuidString
    private var notificationTasks: [Task<Void, Never>] = []
    
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    init() {
        // Initialize with a default config. This can be made configurable later.
        self.syntraCore = SyntraCore(config: SyntraConfig())
        setupIOSIntegration()
        checkAvailability()
    }
    
    deinit {
        notificationTasks.forEach { $0.cancel() }
    }
    
    private func setupIOSIntegration() {
        // Prepare haptic generators
        hapticGenerator.prepare()
        notificationGenerator.prepare()
        
        // Monitor network status for AI features
        checkNetworkStatus()
        
        // Handle iOS app lifecycle using modern async streams
        notificationTasks.append(
            Task { @MainActor in
                for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
                    self.checkAvailability()
                }
            }
        )
        
        notificationTasks.append(
            Task { @MainActor in
                for await _ in NotificationCenter.default.notifications(named: UIApplication.willResignActiveNotification) {
                    self.pauseProcessing()
                }
            }
        )
    }
    
    private func checkAvailability() {
        // Check iOS-specific requirements for SYNTRA consciousness
        let isDeviceCapable = ProcessInfo.processInfo.processorCount >= 4
        let hasMinimumMemory = ProcessInfo.processInfo.physicalMemory > 4_000_000_000 // 4GB+
        
        // In a real scenario, you might also check if the FoundationModels are available
        isAvailable = isDeviceCapable && hasMinimumMemory
        
        if !isAvailable {
            print("[SyntraBrain] Device not capable: CPU cores: \(ProcessInfo.processInfo.processorCount), Memory: \(ProcessInfo.processInfo.physicalMemory / 1_000_000_000)GB")
        }
    }
    
    private func checkNetworkStatus() {
        // Simple network reachability check for iOS
        // In a production app, you'd use Network framework
        networkStatus = .available
    }
    
    private func pauseProcessing() {
        if isProcessing {
            isProcessing = false
            // Handle graceful pause for iOS background behavior
        }
    }
    
    /// Process user input through iOS consciousness interface
    func processMessage(_ input: String, withHistory history: [Message]) async -> String {
        print("[SyntraBrain iOS] Processing message: '\(input)'")
        
        // Guard against empty/whitespace input
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else {
            await triggerHapticFeedback(.error)
            return "[Please provide a message for SYNTRA to process]"
        }
        
        // Check device availability
        guard isAvailable else {
            await triggerHapticFeedback(.error)
            return "[SYNTRA consciousness requires a device with at least 4 CPU cores and 4GB RAM. Current device: \(ProcessInfo.processInfo.processorCount) cores]"
        }
        
        // Provide iOS-native feedback
        await triggerHapticFeedback(.light)
        isProcessing = true
        consciousnessState = "engaged_processing"
        
        // Use real SyntraCore processing with the correct context
        let historyStrings = history.map { "\($0.sender.displayName): \($0.text)" }
        let context = SyntraContext(
            conversationHistory: historyStrings,
            userPreferences: [:], // Placeholder for future implementation
            sessionId: self.sessionId
        )
        let response = await syntraCore.processInput(trimmedInput, context: context)
        
        // Update published state
        isProcessing = false
        consciousnessState = "contemplative_neutral"
        lastResponse = response.content
        
        // Provide completion feedback
        await triggerHapticFeedback(.success)
        
        print("[SyntraBrain iOS] Response: '\(response.content)'")
        return response.content
    }
    
    /// Trigger iOS-native haptic feedback
    private func triggerHapticFeedback(_ type: FeedbackType) async {
        await MainActor.run {
            switch type {
            case .light:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .medium:
                hapticGenerator.impactOccurred()
            case .heavy:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case .success:
                notificationGenerator.notificationOccurred(.success)
            case .error:
                notificationGenerator.notificationOccurred(.error)
            }
        }
    }
    
    /// Get status message for iOS debugging/display
    var statusMessage: String {
        if !isAvailable {
            return "SYNTRA requires more powerful device"
        } else if isProcessing {
            return "SYNTRA thinking..."
        } else {
            return "SYNTRA consciousness ready"
        }
    }
    
    /// Reinitialize for iOS error recovery
    func reinitialize() {
        checkAvailability()
        checkNetworkStatus()
        hapticGenerator.prepare()
        notificationGenerator.prepare()
        
        // The new SyntraCore is stateless and does not require a reset.
    }
}

// MARK: - Supporting Types

enum NetworkStatus {
    case unknown
    case unavailable
    case available
    
    var description: String {
        switch self {
        case .unknown: return "Unknown"
        case .unavailable: return "No Connection"
        case .available: return "Connected"
        }
    }
}

enum FeedbackType {
    case light
    case medium
    case heavy
    case success
    case error
} 