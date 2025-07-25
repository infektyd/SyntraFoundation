<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

# Research and analyze the latest advances in voice-to-text technology for iOS applications in 2024-2025, focusing on:

TECHNICAL COMPARISON:
• Compare OpenAI Whisper vs Apple SFSpeechRecognizer vs new iOS 26 SpeechAnalyzer in terms of accuracy, latency, and user experience
• Evaluate on-device vs cloud-based speech recognition trade-offs for privacy and performance
• Analyze real-time streaming transcription architectures vs traditional batch processing

IMPLEMENTATION FOCUS:
• WhisperKit framework by Argmax - detailed technical analysis, integration complexity, performance benchmarks
• Swift-native voice processing libraries and their adoption rates in production apps
• Modern iOS voice input UX patterns that users prefer over traditional hold-to-talk buttons

USE CASES TO EXAMINE:
• Real-time conversation transcription (meetings, interviews)
• Voice-to-text for AI assistants and chatbots
• Accessibility applications requiring high accuracy
• Multilingual support and automatic language detection

RESEARCH SOURCES:
• GitHub repositories with high star counts and recent activity
• Apple WWDC 2024-2025 sessions on speech technologies
• Production app case studies from major iOS developers
• Academic papers on edge device speech recognition
• Developer blogs discussing migration from SFSpeechRecognizer

DELIVER:
• Pros/cons comparison table of top 3 solutions
• Code implementation complexity assessment
• Performance benchmarks if available
• User experience impact analysis
• Migration strategy recommendations for existing iOS apps

Focus on solutions that can be implemented in production iOS apps in 2025, emphasizing accuracy improvements over current standard implementations.

Now I'll create a comprehensive analysis report based on the extensive research gathered, organized according to the user's specific requirements.

## Voice-to-Text Technology for iOS Applications 2024-2025: Comprehensive Technical Analysis

### Executive Summary

The iOS voice-to-text landscape has undergone significant transformation in 2024-2025, headlined by Apple's introduction of **SpeechAnalyzer** in iOS 26, which represents a major evolution from the aging SFSpeechRecognizer framework. This analysis reveals three dominant approaches: Apple's new on-device SpeechAnalyzer, the continuing evolution of OpenAI Whisper (particularly through WhisperKit), and cloud-based solutions. For AI applications building with Apple Foundation Models, the integration of SpeechAnalyzer with on-device intelligence creates unprecedented opportunities for private, responsive voice interfaces.

## Technical Comparison: Core Technologies

### Apple SpeechAnalyzer (iOS 26) vs Traditional Solutions

**SpeechAnalyzer Architecture**[^1][^2]

- **On-device processing**: Complete privacy with local model execution
- **Long-form audio support**: Optimized for lectures, meetings, and conversations (vs. SFSpeechRecognizer's short-form limitations)
- **Automatic language management**: No user configuration required
- **Low latency**: Real-time transcription without accuracy compromise
- **Timeline-based operations**: Uses audio timeline timecodes for precise correlation

**Performance Benchmarks**[^3][^4][^5]

- **Speed advantage**: Apple's new API transcribed a 34-minute video in 45 seconds vs. MacWhisper's 101% faster than OpenAI Whisper)
- **Accuracy trade-offs**: 3% character error rate and 8% word error rate vs. Whisper's 0.3% CER and 1% WER
- **Real-time capabilities**: 9 seconds processing time for 7:31 minute audio file vs. Whisper's 40 seconds


### OpenAI Whisper vs Apple SpeechAnalyzer

| Feature | OpenAI Whisper | Apple SpeechAnalyzer | Winner |
| :-- | :-- | :-- | :-- |
| **Accuracy** | CER: 0.3%, WER: 1% | CER: 3%, WER: 8% | Whisper |
| **Speed** | 40 seconds (7:31 audio) | 9 seconds (7:31 audio) | SpeechAnalyzer |
| **Privacy** | Cloud-dependent | On-device only | SpeechAnalyzer |
| **Language Support** | 50+ languages | Growing list with regular additions | Whisper |
| **Integration Complexity** | Moderate (requires WhisperKit for iOS) | Native iOS, 3 lines of code | SpeechAnalyzer |
| **Use Case** | High-accuracy transcription | Real-time, privacy-focused apps | Context-dependent |

### On-Device vs Cloud-Based Trade-offs

**On-Device Advantages**[^6][^7][^8]

