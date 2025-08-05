<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

# 📜 SyntraFoundation – Voice Architecture Blueprint

*(PTT Framework -  SpeechAnalyzer -  Hold-to-Talk Control)*

> Drop this file **`VOICE_INTEGRATION_GUIDE.md`** in the repo root.
> It’s written for Claude 4 Sonnet (Cursor IDE) and any human collaborators.

## 0. Objectives

1. **Local, trust-worthy voice input**
    - Hold-to-talk UI element (custom SwiftUI view)
    - Streams mic audio to **SpeechAnalyzer** for on-device transcription.
2. **System-grade voice sessions**
    - Adopt Apple **PushToTalk (PTT) framework** to get Dynamic Island pill, lock-screen Talk button, accessory support, battery-safe background audio.
3. **Unified Syntra pipeline**
    - Final transcripts flow into existing **Valon / Modi / Drift / MemoryEngine**.
    - Spoken responses (ElevenLabs or Apple TTS) returned via PTT as the *remote speaker* for transparency.

## 1. High-Level Flow 🗺️

```mermaid
graph LR
A(PTT or Hold Button) -- mic buffers --> B(AudioEngine)
B --> C(SpeechAnalyzer)
C --> D{Transcript}
D -->|final| E[Syntra Brain\n(Valon · Modi · Drift)]
E --> F(Response Text)
F --> G(TTS)
G -->|audio| H(PTT activeRemoteParticipant)
```

*When PTT channel inactive, step H is skipped and audio plays via normal `AVAudioPlayer`.*

## 2. Module Checklist

| Module | New Targets / Files | Key APIs | Done? |
| :-- | :-- | :-- | :-- |
| **Hold-to-Talk Control** | `SyntraSwift/UI/PTTButton.swift` | `DragGesture(minimumDistance:0)` | ☐ |
| **Audio Capture** | `SyntraSwift/Voice/HoldToTalkRecorder.swift` | `AVAudioEngine` + `installTap` | ☐ |
| **SpeechAnalyzer** | `SyntraSwift/Voice/TranscriptionEngine.swift` | `SpeechAnalyzer` · `SpeechTranscriber` | ☐ |
| **PTT Channel Manager** | `SyntraSwift/Voice/SyntraPTTManager.swift` | `PTChannelManager`, `PTChannelDescriptor`, `activeRemoteParticipant` | ☐ |
| **Brain Bridge** | Extend `ValonProcessor.swift` \& friends | Accept transcript string, return reply | — |
| **Voice Out** | `SyntraSwift/Voice/SpeechOut.swift` | ElevenLabs or `AVSpeechSynthesizer`; PTT playback hook | ☐ |
| **Config Hooks** | Update `config.json` \& loader | flags: `use_ptt`, `use_speech_analyzer` | ☐ |
| **Unit Tests** | `tests/VoicePipelineTests.swift` | Fake audio, transcript injection | ☐ |

## 3. Implementation Steps

### 3.1  Add Capabilities \& Entitlements

```text
Project → Signing & Capabilities
  • Background Modes  ➜  Push to Talk, Audio, Voice Processing
  • Push Notifications
  • Push to Talk Entitlement (com.apple.developer.push-to-talk)
```

> **Info.plist** must keep `NSMicrophoneUsageDescription`.

### 3.2  Swift Package Updates

In **`Package.swift`**

```swift
.platforms = [
  .iOS("26.0"), // SpeechAnalyzer & PTT need iOS 26
]
```


### 3.3  Hold-to-Talk Control (UI)

```swift
public struct PTTButton: View {
    @State private var isDown = false
    let start: () -> Void
    let stop: () -> Void

    public var body: some View {
        Circle()
            .fill(isDown ? .red : .accentColor)
            .frame(width: 80, height: 80)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in if !isDown { isDown = true; start() } }
                    .onEnded   { _ in isDown = false; stop() }
            )
            .accessibilityLabel("Hold to talk to Syntra")
    }
}
```


