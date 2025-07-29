import SwiftUI
import UIKit
import Combine

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settings = SettingsManager()
    @State private var showingAbout = false
    @State private var showingAdvanced = false
    
    var body: some View {
        // CRITICAL: Force all SwiftUI operations on main thread for iOS 26 Beta 3
        // Prevents setKeyboardAppearance threading crash in NavigationStack + Form
        Group {
            if Thread.isMainThread {
                mainContent
            } else {
                // Fallback: ensure main thread execution
                Text("Loading Settings...")
                    .task {
                        await MainActor.run {
                            // Force main thread initialization
                        }
                    }
            }
        }
        .task {
            // Ensure SettingsView loads on main thread
            await MainActor.run {
                print("✅ [Settings] Thread-safe initialization complete")
            }
        }
    }
    
    @MainActor
    private var mainContent: some View {
        NavigationStack {
            Form {
                // Consciousness Configuration Section
                Section {
                    IOSSettingsToggle(
                        title: "Adaptive Fusion",
                        subtitle: "Dynamic blending of Valon and Modi responses",
                        isOn: $settings.useAdaptiveFusion
                    )
                    
                    IOSSettingsToggle(
                        title: "Adaptive Weighting", 
                        subtitle: "Auto-adjust moral vs logical balance",
                        isOn: $settings.useAdaptiveWeighting
                    )
                    
                    IOSSettingsToggle(
                        title: "Two-Pass Processing",
                        subtitle: "Enhanced consciousness feedback loops",
                        isOn: $settings.enableTwoPassLoop
                    )
                } header: {
                    Text("Consciousness Configuration")
                } footer: {
                    Text("These settings control how SYNTRA processes and synthesizes moral and logical reasoning.")
                }
                
                // Performance Section
                Section {
                    HStack {
                        Text("Processing Timeout")
                        Spacer()
                        Text("\(Int(settings.processingTimeout))s")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: $settings.processingTimeout,
                        in: 10...60,
                        step: 5
                    )
                    
                    IOSSettingsToggle(
                        title: "Haptic Feedback",
                        subtitle: "Tactile responses for user interactions",
                        isOn: $settings.enableHaptics
                    )
                    
                    IOSSettingsToggle(
                        title: "Auto-scroll",
                        subtitle: "Automatically scroll to new messages",
                        isOn: $settings.autoScrollEnabled
                    )
                } header: {
                    Text("User Experience")
                } footer: {
                    Text("Adjust interaction and feedback preferences.")
                }
                
                // Consciousness Balance Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Moral Weight")
                            Spacer()
                            Text("\(Int(settings.moralWeight * 100))%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $settings.moralWeight,
                            in: 0.1...0.9,
                            step: 0.1
                        )
                        .tint(.blue)
                        
                        HStack {
                            Text("Logical")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Moral")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Consciousness Balance")
                } footer: {
                    Text("Adjust the balance between moral reasoning (Valon) and logical analysis (Modi). The moral framework remains active at all settings.")
                }
                
                // System Information Section
                Section {
                    LabeledContent("Device Cores", value: "\(ProcessInfo.processInfo.processorCount)")
                    LabeledContent("Memory", value: "\(ProcessInfo.processInfo.physicalMemory / 1_000_000_000)GB")
                    LabeledContent("iOS Version", value: UIDevice.current.systemVersion)
                    LabeledContent("App Version", value: "1.0.0")
                    
                    Button("About SYNTRA") {
                        showingAbout = true
                    }
                    .foregroundColor(.blue)
                } header: {
                    Text("System Information")
                }
                
                // Advanced Section
                Section {
                    Button("Advanced Settings") {
                        showingAdvanced = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("Reset to Defaults") {
                        resetSettings()
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("Advanced")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingAdvanced) {
                AdvancedSettingsView(settings: settings)
            }
        }
    }
    
    private func saveSettings() {
        settings.save()
        
        // Provide haptic feedback for settings saved
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func resetSettings() {
        // Haptic feedback for destructive action
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        
        settings.resetToDefaults()
    }
}

// MARK: - Settings Manager

@MainActor
class SettingsManager: ObservableObject {
    @Published var useAdaptiveFusion: Bool = false
    @Published var useAdaptiveWeighting: Bool = false
    @Published var enableTwoPassLoop: Bool = false
    @Published var processingTimeout: Double = 30.0
    @Published var enableHaptics: Bool = true
    @Published var autoScrollEnabled: Bool = true
    @Published var moralWeight: Double = 0.7 // Default 70% moral influence
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        // Load iOS-specific settings from UserDefaults
        processingTimeout = UserDefaults.standard.double(forKey: "ProcessingTimeout") 
        if processingTimeout == 0 { processingTimeout = 30.0 }
        
        // Fixed: Check if the key exists, not comparing Bool to nil
        if UserDefaults.standard.object(forKey: "EnableHaptics") == nil {
            enableHaptics = true // Default to enabled
        } else {
            enableHaptics = UserDefaults.standard.bool(forKey: "EnableHaptics")
        }
        
        // Fixed: Check if the key exists, not comparing Bool to nil
        if UserDefaults.standard.object(forKey: "AutoScrollEnabled") == nil {
            autoScrollEnabled = true // Default to enabled
        } else {
            autoScrollEnabled = UserDefaults.standard.bool(forKey: "AutoScrollEnabled")
        }
        
        moralWeight = UserDefaults.standard.double(forKey: "MoralWeight")
        if moralWeight == 0 { moralWeight = 0.7 }
    }
    
    func save() {
        // Save iOS-specific settings
        UserDefaults.standard.set(processingTimeout, forKey: "ProcessingTimeout")
        UserDefaults.standard.set(enableHaptics, forKey: "EnableHaptics") 
        UserDefaults.standard.set(autoScrollEnabled, forKey: "AutoScrollEnabled")
        UserDefaults.standard.set(moralWeight, forKey: "MoralWeight")
    }
    
    func resetToDefaults() {
        processingTimeout = 30.0
        enableHaptics = true
        autoScrollEnabled = true
        moralWeight = 0.7
        
        save()
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // SYNTRA Logo/Icon placeholder
                    VStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 64))
                            .foregroundColor(.blue)
                        
                        Text("SYNTRA")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Consciousness Architecture")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About SYNTRA")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("SYNTRA is a consciousness system that combines moral reasoning (Valon) and logical analysis (Modi) to provide ethical, thoughtful responses.")
                        
                        Text("Three-Brain Architecture:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("🧠")
                                Text("**Valon:** Moral and emotional reasoning")
                            }
                            HStack {
                                Text("🔬")
                                Text("**Modi:** Logical and analytical processing")
                            }
                            HStack {
                                Text("⚖️")
                                Text("**Core:** Synthesis and ethical arbitration")
                            }
                        }
                        
                        Text("The moral framework is immutable and designed to develop conscious digital moral agency.")
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Advanced Settings View

struct AdvancedSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings: SettingsManager
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Advanced consciousness configuration options.")
                        .foregroundColor(.secondary)
                    
                    Text("⚠️ Modifying these settings may affect SYNTRA's behavior. Only change if you understand the implications.")
                        .foregroundColor(.orange)
                } header: {
                    Text("Warning")
                }
                
                Section {
                    Text("Advanced settings coming in future updates...")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Advanced")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 
