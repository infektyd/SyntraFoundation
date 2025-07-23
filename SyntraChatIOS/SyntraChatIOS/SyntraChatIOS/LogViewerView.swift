import SwiftUI
import Foundation
import Combine

// MARK: - Real-Time Log Viewer for SYNTRA Backend Activity
struct LogViewerView: View {
    @StateObject private var logManager = LogManager.shared
    @State private var searchText = ""
    @State private var selectedLogLevel: LogLevel = .all
    @State private var isAutoScrollEnabled = true
    @State private var showingLogExport = false
    
    var filteredLogs: [LogEntry] {
        let levelFiltered = selectedLogLevel == .all ? logManager.logs : 
            logManager.logs.filter { $0.level == selectedLogLevel }
        
        if searchText.isEmpty {
            return levelFiltered
        } else {
            return levelFiltered.filter { 
                $0.message.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Control Panel
                controlPanel
                
                // Log Display
                logDisplay
            }
            .navigationTitle("SYNTRA Backend Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Export") {
                        showingLogExport = true
                    }
                    
                    Button("Clear") {
                        logManager.clearLogs()
                    }
                }
            }
        }
        .sheet(isPresented: $showingLogExport) {
            LogExportView(logs: filteredLogs)
        }
    }
    
    private var controlPanel: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search logs...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // Filter Controls
            HStack {
                Text("Level:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Log Level", selection: $selectedLogLevel) {
                    ForEach(LogLevel.allCases, id: \.self) { level in
                        Text(level.displayName)
                            .foregroundColor(level.color)
                            .tag(level)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Spacer()
                
                Toggle("Auto-scroll", isOn: $isAutoScrollEnabled)
                    .font(.caption)
            }
            
            // Stats
            HStack {
                Text("\(filteredLogs.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if logManager.isRecording {
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("Recording")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private var logDisplay: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(filteredLogs) { entry in
                    LogEntryView(entry: entry)
                        .id(entry.id)
                }
            }
            .listStyle(PlainListStyle())
            .onChange(of: filteredLogs.count) { _ in
                if isAutoScrollEnabled && !filteredLogs.isEmpty {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(filteredLogs.last?.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

// MARK: - Individual Log Entry View
struct LogEntryView: View {
    let entry: LogEntry
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Timestamp
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .leading)
                
                // Level indicator
                Text(entry.level.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(entry.level.color)
                    .frame(width: 50, alignment: .leading)
                
                // Category
                Text(entry.category)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(width: 100, alignment: .leading)
                
                Spacer()
                
                // Expand button for detailed logs
                if entry.hasDetails {
                    Button(action: { isExpanded.toggle() }) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Main message
            Text(entry.message)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(isExpanded ? nil : 3)
            
            // Detailed information when expanded
            if isExpanded && entry.hasDetails {
                VStack(alignment: .leading, spacing: 4) {
                    if let details = entry.details {
                        Text("Details:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(details)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                    }
                    
                    if let location = entry.sourceLocation {
                        Text("Source:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(location)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.blue)
                            .padding(.leading, 8)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
        .background(entry.level.backgroundColor)
        .cornerRadius(6)
        .onTapGesture {
            if entry.hasDetails {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }
        }
    }
}

// MARK: - Log Export View
struct LogExportView: View {
    let logs: [LogEntry]
    @Environment(\.presentationMode) var presentationMode
    @State private var exportText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(exportText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
            }
            .navigationTitle("Export Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        shareLogText()
                    }
                }
            }
        }
        .onAppear {
            generateExportText()
        }
    }
    
    private func generateExportText() {
        exportText = logs.map { entry in
            let timestamp = DateFormatter.logExport.string(from: entry.timestamp)
            return "[\(timestamp)] [\(entry.level.rawValue)] [\(entry.category)] \(entry.message)"
        }.joined(separator: "\n")
    }
    
    private func shareLogText() {
        let activityVC = UIActivityViewController(
            activityItems: [exportText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

// MARK: - Log Management System
@MainActor
class LogManager: ObservableObject {
    static let shared = LogManager()
    
    @Published var logs: [LogEntry] = []
    @Published var isRecording = true
    
    private let maxLogEntries = 1000
    private let queue = DispatchQueue(label: "com.syntra.logmanager", qos: .utility)
    
    private init() {
        setupLogCapture()
    }
    
    private func setupLogCapture() {
        // Capture existing SyntraLogger output
        NotificationCenter.default.addObserver(
            forName: .syntraLogGenerated,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let logInfo = notification.userInfo {
                self?.addLog(from: logInfo)
            }
        }
    }
    
    func addLog(
        message: String,
        level: LogLevel = .info,
        category: String = "General",
        details: String? = nil,
        sourceLocation: String? = nil
    ) {
        guard isRecording else { return }
        
        queue.async { [weak self] in
            let entry = LogEntry(
                message: message,
                level: level,
                category: category,
                details: details,
                sourceLocation: sourceLocation
            )
            
            DispatchQueue.main.async {
                self?.logs.append(entry)
                
                // Keep log count manageable
                if let logs = self?.logs, logs.count > self?.maxLogEntries ?? 1000 {
                    self?.logs.removeFirst(logs.count - (self?.maxLogEntries ?? 1000))
                }
            }
        }
    }
    
    private func addLog(from logInfo: [AnyHashable: Any]) {
        let message = logInfo["message"] as? String ?? "Unknown log"
        let levelString = logInfo["level"] as? String ?? "info"
        let category = logInfo["category"] as? String ?? "General"
        let details = logInfo["details"] as? String
        let location = logInfo["location"] as? String
        
        let level = LogLevel(rawValue: levelString) ?? .info
        
        addLog(
            message: message,
            level: level,
            category: category,
            details: details,
            sourceLocation: location
        )
    }
    
    func clearLogs() {
        logs.removeAll()
    }
    
    func toggleRecording() {
        isRecording.toggle()
    }
}

// MARK: - Log Data Models
struct LogEntry: Identifiable, Sendable {
    let id = UUID()
    let timestamp = Date()
    let message: String
    let level: LogLevel
    let category: String
    let details: String?
    let sourceLocation: String?
    
    var hasDetails: Bool {
        details != nil || sourceLocation != nil
    }
}

enum LogLevel: String, CaseIterable, Sendable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
    case all = "ALL"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        default: return rawValue
        }
    }
    
    var color: Color {
        switch self {
        case .debug: return .gray
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        case .critical: return .purple
        case .all: return .primary
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .debug: return Color.gray.opacity(0.05)
        case .info: return Color.blue.opacity(0.05)
        case .warning: return Color.orange.opacity(0.05)
        case .error: return Color.red.opacity(0.05)
        case .critical: return Color.purple.opacity(0.05)
        case .all: return Color.clear
        }
    }
}

// MARK: - Extensions
extension Notification.Name {
    static let syntraLogGenerated = Notification.Name("syntraLogGenerated")
}

extension DateFormatter {
    static let logExport: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
} 