- **Zero latency**: No network round-trips
- **100% privacy**: Data never leaves device
- **Offline capability**: Functions without internet connectivity
- **No API costs**: Free inference after model download
- **Consistent performance**: Not affected by network fluctuations

**Cloud-Based Advantages**[^6][^7][^8]

- **Higher accuracy**: Access to larger, more sophisticated models
- **Unlimited processing power**: Can handle complex audio scenarios
- **Multilingual expertise**: Better support for diverse languages and accents
- **Continuous updates**: Models improve without app updates
- **Specialized features**: Advanced punctuation, speaker diarization

**Recommendation for AI Apps**: For applications integrating with Apple Foundation Models, prioritize on-device solutions (SpeechAnalyzer + Foundation Models) for privacy and real-time responsiveness, with cloud fallback for specialized requirements.

## WhisperKit Framework: Deep Technical Analysis

### Performance and Integration Assessment

**Technical Specifications**[^9][^10][^11]

- **Real-time performance**: 70x realtime transcription with large-v2 model
- **Memory efficiency**: Requires <8GB GPU memory for large-v2 with beam_size=5
- **Hardware acceleration**: Native Apple Neural Engine (ANE) implementation
- **Model compression**: 1.6GB to 0.6GB (60% reduction) while maintaining accuracy within 1% WER

**Integration Complexity**[^9][^11]

```swift
// Basic WhisperKit implementation
import WhisperKit

Task {
    let pipe = try? await WhisperKit()
    let transcription = try? await pipe!.transcribe(audioPath: "path/to/audio.wav")?.text
    print(transcription)
}
```

**Production Benchmarks**[^12][^13][^10]

- **M3 Max performance**: 0.46s latency with 2.2% WER
- **iOS 18 improvements**: 40% performance increase (165 to 237 tokens/second)
- **Energy efficiency**: Optimized for battery life and thermal sustainability
- **Model variants**: Support for distilled models and custom fine-tuning


### Competitive Analysis: WhisperKit vs Alternatives

| Framework | Real-time Performance | Accuracy (WER) | Integration Effort | On-device |
| :-- | :-- | :-- | :-- | :-- |
| **WhisperKit** | 42x real-time | 2.2% | Low (Swift native) | Yes |
| **whisper.cpp** | Varies by device | Similar to OpenAI | Moderate (C++ bridge) | Yes |
| **OpenAI API** | Network dependent | 0.3% CER, 1% WER | Low (API calls) | No |
| **Apple SpeechAnalyzer** | Real-time optimized | 3% CER, 8% WER | Very low (3 lines) | Yes |

## Real-Time Streaming Architecture Analysis

### Streaming vs Batch Processing

**Streaming Architecture Challenges**[^14][^10]

- **Whisper limitations**: Native 30-second chunk processing creates inefficiencies
- **WhisperKit solution**: Modified audio encoder supports native streaming
- **Latency optimization**: Streaming reduces 60+ forward passes to single-pass processing
- **Memory management**: Efficient buffer handling for continuous audio streams

**Modern Streaming Implementations**[^15][^16][^17]

```swift
// SpeechAnalyzer streaming implementation
let transcriber = SpeechTranscriber(locale: locale, preset: .offlineTranscription)
let analyzer = SpeechAnalyzer(modules: [transcriber])

// Stream audio buffers
func streamAudioToTranscriber(_ buffer: AVAudioPCMBuffer) async throws {
    let converted = try converter.convertBuffer(buffer, to: analyzerFormat)
    let input = AnalyzerInput(buffer: converted)
    inputBuilder.yield(input)
}
```

**Performance Comparison: Streaming vs Batch**[^18]

- **Streaming accuracy penalty**: 6-7% WER increase when formatting required
- **Real-time benefits**: Immediate user feedback and interaction
- **Battery impact**: Streaming requires continuous processing resources
- **Use case suitability**: Live transcription, voice commands vs. file processing


## Swift-Native Voice Processing Libraries

### Current Ecosystem Analysis

**Primary Swift Libraries**[^19][^20][^21]

1. **Talkify**: Comprehensive speech recognition and synthesis
    - SFSpeechRecognizer and AVSpeechSynthesizer integration
    - RxSwift, Combine, TCA support
    - Multilingual capabilities with custom voice models
2. **Compiler-Inc/Transcriber**: Modern SFSpeechRecognizer wrapper
    - Actor-based interface for thread safety
    - Automatic silence detection
    - Custom language model support
3. **SwiftSpeech**: SwiftUI-focused framework
    - Automatic audio engine and authorization handling
    - SwiftUI-native syntax and components

