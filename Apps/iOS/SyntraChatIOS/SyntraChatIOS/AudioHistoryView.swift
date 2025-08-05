/*
 * AudioHistoryView.swift - TEMPORARILY DISABLED
 * 
 * This audio recording history feature has been temporarily disabled
 * as we're using native Apple voice input instead. This code is preserved
 * for future development when custom voice recording functionality may be needed.
 * 
 * Disabled date: Current development phase
 * Reason: Using native iOS Speech framework instead
 * 
 * Previous functionality:
 * - Displayed history of voice recordings with playback capabilities
 * - Managed local audio files and transcription data
 * - Native dictation has no separate audio history - integrated seamlessly
 * 
 * Replacement: Native dictation has no separate audio history - integrated seamlessly
 */

/*
import SwiftUI
import AVFoundation

// Local recording session model (simplified version)
struct RecordingSession: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let duration: TimeInterval
    let audioFileURL: URL
    let transcriptionText: String?
}

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
    @State private var currentlyPlayingSession: RecordingSession?
    @State private var showingDeleteAlert = false
    @State private var sessionToDelete: RecordingSession?
    
    var body: some View {
        NavigationView {
            Group {
                if recorder.recordingSessions.isEmpty {
                    ContentUnavailableView(
                        "No Recordings",
                        systemImage: "mic.slash",
                        description: Text("Your voice recordings will appear here")
                    )
                } else {
                    List {
                        ForEach(recorder.recordingSessions.reversed()) { session in
                            RecordingRowView(
                                session: session,
                                isPlaying: currentlyPlayingSession?.id == session.id,
                                onPlay: { playRecording(session) },
                                onStop: { stopPlayback() },
                                onDelete: { deleteRecording(session) }
                            )
                        }
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
    }
    
    private func playRecording(_ session: RecordingSession) {
        stopPlayback() // Stop any currently playing recording
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: session.audioFileURL)
            audioPlayer?.prepareToPlay()
            
            audioPlayerDelegate = AudioPlayerDelegate(onFinished: {
                currentlyPlayingSession = nil
            })
            audioPlayer?.delegate = audioPlayerDelegate
            
            currentlyPlayingSession = session
            audioPlayer?.play()
        } catch {
            print("Failed to play recording: \(error.localizedDescription)")
        }
    }
    
    private func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        audioPlayerDelegate = nil
        currentlyPlayingSession = nil
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
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.timestamp, style: .date)
                    .font(.headline)
                
                Text(session.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let transcription = session.transcriptionText {
                    Text(transcription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(formatDuration(session.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    if isPlaying {
                        onStop()
                    } else {
                        onPlay()
                    }
                }) {
                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(isPlaying ? .red : .blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
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
*/ 