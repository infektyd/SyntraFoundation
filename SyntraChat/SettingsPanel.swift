import SwiftUI
import SyntraConfig

@available(macOS 26.0, *)
class ConfigViewModel: ObservableObject {
    @Published var useAdaptiveFusion: Bool
    @Published var useAdaptiveWeighting: Bool
    @Published var enableTwoPassLoop: Bool

    init() {
        let cfg = (try? SyntraConfig.loadConfig()) ?? SyntraConfig()
        self.useAdaptiveFusion    = cfg.useAdaptiveFusion ?? false
        self.useAdaptiveWeighting = cfg.useAdaptiveWeighting ?? false
        self.enableTwoPassLoop    = cfg.enableTwoPassLoop ?? false
    }

    func save() {
        var cfg = (try? SyntraConfig.loadConfig()) ?? SyntraConfig()
        cfg.useAdaptiveFusion    = useAdaptiveFusion
        cfg.useAdaptiveWeighting = useAdaptiveWeighting
        cfg.enableTwoPassLoop    = enableTwoPassLoop
        if let data = try? JSONEncoder().encode(cfg) {
            let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .appendingPathComponent("config.json")
            try? data.write(to: url)
        }
    }
}

@available(macOS 26.0, *)
struct SettingsPanel: View {
    @ObservedObject var settings: ConfigViewModel

    var body: some View {
        Form {
            Section("Fusion & Weighting") {
                Toggle("Use Adaptive Fusion",    isOn: $settings.useAdaptiveFusion)
                Toggle("Use Adaptive Weighting", isOn: $settings.useAdaptiveWeighting)
            }
            Section("Feedback Loop") {
                Toggle("Enable Two-Pass Loop", isOn: $settings.enableTwoPassLoop)
            }
            Section {
                Button("Save Settings") {
                    settings.save()
                }
            }
        }
        .padding()
        .frame(minWidth: 200)
    }
}