**Production Adoption Rates**[Based on GitHub metrics]

- **WhisperKit**: 1,800+ stars, active enterprise adoption
- **Talkify**: Growing developer community, comprehensive feature set
- **Native SFSpeechRecognizer**: Still dominant but declining for new projects


### Migration from SFSpeechRecognizer

**Key Migration Drivers**[^1][^2][^22]

- **iOS 26 deprecation signals**: Apple pushing developers toward SpeechAnalyzer
- **Performance limitations**: SFSpeechRecognizer's 1-minute timeout and server dependency
- **Privacy concerns**: Cloud processing requirements for older framework
- **Feature gaps**: Limited long-form audio and distant microphone support

**Migration Strategy Recommendations**

1. **Immediate**: Begin SpeechAnalyzer integration for iOS 26+ targets
2. **Gradual**: Maintain SFSpeechRecognizer for older iOS versions
3. **Hybrid approach**: Use availability checks to leverage best framework per device

## Modern iOS Voice Input UX Patterns

### Beyond Hold-to-Talk: Contemporary Approaches

**Current UX Innovations**[^23][^24][^25]

1. **Contextual activation**: Voice input triggered by app state rather than button press
2. **Multi-modal interfaces**: Seamless switching between voice, touch, and visual inputs
3. **Continuous listening**: Background voice detection with privacy indicators
4. **Visual feedback integration**: Real-time transcript display with audio playback sync

**User Preference Analysis**[^23]

- **52% of users prefer voice-assisted technology** over traditional interfaces
- **Accessibility focus**: Voice UI critical for users with mobility limitations
- **Context awareness**: 81% prefer personalized voice interactions based on usage patterns

**Implementation Patterns**

```swift
// Modern voice input pattern
struct VoiceInputView: View {
    @State private var isListening = false
    @State private var transcript = ""
    
    var body: some View {
        VStack {
            // Visual feedback for voice state
            VoiceWaveformView(isActive: isListening)
            
            // Real-time transcript display
            ScrollView {
                Text(transcript)
                    .transition(.opacity)
            }
            
            // Multi-modal activation
            HStack {
                VoiceActivationButton(isActive: $isListening)
                TextInputFallback()
            }
        }
    }
}
```


## Use Case Implementation Analysis

### Real-Time Conversation Transcription

**Technical Requirements**[^26][^27][^28]

- **Speaker diarization**: Automatic speaker identification and labeling
- **Live transcript generation**: Real-time text output with speaker attribution
- **Audio synchronization**: Timestamp correlation for playback alignment
- **Export capabilities**: Meeting notes, action items, and summaries

**Production Examples**[^27][^29][^28]

- **Otter.ai**: 300 minutes free monthly, real-time transcription with AI summaries
- **Read AI**: iPhone app for in-person meetings with automatic speaker detection
- **Apple's Live Captions**: System-level implementation in iOS 26


### Voice-to-Text for AI Assistants Integration

**Apple Foundation Models Integration**[^30][^31][^32]

```swift
// Combining SpeechAnalyzer with Foundation Models
import FoundationModels
import Speech

class AIAssistantManager {
    private let speechAnalyzer = SpeechAnalyzer()
    private let languageModel = SystemLanguageModel.default
    
    func processVoiceInput() async {
        // 1. Capture and transcribe audio
        let transcript = await speechAnalyzer.transcribe(audioInput)
        
        // 2. Process with Foundation Models
        let session = LanguageModelSession()
        let response = try await session.prompt(transcript.text)
        
        // 3. Generate voice response
        synthesizeResponse(response.text)
    }
}
```

**Key Integration Benefits**[^30][^33]

- **On-device processing**: Complete privacy for sensitive AI interactions
- **No API costs**: Free inference using Apple's models
- **Offline capability**: Full functionality without internet connectivity
- **Swift-native**: Seamless integration with just 3 lines of code


### Accessibility Applications

**High-Accuracy Requirements**[^34][^26][^35]

- **Live Captions**: iOS 26 system-level transcription for hearing accessibility
- **VoiceOver integration**: Automatic language detection and switching
- **Custom vocabulary**: Medical, legal, and technical term accuracy
- **Error correction**: User feedback loops for improved recognition

**Implementation Considerations**

- **Accuracy thresholds**: Medical/legal applications require >99% accuracy
- **Fallback mechanisms**: Multiple input methods for recognition failures
- **Compliance requirements**: WCAG guidelines and accessibility standards


### Multilingual Support and Language Detection

**Current Capabilities**[^36][^37][^38]

