import SwiftUI
import Combine
import UniformTypeIdentifiers
import PDFKit

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
            allowedContentTypes: [.plainText, .init(filenameExtension: "md")!, .pdf],
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
                
                // Handle different file types
                if url.pathExtension.lowercased() == "pdf" {
                    await handlePDFImport(url)
                } else {
                    await handleTextFileImport(url)
                }
                
            } catch {
                fileImporter.importError = "Import failed: \(error.localizedDescription)"
                print("[FileImportView] Import error: \(error)")
            }
        }
    }
    
    private func handleTextFileImport(_ url: URL) async {
        do {
            let data = try Data(contentsOf: url, options: [])
            guard let text = String(data: data, encoding: .utf8) else {
                fileImporter.importError = "Failed to read file as text"
                return
            }
            
            // Update imported content
            fileImporter.importedText = text
            fileImporter.importedFileName = url.lastPathComponent
            fileImporter.importError = nil
            
            print("[FileImportView] Successfully imported text file: \(url.lastPathComponent)")
            print("[FileImportView] Content length: \(text.count) characters")
            
        } catch {
            fileImporter.importError = "Failed to read text file: \(error.localizedDescription)"
        }
    }
    
    private func handlePDFImport(_ url: URL) async {
        do {
            // Use our new Swift PDF processor
            let result = try await PDFProcessor.processPDF(
                path: url.path,
                provider: .apple,
                mode: .balanced
            )
            
            // Format the processed content for display
            let processedContent = """
            📄 PDF Processed: \(url.lastPathComponent)
            
            📊 Summary:
            - Original text length: \(result.originalText.count) characters
            - Chunks processed: \(result.chunks.count)
            - Processing mode: \(result.processingMode)
            
            📝 Key Insights:
            \(result.insights["valon"] ?? "No Valon insights available")
            
            🔧 Technical Analysis:
            \(result.insights["modi"] ?? "No Modi analysis available")
            
            📋 Full Summary:
            \(result.summaries.joined(separator: "\n\n"))
            """
            
            // Update imported content
            fileImporter.importedText = processedContent
            fileImporter.importedFileName = url.lastPathComponent
            fileImporter.importError = nil
            
            print("[FileImportView] Successfully processed PDF: \(url.lastPathComponent)")
            print("[FileImportView] Processed content length: \(processedContent.count) characters")
            
        } catch {
            fileImporter.importError = "PDF processing failed: \(error.localizedDescription)"
            print("[FileImportView] PDF processing error: \(error)")
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