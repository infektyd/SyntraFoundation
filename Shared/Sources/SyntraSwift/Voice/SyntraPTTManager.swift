import Foundation
import OSLog

#if canImport(PushToTalk) && os(iOS)
import PushToTalk
#endif

@MainActor
public final class SyntraPTTManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    public static let shared = SyntraPTTManager()
    
    // MARK: - Published Properties
    @Published public var isConnected = false
    @Published public var isTransmitting = false
    @Published public var channelName = "Syntra"
    @Published public var errorMessage: String?
    
    // MARK: - Private Properties
    #if canImport(PushToTalk) && os(iOS)
    @available(iOS 26.0, *)
    private var channelManager: PTChannelManager?
    #endif
    
    private let logger = Logger(subsystem: "SyntraFoundation", category: "PTTManager")
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    // MARK: - Public Interface
    public func initialize(channelName: String = "Syntra") async {
        self.channelName = channelName
        
        #if canImport(PushToTalk) && os(iOS)
        if #available(iOS 16.0, *) {
            await joinPTTChannel()
        } else {
            logger.warning("⚠️ PushToTalk requires iOS 16.0+")
            errorMessage = "PushToTalk requires iOS 16.0 or later"
        }
        #else
        logger.info("📱 PushToTalk not available on this platform")
        errorMessage = "PushToTalk is only available on iOS 16+"
        #endif
    }
    
    public func transmitAudio(from audioURL: URL) async {
        #if canImport(PushToTalk) && os(iOS)
        if #available(iOS 16.0, *), let manager = channelManager {
            do {
                try await manager.requestBeginTransmitting()
                isTransmitting = true
                
                // Stream audio file - simplified implementation
                logger.info("🎤 Starting PTT transmission: \(audioURL.lastPathComponent)")
                
                // TODO: Implement actual audio streaming
                // This would involve reading the audio file and streaming it through PTT
                
                // Simulate transmission duration
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                try await manager.stopTransmitting()
                isTransmitting = false
                
                logger.info("🔇 PTT transmission completed")
                
            } catch {
                isTransmitting = false
                errorMessage = "PTT transmission failed: \(error.localizedDescription)"
                logger.error("❌ PTT transmission error: \(error.localizedDescription)")
            }
        } else {
            logger.warning("⚠️ PTT not initialized, cannot transmit")
            errorMessage = "PTT not available for transmission"
        }
        #else
        logger.info("📱 PTT transmission requested but not available on this platform")
        #endif
    }
    
    public func disconnect() async {
        #if canImport(PushToTalk) && os(iOS)
        if #available(iOS 16.0, *) {
            channelManager = nil
            isConnected = false
            isTransmitting = false
            logger.info("🔌 Disconnected from PTT channel")
        }
        #endif
    }
    
    // MARK: - Private Implementation
    #if canImport(PushToTalk) && os(iOS)
    @available(iOS 26.0, *)
    private func joinPTTChannel() async {
        do {
            // Create channel manager
            channelManager = try await PTChannelManager.channelManager(
                delegate: self,
                restorationDelegate: self
            )
            
            // Create channel descriptor
            let channelImage = createChannelImage()
            let descriptor = PTChannelDescriptor(
                name: channelName,
                image: channelImage
            )
            
            // Join the channel
            try await channelManager?.join(descriptor)
            
            isConnected = true
            errorMessage = nil
            
            logger.info("✅ Successfully joined PTT channel: \(channelName)")
            
        } catch {
            isConnected = false
            errorMessage = "Failed to join PTT channel: \(error.localizedDescription)"
            logger.error("❌ PTT channel join failed: \(error.localizedDescription)")
        }
    }
    
    @available(iOS 26.0, *)
    private func createChannelImage() -> UIImage {
        // Create a simple SYNTRA icon for the PTT channel
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        return UIImage(systemName: "brain.head.profile", withConfiguration: config) 
               ?? UIImage(systemName: "mic.fill", withConfiguration: config)
               ?? UIImage()
    }
    #endif
}

// MARK: - PTChannelManagerDelegate
#if canImport(PushToTalk) && os(iOS)
@available(iOS 26.0, *)
extension SyntraPTTManager: PTChannelManagerDelegate {
    
    public func channelManager(
        _ channelManager: PTChannelManager,
        didBeginTransmittingIn channel: PTChannelDescriptor
    ) {
        Task { @MainActor in
            isTransmitting = true
            logger.info("🎤 PTT transmission started in channel: \(channel.name)")
        }
    }
    
    public func channelManager(
        _ channelManager: PTChannelManager,
        didEndTransmittingIn channel: PTChannelDescriptor
    ) {
        Task { @MainActor in
            isTransmitting = false
            logger.info("🔇 PTT transmission ended in channel: \(channel.name)")
        }
    }
    
    public func channelManager(
        _ channelManager: PTChannelManager,
        receivedEphemeralPushToken pushToken: Data
    ) {
        logger.info("📡 Received PTT ephemeral push token")
    }
}

// MARK: - PTChannelRestorationDelegate
@available(iOS 26.0, *)
extension SyntraPTTManager: PTChannelRestorationDelegate {
    
    public func channelManager(
        _ channelManager: PTChannelManager,
        didRestoreChannel channel: PTChannelDescriptor
    ) {
        Task { @MainActor in
            isConnected = true
            logger.info("🔄 PTT channel restored: \(channel.name)")
        }
    }
}
#endif

// MARK: - Configuration Integration
extension SyntraPTTManager {
    
    public func configure(with voiceConfig: [String: Any]?) {
        guard let voiceConfig = voiceConfig else {
            logger.info("📝 No voice configuration provided")
            return
        }
        
        // Apply voice configuration
        if let channelName = voiceConfig["ptt_channel"] as? String {
            self.channelName = channelName
        }
        
        // Initialize PTT if enabled
        if let usePTT = voiceConfig["use_ptt"] as? Bool, usePTT {
            Task { [weak self] in
                await self?.initialize(channelName: self?.channelName ?? "Syntra")
            }
        }
        
        logger.info("⚙️ PTT configured with channel: \(self.channelName)")
    }
} 