- **iOS 26 improvements**: Automatic language detection in voice input
- **Multilingual keyboards**: Automatic language switching based on content
- **15 language support**: Foundation Models framework multilingual capability
- **Regional variations**: Support for dialects and regional language differences

**Technical Implementation**[^39][^36]

```swift
// Automatic language detection
let speechRecognizer = SFSpeechRecognizer()
let supportedLocales = SFSpeechRecognizer.supportedLocales()

// iOS 26 preferred locales approach
let preferredLocales = Locale.preferredLocales
let matchedLocales = matchUserPreferences(preferredLocales, supportedLocales)
```


## Performance Benchmarks Summary

### Comprehensive Speed and Accuracy Analysis

**Speed Performance Rankings**[^3][^5][^18][^40]

1. **Apple SpeechAnalyzer**: 9 seconds (7:31 audio) - 55% faster than Whisper
2. **WhisperKit**: 42x real-time with optimized configurations
3. **OpenAI Whisper**: 40 seconds (7:31 audio) baseline
4. **Cloud APIs**: Variable based on network conditions

**Accuracy Performance Rankings**[^3][^18][^40]

1. **OpenAI Whisper**: 0.3% CER, 1% WER (highest accuracy)
2. **Google Gemini**: Excellent for accents and technical vocabulary
3. **Apple SpeechAnalyzer**: 3% CER, 8% WER (good for real-time)
4. **AssemblyAI**: Strong unformatted accuracy, formatting challenges

### Device-Specific Performance

**Apple Neural Engine Optimization**[^10][^41]

- **M3 Max**: 237 tokens/second with WhisperKit
- **iPhone 15 Pro**: Real-time transcription with <1 second latency
- **Memory requirements**: 3B parameter model fits in 8GB unified memory
- **Energy efficiency**: Optimized for sustained transcription sessions


## Migration Strategy Recommendations

### For Existing iOS Apps

**Immediate Actions (2025)**

1. **Assess current implementation**: Evaluate SFSpeechRecognizer usage and limitations
2. **iOS 26 compatibility**: Begin SpeechAnalyzer integration for supported devices
3. **WhisperKit evaluation**: Consider for apps requiring high accuracy offline processing
4. **User experience audit**: Review voice input patterns and user feedback

**Gradual Migration Path**

```swift
// Version-aware implementation
@available(iOS 26.0, *)
func useSpeechAnalyzer() {
    // New SpeechAnalyzer implementation
    let transcriber = SpeechTranscriber(locale: locale)
    let analyzer = SpeechAnalyzer(modules: [transcriber])
}

func fallbackToSFSpeech() {
    // Maintain SFSpeechRecognizer for older versions
    let recognizer = SFSpeechRecognizer(locale: locale)
}
```

**Long-term Strategy (2025-2026)**

- **Full SpeechAnalyzer adoption**: As iOS 26+ adoption increases
- **Foundation Models integration**: For AI-powered applications
- **Privacy-first approach**: Emphasize on-device processing benefits
- **Performance optimization**: Leverage Apple Silicon capabilities


### For New AI Applications

**Recommended Architecture**

1. **Primary**: SpeechAnalyzer + Apple Foundation Models
2. **Enhancement**: WhisperKit for specialized accuracy requirements
3. **Fallback**: Cloud APIs for unsupported scenarios
4. **User choice**: Allow users to select privacy vs. accuracy preferences

**Implementation Timeline**

- **Phase 1**: Core voice input with SpeechAnalyzer
- **Phase 2**: Foundation Models integration for AI processing
- **Phase 3**: Advanced features (speaker diarization, multilingual)
- **Phase 4**: Performance optimization and user experience refinement


## Conclusion and Future Outlook

The iOS voice-to-text landscape in 2024-2025 presents unprecedented opportunities for developers building AI applications. Apple's introduction of SpeechAnalyzer represents a paradigm shift toward privacy-first, on-device processing that aligns perfectly with the Foundation Models framework. While traditional solutions like OpenAI Whisper maintain accuracy advantages, the combination of SpeechAnalyzer's speed, privacy, and seamless integration with Apple's AI infrastructure creates compelling advantages for modern iOS applications.

For developers building AI apps with Apple Foundation Models, the path forward is clear: embrace the on-device ecosystem while maintaining strategic flexibility through hybrid implementations. The convergence of high-performance voice recognition, on-device AI processing, and privacy-preserving architecture positions iOS as the premier platform for next-generation voice-enabled AI experiences.

