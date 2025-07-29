import SwiftUI

@available(iOS 26.0, *)
struct OfflineStatusView: View {
    @ObservedObject var syntraCore: SyntraCore
    
    var body: some View {
        HStack {
            // Offline indicator
            Circle()
                .fill(syntraCore.isOffline ? Color.orange : Color.green)
                .frame(width: 8, height: 8)
            
            Text(syntraCore.isOffline ? "Offline" : "Online")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if syntraCore.syncStatus != "ready" {
                Text("• \(syntraCore.syncStatus)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
}

@available(iOS 26.0, *)
struct CrashTestView: View {
    @ObservedObject var syntraCore: SyntraCore
    @State private var showingDebugLogs = false
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Debug Information")
                .font(.headline)
            
            // System status info
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Processing:")
                    Text(syntraCore.isProcessing ? "Active" : "Idle")
                        .foregroundColor(syntraCore.isProcessing ? .orange : .green)
                }
                
                HStack {
                    Text("Network:")
                    Text(syntraCore.isOffline ? "Offline" : "Online")
                        .foregroundColor(syntraCore.isOffline ? .red : .green)
                }
                
                HStack {
                    Text("Sync Status:")
                    Text(syntraCore.syncStatus)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Consciousness State:")
                    Text(syntraCore.consciousnessState)
                        .foregroundColor(.purple)
                }
            }
            .font(.caption)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            Button("View Real-Time Backend Logs") {
                showingDebugLogs = true
            }
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
        }
        .padding()
        .sheet(isPresented: $showingDebugLogs) {
            LogViewerView()
        }
    }
}

struct DebugLogsView: View {
    let logs: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(logs)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
            }
            .navigationTitle("Debug Logs")
        }
    }
} 