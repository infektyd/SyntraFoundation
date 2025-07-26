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
        Task { @MainActor in
            switch result {
            case .success(let urls):
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
                
            case .failure(let error):
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
        // Simple PDF text extraction for now
        guard let document = PDFDocument(url: url) else {
            fileImporter.importError = "Failed to load PDF document"
            return
        }
        
        var extractedText = ""
        for i in 0..<document.pageCount {
            if let page = document.page(at: i),
               let pageText = page.string {
                extractedText += pageText + "\n\n"
            }
        }
        
        let processedContent = """
        📄 PDF Processed: \(url.lastPathComponent)
        
        📊 Summary:
        - Original text length: \(extractedText.count) characters
        - Pages processed: \(document.pageCount)
        - Processing: Basic text extraction
        
        📝 Content Preview:
        \(String(extractedText.prefix(1000)))...
        
        [Note: Full PDF processing with Apple Foundation Models will be available in a future update]
        """
        
        // Update imported content
        fileImporter.importedText = processedContent
        fileImporter.importedFileName = url.lastPathComponent
        fileImporter.importError = nil
        
        print("[FileImportView] Successfully processed PDF: \(url.lastPathComponent)")
        print("[FileImportView] Processed content length: \(processedContent.count) characters")
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