### 3.4  Audio Capture + SpeechAnalyzer

```swift
final class HoldToTalkRecorder {
    private let engine = AVAudioEngine()
    private var analyzer: SpeechAnalyzer!
    private var transcriber: SpeechTranscriber!
    private var continuation: AsyncStream<AnalyzerInput>.Continuation?

    func start(locale: Locale = .current) async throws {
        transcriber = SpeechTranscriber(locale: locale, preset: .offlineTranscription)
        analyzer    = SpeechAnalyzer(modules:[transcriber])

        let inputNode = engine.inputNode
        let format    = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus:0, bufferSize:2048, format:format) { [weak self] buf,_ in
            self?.continuation?.yield(.init(buffer: buf))
        }
        try engine.start()
        continuation = transcriber.prepareForStreaming()
        Task { await collect() }
    }

    func stop() async {
        engine.inputNode.removeTap(onBus:0)
        engine.stop()
        continuation?.finish()
        try? await analyzer.finalizeAndFinishThroughEndOfInput()
    }

    private func collect() async {
        for await res in transcriber.results where res.isFinal {
            await SyntraBrain.shared.handle(transcript: res.text)
        }
    }
}
```


### 3.5  PTT Channel Manager

```swift
final class SyntraPTTManager: NSObject, PTChannelManagerDelegate, PTChannelRestorationDelegate {
    static let shared = SyntraPTTManager()
    private var manager: PTChannelManager?

    func join() async throws {
        manager = try await PTChannelManager.channelManager(delegate:self, restorationDelegate:self)
        let desc = PTChannelDescriptor(name:"Syntra", image: UIImage(named:"syntra")!)
        try await manager?.join(desc)
    }

    // MARK: - Send / Receive
    func transmit(_ audio: URL) {
        Task { try? await manager?.requestBeginTransmitting() }
        // stream audio file bytes…
    }

    // MARK: - Delegate
    func channelManager(_ cm: PTChannelManager, didBeginTransmittingIn channel: PTChannelDescriptor) { }
    func channelManager(_ cm: PTChannelManager, didEndTransmittingIn channel: PTChannelDescriptor) { }
}
```


### 3.6  Route Replies Through PTT (optional)

```swift
func speak(_ text: String) {
    let audioURL = TTS.generate(text)
    SyntraPTTManager.shared.transmit(audioURL)
}
```


## 4. Configuration Flags

`config.json`

```jsonc
{
  "voice": {
    "use_ptt": true,
    "use_speech_analyzer": true,
    "ptt_channel": "Syntra"
  }
}
```


## 5. Testing Matrix

| Scenario | Expected Behaviour |
| :-- | :-- |
| **Button press / release** | Mic indicator on → transcript appears in logs → Syntra responds |
| **Screen locked + Dynamic Island** | PTT pill shows; hold to talk still streams |
| **Bluetooth PTT accessory** | Accessory triggers transmit without opening UI |
| **AirPods Pro** | Press force sensor → start Talk, Siri interruption handled |
| **Low-battery** | Framework suspends; resume works on re-join |
| **Legacy device (< iOS 26)** | Falls back to SFSpeechRecognizer with same `PTTButton` |

Automate with `VoicePipelineTests.swift` using prerecorded CAF files.

## 6. Documentation TODO

- Update `README.md` with voice-feature badges
- Add `VOICE_PRIVACY.md` describing on-device processing \& indicators
- Record demo GIF of Dynamic Island + button


## 7. Milestones

1. **M-1** Hold-to-talk control + SpeechAnalyzer (🎯 ETA 1 week)
2. **M-2** PTT channel join / transmit playback (🎯 ETA 2 weeks)
3. **M-3** Multi-agent speaker UI (optional) (🎯 ETA 3 weeks)
4. **M-4** QA pass \& App Store TestFlight (🎯 ETA 4 weeks)

### 🚀 When all checkboxes are green, Syntra speaks and listens like a system-grade, privacy-first Walkie-Talkie AI.

