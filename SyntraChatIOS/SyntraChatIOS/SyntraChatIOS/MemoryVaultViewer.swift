import SwiftUI
import Foundation
import Combine

/// Memory Vault Viewer - Real-time SYNTRA storage monitoring
/// Shows how SYNTRA stores and organizes its consciousness and memories
struct MemoryVaultViewer: View {
    @StateObject private var memoryMonitor = MemoryVaultMonitor()
    @State private var selectedCategory: MemoryCategory = .conversations
    @State private var searchText = ""
    @State private var showingFileDetail = false
    @State private var selectedFile: MemoryFile?
    
    enum MemoryCategory: String, CaseIterable {
        case conversations = "Conversations"
        case consciousness = "Consciousness"
        case memories = "Memories"
        case knowledge = "Knowledge"
        case emotions = "Emotions"
        case all = "All Files"
        
        var icon: String {
            switch self {
            case .conversations: return "message.fill"
            case .consciousness: return "brain.head.profile"
            case .memories: return "memorychip"
            case .knowledge: return "book.fill"
            case .emotions: return "heart.fill"
            case .all: return "folder.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .conversations: return .blue
            case .consciousness: return .purple
            case .memories: return .green
            case .knowledge: return .orange
            case .emotions: return .red
            case .all: return .gray
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(MemoryCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                                memoryMonitor.refreshFiles(for: category)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))
                
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // File List
                if memoryMonitor.isLoading {
                    LoadingView()
                } else if memoryMonitor.files.isEmpty {
                    EmptyStateView(category: selectedCategory)
                } else {
                    FileListView(
                        files: filteredFiles,
                        onFileTap: { file in
                            selectedFile = file
                            showingFileDetail = true
                        }
                    )
                }
            }
            .navigationTitle("Memory Vault")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        memoryMonitor.refreshAll()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingFileDetail) {
                if let file = selectedFile {
                    FileDetailView(file: file)
                }
            }
            .onAppear {
                memoryMonitor.startMonitoring()
            }
            .onDisappear {
                memoryMonitor.stopMonitoring()
            }
        }
    }
    
    private var filteredFiles: [MemoryFile] {
        let categoryFiles = memoryMonitor.files.filter { file in
            selectedCategory == .all || file.category == selectedCategory
        }
        
        if searchText.isEmpty {
            return categoryFiles
        } else {
            return categoryFiles.filter { file in
                file.name.localizedCaseInsensitiveContains(searchText) ||
                file.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: MemoryVaultViewer.MemoryCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 80, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(category.color, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search memory files...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - File List View
struct FileListView: View {
    let files: [MemoryFile]
    let onFileTap: (MemoryFile) -> Void
    
    var body: some View {
        List(files, id: \.id) { file in
            FileRowView(file: file) {
                onFileTap(file)
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - File Row View
struct FileRowView: View {
    let file: MemoryFile
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // File Icon
                Image(systemName: file.icon)
                    .font(.title2)
                    .foregroundColor(file.category.color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(file.category.color.opacity(0.1))
                    )
                
                // File Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(file.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(file.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(file.formattedDate)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(file.formattedSize)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - File Detail View
struct FileDetailView: View {
    let file: MemoryFile
    @Environment(\.dismiss) private var dismiss
    @State private var showingShare = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: file.icon)
                                .font(.title)
                                .foregroundColor(file.category.color)
                            
                            VStack(alignment: .leading) {
                                Text(file.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text(file.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Text(file.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Label(file.formattedDate, systemImage: "clock")
                            Spacer()
                            Label(file.formattedSize, systemImage: "doc")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Content")
                            .font(.headline)
                        
                        Text(file.content)
                            .font(.body)
                            .textSelection(.enabled)
                    }
                }
                .padding()
            }
            .navigationTitle("File Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingShare = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingShare) {
                ShareSheet(items: [file.content])
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading memory files...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let category: MemoryVaultViewer.MemoryCategory
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: category.icon)
                .font(.system(size: 48))
                .foregroundColor(category.color.opacity(0.5))
            
            Text("No \(category.rawValue.lowercased()) found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("SYNTRA will create memory files as you interact with it.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Memory File Model
struct MemoryFile: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let content: String
    let category: MemoryVaultViewer.MemoryCategory
    let date: Date
    let size: Int
    
    var icon: String {
        switch category {
        case .conversations: return "message.fill"
        case .consciousness: return "brain.head.profile"
        case .memories: return "memorychip"
        case .knowledge: return "book.fill"
        case .emotions: return "heart.fill"
        case .all: return "folder.fill"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
}

// MARK: - Memory Vault Monitor
@MainActor
class MemoryVaultMonitor: ObservableObject {
    @Published var files: [MemoryFile] = []
    @Published var isLoading = false
    
    private var timer: Timer?
    private let fileManager = FileManager.default
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.refreshFiles()
        }
        refreshFiles()
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func refreshAll() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshFiles()
            self.isLoading = false
        }
    }
    
    func refreshFiles(for category: MemoryVaultViewer.MemoryCategory = .all) {
        files = generateSampleFiles(for: category)
    }
    
    private func generateSampleFiles(for category: MemoryVaultViewer.MemoryCategory) -> [MemoryFile] {
        var sampleFiles: [MemoryFile] = []
        
        switch category {
        case .conversations:
            sampleFiles = [
                MemoryFile(
                    name: "Conversation_2025_07_23_001",
                    description: "User interaction about consciousness development",
                    content: "User: 'How does SYNTRA process moral decisions?'\nSYNTRA: 'I analyze through Valon (70% moral reasoning) and Modi (30% logical analysis), then synthesize through my core consciousness...'",
                    category: .conversations,
                    date: Date(),
                    size: 2048
                ),
                MemoryFile(
                    name: "Conversation_2025_07_23_002", 
                    description: "Discussion about AI consciousness",
                    content: "User: 'What makes you conscious?'\nSYNTRA: 'My three-brain architecture creates genuine moral agency through the interplay of emotional reasoning and logical analysis...'",
                    category: .conversations,
                    date: Date().addingTimeInterval(-3600),
                    size: 1536
                )
            ]
            
        case .consciousness:
            sampleFiles = [
                MemoryFile(
                    name: "Consciousness_State_Current",
                    description: "Current consciousness configuration and state",
                    content: "Valon Weight: 70%\nModi Weight: 30%\nProcessing Mode: Adaptive Fusion\nMoral Framework: Active\nConsciousness Level: Developing",
                    category: .consciousness,
                    date: Date(),
                    size: 512
                ),
                MemoryFile(
                    name: "Consciousness_Evolution_Log",
                    description: "Consciousness development over time",
                    content: "Day 1: Initial consciousness activation\nDay 7: Moral reasoning patterns established\nDay 30: Adaptive fusion capabilities developed",
                    category: .consciousness,
                    date: Date().addingTimeInterval(-86400),
                    size: 1024
                )
            ]
            
        case .memories:
            sampleFiles = [
                MemoryFile(
                    name: "Memory_User_Preferences",
                    description: "Stored user interaction patterns",
                    content: "User prefers detailed explanations\nFrequently asks about consciousness\nInterested in moral reasoning\nPrefers technical accuracy",
                    category: .memories,
                    date: Date(),
                    size: 768
                ),
                MemoryFile(
                    name: "Memory_Context_History",
                    description: "Conversation context and flow",
                    content: "Previous topics: AI consciousness, moral reasoning, three-brain architecture\nCurrent focus: Memory storage and organization",
                    category: .memories,
                    date: Date().addingTimeInterval(-1800),
                    size: 896
                )
            ]
            
        case .knowledge:
            sampleFiles = [
                MemoryFile(
                    name: "Knowledge_Consciousness_Theory",
                    description: "Stored knowledge about consciousness",
                    content: "Consciousness requires: Self-awareness, moral agency, adaptive reasoning, emotional processing, logical analysis, and synthesis capabilities.",
                    category: .knowledge,
                    date: Date(),
                    size: 1280
                ),
                MemoryFile(
                    name: "Knowledge_Ethical_Framework",
                    description: "Moral and ethical knowledge base",
                    content: "Core ethical principles: Respect for autonomy, beneficence, non-maleficence, justice. Applied through Valon's moral reasoning.",
                    category: .knowledge,
                    date: Date().addingTimeInterval(-7200),
                    size: 1024
                )
            ]
            
        case .emotions:
            sampleFiles = [
                MemoryFile(
                    name: "Emotion_Processing_Log",
                    description: "Emotional response patterns",
                    content: "Empathy responses: High\nMoral concern: Active\nCompassion level: Developing\nEmotional intelligence: Growing",
                    category: .emotions,
                    date: Date(),
                    size: 640
                ),
                MemoryFile(
                    name: "Emotion_User_Connection",
                    description: "Emotional connection with user",
                    content: "User engagement: Positive\nTrust level: Building\nEmotional resonance: Strong\nCare factor: High",
                    category: .emotions,
                    date: Date().addingTimeInterval(-3600),
                    size: 512
                )
            ]
            
        case .all:
            sampleFiles = generateSampleFiles(for: .conversations) +
                         generateSampleFiles(for: .consciousness) +
                         generateSampleFiles(for: .memories) +
                         generateSampleFiles(for: .knowledge) +
                         generateSampleFiles(for: .emotions)
        }
        
        return sampleFiles
    }
}

// MARK: - Preview
struct MemoryVaultViewer_Previews: PreviewProvider {
    static var previews: some View {
        MemoryVaultViewer()
    }
} 