The migration from legacy frameworks like SFSpeechRecognizer to SpeechAnalyzer should be prioritized, with careful attention to user experience design that moves beyond traditional hold-to-talk patterns toward more natural, contextual voice interactions. As Apple continues to refine these technologies, developers who invest in the integrated ecosystem will be best positioned to deliver compelling, private, and responsive voice-AI experiences.

<div style="text-align: center">⁂</div>

[^1]: https://dev.to/arshtechpro/wwdc-2025-the-next-evolution-of-speech-to-text-using-speechanalyzer-6lo

[^2]: https://developer.apple.com/videos/play/wwdc2025/277/

[^3]: https://www.heise.de/en/news/Speech-to-text-Apple-s-new-APIs-outperform-Whisper-on-speed-10475273.html

[^4]: https://www.communeify.com/en/blog/apple-speech-api-vs-whisper-speed-accuracy-test/

[^5]: https://appleinsider.com/articles/25/06/18/apple-intelligence-transcription-is-twice-as-fast-as-openais-whisper

[^6]: https://picovoice.ai/blog/on-device-speech-recognition/

[^7]: https://zilliz.com/ai-faq/what-are-the-differences-between-cloudbased-and-ondevice-speech-recognition

[^8]: https://milvus.io/ai-quick-reference/what-are-the-differences-between-cloudbased-and-ondevice-speech-recognition

[^9]: https://github.com/argmaxinc/WhisperKit

[^10]: https://www.arxiv.org/pdf/2507.10860.pdf

[^11]: https://transloadit.com/devtips/transcribe-audio-on-ios-macos-whisperkit/

[^12]: https://github.com/argmaxinc/WhisperKit/issues/5

[^13]: https://huggingface.co/argmaxinc/whisperkit-coreml

[^14]: https://arxiv.org/html/2507.10860v1

[^15]: https://deepgram.com/learn/ios-live-transcription

[^16]: https://docs.videosdk.live/ios/guide/video-and-audio-calling-api-sdk/transcription-and-summary/realtime-transcribe-meeting

[^17]: https://www.youtube.com/watch?v=vIqZq1UYBOA

[^18]: https://voicewriter.io/blog/best-speech-recognition-api-2025

[^19]: https://github.com/tornikegomareli/Talkify

[^20]: https://github.com/Compiler-Inc/Transcriber

[^21]: https://www.reddit.com/r/SwiftUI/comments/hzqv8o/i_made_a_speech_recognition_package_for_swiftui/

[^22]: https://www.andyibanez.com/posts/speech-recognition-sfspeechrecognizer/

[^23]: https://moldstud.com/articles/p-the-future-of-voice-ui-in-ios-app-development

[^24]: https://www.eleken.co/blog-posts/mobile-ux-design-examples

[^25]: https://www.smashingmagazine.com/2022/02/voice-user-interfaces-guide/

[^26]: https://support.apple.com/guide/iphone/get-live-captions-of-spoken-audio-iphe0990f7bb/ios

[^27]: https://apps.apple.com/us/app/otter-transcribe-voice-notes/id1276437113

[^28]: https://www.read.ai/post/read-ai-launches-iphone-app-for-in-person-meetings

[^29]: https://otter.ai

[^30]: https://machinelearning.apple.com/research/apple-foundation-models-2025-updates

[^31]: https://www.artemnovichkov.com/blog/getting-started-with-apple-foundation-models

[^32]: https://developer.apple.com/apple-intelligence/

[^33]: https://appleinsider.com/articles/25/07/21/how-apple-made-ai-in-ios-26-more-helpful-more-private

[^34]: https://convergeaccessibility.com/2025/07/07/ios-26-accessibility-blind-iphone-users/

[^35]: https://tactiq.io/audio-to-text/voice-to-text-iphone

[^36]: https://developer.apple.com/videos/play/wwdc2025/222/

[^37]: https://www.youtube.com/watch?v=6AGCk8K8Rkk

[^38]: https://discussions.apple.com/thread/254559405

[^39]: https://www.reddit.com/r/shortcuts/comments/bmwvu7/multilanguage_support_with_automatic_language/

[^40]: https://www.willowtreeapps.com/craft/10-speech-to-text-models-tested

[^41]: https://machinelearning.apple.com/research/conformer-based-speech

[^42]: https://en.wikipedia.org/wiki/IOS_version_history

[^43]: https://www.apple.com/os/ios/

[^44]: https://appcircle.io/blog/wwdc25-bring-advanced-speech-to-text-capabilities-to-your-app-with-speechanalyzer

