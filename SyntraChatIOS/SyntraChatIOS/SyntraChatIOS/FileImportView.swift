import SwiftUI
import UniformTypeIdentifiers

/// File import component that bypasses iOS/macOS 26 Beta 3 threading crashes
/// Allows importing .md and .txt files instead of using TextField for input
@MainActor
struct FileImportView: View {
    @State private var showFileImporter = false
    @State private var importedText = ""
    @State private var importedFileName = ""
    @State private var importError: String?
    
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
            if !importedFileName.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Imported: \(importedFileName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Error display
            if let error = importError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Imported content preview
            if !importedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Imported Content:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView {
                        Text(importedText)
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
                    importError = "No file selected"
                    return
                }
                
                // Start accessing the security-scoped resource
                guard url.startAccessingSecurityScopedResource() else {
                    importError = "Failed to access file"
                    return
                }
                
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                
                // FIXED: Use newer Data(contentsOf:options:) API for iOS 18 compatibility
                let data = try Data(contentsOf: url, options: [])
                guard let text = String(data: data, encoding: .utf8) else {
                    importError = "Failed to read file as text"
                    return
                }
                
                // Update imported content
                importedText = text
                importedFileName = url.lastPathComponent
                importError = nil
                
                print("[FileImportView] Successfully imported: \(url.lastPathComponent)")
                print("[FileImportView] Content length: \(text.count) characters")
                
            } catch {
                importError = "Import failed: \(error.localizedDescription)"
                print("[FileImportView] Import error: \(error)")
            }
        }
    }
    
    /// Clear imported content
    func clearImportedContent() {
        importedText = ""
        importedFileName = ""
        importError = nil
    }
} 