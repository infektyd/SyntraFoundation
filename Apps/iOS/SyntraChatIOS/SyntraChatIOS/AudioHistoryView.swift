/*
 * AudioHistoryView.swift - DEPRECATED
 * 
 * This audio recording history feature has been deprecated as part of the migration
 * to Apple's native dictation support. Native dictation doesn't create separate
 * audio files that need to be managed, making this history view unnecessary.
 * 
 * Migration date: Based on os changes.md plan
 * Replacement: Native dictation has no separate audio history - integrated seamlessly
 */

import SwiftUI
import AVFoundation
import Combine

// Local recording session model (simplified version)
struct RecordingSession: Identifiable, Codable {
    var id = UUID()
    let timestamp: Date
    let duration: TimeInterval
    let transcript: String
    let audioFileURL: URL
    let fileSize: Int64
}

// Simple local recorder manager
class LocalAudioRecorder: ObservableObject {
    @Published var recordingSessions: [RecordingSession] = []
    
    init() {
        loadRecordingSessions()
    }
    
    private func loadRecordingSessions() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let sessionsURL = documentsPath.appendingPathComponent("recordingSessions.json")
        
        do {
            let data = try Data(contentsOf: sessionsURL)
            recordingSessions = try JSONDecoder().decode([RecordingSession].self, from: data)
        } catch {
            print("No previous recording sessions found")
            recordingSessions = []
        }
    }
    
    private func saveRecordingSessions() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let sessionsURL = documentsPath.appendingPathComponent("recordingSessions.json")
        
        do {
            let data = try JSONEncoder().encode(recordingSessions)
            try data.write(to: sessionsURL)
        } catch {
            print("Failed to save recording sessions: \(error.localizedDescription)")
        }
    }
    
    func deleteRecording(_ session: RecordingSession) {
        // Remove file
        try? FileManager.default.removeItem(at: session.audioFileURL)
        
        // Remove from array
        recordingSessions.removeAll { $0.id == session.id }
        saveRecordingSessions()
        
        print("Recording deleted: \(session.audioFileURL.lastPathComponent)")
    }
}

struct AudioHistoryView: View {
    @StateObject private var recorder = LocalAudioRecorder()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioPlayerDelegate: AudioPlayerDelegate?
    @State private var currentlyPlaying: UUID?
    @State private var isPlaying = false
    @State private var showingDeleteAlert = false
    @State private var sessionToDelete: RecordingSession?
    
    var body: some View {
        NavigationView {
            List {
                if recorder.recordingSessions.isEmpty {
                    ContentUnavailableView(
                        "No Recordings",
                        systemImage: "mic.slash",
                        description: Text("Your voice recordings will appear here")
                    )
                } else {
                    ForEach(recorder.recordingSessions.reversed()) { session in
                        RecordingRowView(
                            session: session,
                            isPlaying: currentlyPlaying == session.id && isPlaying,
                            onPlay: { playRecording(session) },
                            onStop: { stopPlayback() },
                            onDelete: { deleteRecording(session) }
                        )
                    }
                }
            }
            .navigationTitle("Voice Recordings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        clearAllRecordings()
                    }
                    .disabled(recorder.recordingSessions.isEmpty)
                }
            }
        }
        .alert("Delete Recording", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let session = sessionToDelete {
                    recorder.deleteRecording(session)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this recording?")
        }
    }
    
    private func playRecording(_ session: RecordingSession) {
        stopPlayback() // Stop any current playback
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: session.audioFileURL)
            
            // Create and store delegate to prevent deallocation
            audioPlayerDelegate = AudioPlayerDelegate(onFinished: {
                currentlyPlaying = nil
                isPlaying = false
            })
            audioPlayer?.delegate = audioPlayerDelegate
            
            currentlyPlaying = session.id
            isPlaying = true
            audioPlayer?.play()
            
        } catch {
            print("Failed to play recording: \(error.localizedDescription)")
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        audioPlayerDelegate = nil
        currentlyPlaying = nil
        isPlaying = false
    }
    
    private func deleteRecording(_ session: RecordingSession) {
        sessionToDelete = session
        showingDeleteAlert = true
    }
    
    private func clearAllRecordings() {
        for session in recorder.recordingSessions {
            recorder.deleteRecording(session)
        }
    }
}

struct RecordingRowView: View {
    let session: RecordingSession
    let isPlaying: Bool
    let onPlay: () -> Void
    let onStop: () -> Void
    let onDelete: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: session.timestamp)
    }
    
    private var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: session.duration) ?? "0s"
    }
    
    private var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: session.fileSize, countStyle: .file)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.headline)
                    
                    Text("\(formattedDuration) • \(formattedFileSize)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack {
                    Button(action: isPlaying ? onStop : onPlay) {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if !session.transcript.isEmpty {
                Text(session.transcript)
                    .font(.body)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Text("No transcript available")
                    .font(.body)
                    .italic()
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Audio Player Delegate
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    let onFinished: () -> Void
    
    init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinished()
    }
}

#Preview {
    AudioHistoryView()
} 