[^45]: https://apps.apple.com/us/app/speech-to-text-ai-note-taker/id1150900877

[^46]: https://gigazine.net/gsc_news/en/20250619-apple-speech-analyzer/

[^47]: https://vomo.ai/blog/best-ios-app-for-free-speech-to-text-transcribe-in-2024

[^48]: https://markellisreviews.com/tech-news/ios-26/

[^49]: https://www.gladia.io/blog/openai-whisper-vs-google-speech-to-text-vs-amazon-transcribe

[^50]: https://www.techradar.com/news/best-speech-to-text-app

[^51]: https://otter.ai/blog/best-speech-to-text-app?0db891cc_page=30\&28959088_page=2\&7bd4a6f3_page=1

[^52]: https://speechcentral.net/2025/06/27/missing-iphone-voices-restore-ava-samantha-other-favorites-on-ios-17-18-and-ios-26/

[^53]: https://deepgram.com/learn/deepgram-vs-openai-vs-google-stt-accuracy-latency-price-compared

[^54]: https://www.notta.ai/en/blog/best-speech-to-text-app

[^55]: https://www.alvareztg.com/apple-wwdc-2025/

[^56]: https://huggingface.co/datasets/argmaxinc/whisperkit-evals

[^57]: https://www.linkedin.com/posts/argmaxinc_whisperkit-is-40-faster-on-ios-18-improved-activity-7208851314166886403-WbRh

[^58]: https://stackoverflow.com/questions/78713631/compiling-for-ios-15-0-but-module-whisperkit-has-a-minimum-deployment-target

[^59]: https://www.argmaxinc.com/blog/speakerkit

[^60]: https://github.com/argmaxinc/whisperkittools

[^61]: https://www.youtube.com/watch?v=b10OHCDHDQ4

[^62]: https://model.aibase.com/models/details/1915693359613763586

[^63]: https://sourceforge.net/projects/whisperkit.mirror/

[^64]: https://www.argmaxinc.com/blog/apple-and-argmax

[^65]: https://www.argmaxinc.com/blog/whisperkit

[^66]: https://blog.stackademic.com/integrate-whisper-cpp-in-ios-b2f2873c2c69

[^67]: https://swiftpackageindex.com/argmaxinc/WhisperKit

[^68]: https://www.newscaststudio.com/2024/06/11/apple-ios-16-call-recording-transcription/

[^69]: https://platform.openai.com/docs/guides/realtime

[^70]: https://dev.to/codebymattz/roadmap-for-ios-development-in-2024-4bel

[^71]: https://uxdesign.cc/why-great-conversationalists-make-great-designers-c845039b9ab5

[^72]: https://galileo.ai/blog/best-real-time-speech-to-text-tools

[^73]: https://dev.to/julia_8cb077bca5/cloud-solutions-vs-on-premise-speech-recognition-systems-1378

[^74]: https://www.interaction-design.org/literature/article/ui-form-design

[^75]: https://www.reddit.com/r/selfhosted/comments/196quf9/app_for_transcribing_audio_in_real_time/

[^76]: https://www.sensory.com/wake-word-revalidation-in-the-cloud/

[^77]: https://cloud.google.com/blog/products/ai-machine-learning/speech-on-device-run-server-quality-speech-ai-locally

[^78]: https://www.reddit.com/r/macapps/comments/1huwfvu/fully_local_ai_app_for_realtime_meeting/

[^79]: https://learn.g2.com/best-voice-recognition-software

[^80]: https://www.gladia.io/blog/best-open-source-speech-to-text-models

[^81]: https://www.read.ai/platforms/ios

[^82]: https://elevenlabs.io/speech-to-text

[^83]: https://www.youtube.com/watch?v=Nf9Gmdm9C2c

[^84]: https://www.meetjamie.ai/blog/10-best-speech-to-text-software

[^85]: https://fellow.app/blog/meetings/best-meeting-transcription-apps/

[^86]: https://zapier.com/blog/best-text-dictation-software/

[^87]: https://developer.apple.com/documentation/xcode/supporting-multiple-languages-in-your-app

[^88]: https://www.microsoft.com/en-us/garage/profiles/group-transcribe/

[^89]: https://github.com/m-bain/whisperX

[^90]: https://github.com/gromb57/ios-wwdc23__RecognizingSpeechInLiveAudio

[^91]: https://github.com/SpeechColab/GigaSpeech

[^92]: https://github.com/FunAudioLLM/SenseVoice

