import Foundation
import SwiftUI
import UIKit
import SyntraTools
import SyntraConfig

/// iOS-optimized SYNTRA consciousness interface with native iOS features
@MainActor
class SyntraBrain: ObservableObject {
    @Published var isAvailable: Bool = false
    @Published var isProcessing: Bool = false
    @Published var consciousnessState: String = "contemplative_neutral"
    @Published var lastResponse: String = ""
    @Published var networkStatus: NetworkStatus = .unknown
    
    private let syntraCore = SyntraCore()
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    init() {
        setupIOSIntegration()
        checkAvailability()
    }
    
    private func setupIOSIntegration() {
        // Prepare haptic generators
        hapticGenerator.prepare()
        notificationGenerator.prepare()
        
        // Monitor network status for AI features
        checkNetworkStatus()
        
        // Handle iOS app lifecycle
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkAvailability()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.pauseProcessing()
        }
    }
    
    private func checkAvailability() {
        // Check iOS-specific requirements for SYNTRA consciousness
        let isDeviceCapable = ProcessInfo.processInfo.processorCount >= 4
        let hasMinimumMemory = ProcessInfo.processInfo.physicalMemory > 4_000_000_000 // 4GB+
        
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
    
    /// Process user input through unified SYNTRA consciousness with iOS optimizations
    func processMessage(_ input: String) async -> String {
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
        
        // Process through unified SyntraCore with iOS background handling
        let response = await withTaskGroup(of: String.self) { group in
            group.addTask { [weak self] in
                await self?.syntraCore.processInput(trimmedInput) ?? "[Processing error occurred]"
            }
            
            // Add timeout for iOS responsiveness
            group.addTask {
                try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 second timeout
                return "[Response timeout - please try again with a shorter message]"
            }
            
            // Return first completed result
            return await group.next() ?? "[Unknown error]"
        }
        
        // Update published state
        isProcessing = false
        consciousnessState = syntraCore.consciousnessState
        lastResponse = response
        
        // Provide completion feedback
        let isError = response.hasPrefix("[") && response.hasSuffix("]")
        await triggerHapticFeedback(isError ? .error : .success)
        
        print("[SyntraBrain iOS] Response: '\(response)'")
        return response
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