import SwiftUI
import Combine
import UniformTypeIdentifiers

/// File import component that bypasses iOS/macOS 26 Beta 3 threading crashes
/// Allows importing .md and .txt files instead of using TextField for input
@MainActor
struct FileImportView: View {
    @EnvironmentObject var fileImporter: FileImportManager
    @State private var showFileImporter = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Import button
            Button(action: {
                showFileImporter = true
            }) {
                HStack {
                    Image(systemName: "doc.badge.plus")
                    Text("Import File")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            // Success display
            if !fileImporter.importedFileName.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Imported: \(fileImporter.importedFileName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Error display
            if let error = fileImporter.importError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Imported content preview
            if !fileImporter.importedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Imported Content:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView {
                        Text(fileImporter.importedText)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.thinMaterial)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 200)
                }
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.plainText, .init(filenameExtension: "md")!],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }
    
    // MARK: - File Import Methods
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        // CRITICAL: Ensure file operations on main thread - Beta 3 threading fix
        DispatchQueue.main.async {
            do {
                let urls = try result.get()
                guard let url = urls.first else {
                    fileImporter.importError = "No file selected"
                    return
                }
                
                // Start accessing the security-scoped resource
                guard url.startAccessingSecurityScopedResource() else {
                    fileImporter.importError = "Failed to access file"
                    return
                }
                
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                
                // FIXED: Use newer Data(contentsOf:options:) API for iOS 18 compatibility
                let data = try Data(contentsOf: url, options: [])
                guard let text = String(data: data, encoding: .utf8) else {
                    fileImporter.importError = "Failed to read file as text"
                    return
                }
                
                // Update imported content
                fileImporter.importedText = text
                fileImporter.importedFileName = url.lastPathComponent
                fileImporter.importError = nil
                
                print("[FileImportView] Successfully imported: \(url.lastPathComponent)")
                print("[FileImportView] Content length: \(text.count) characters")
                
            } catch {
                fileImporter.importError = "Import failed: \(error.localizedDescription)"
                print("[FileImportView] Import error: \(error)")
            }
        }
    }
    
    /// Clear imported content
    func clearImportedContent() {
        fileImporter.importedText = ""
        fileImporter.importedFileName = ""
        fileImporter.importError = nil
    }
}

// MARK: - File Import Manager
@MainActor
class FileImportManager: ObservableObject {
    @Published var importedText: String = ""
    @Published var importedFileName: String = ""
    @Published var importError: String?
    
    func clearContent() {
        importedText = ""
        importedFileName = ""
        importError = nil
    }
} 