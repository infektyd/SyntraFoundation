# SYNTRA Chat UI

SwiftUI-based desktop chat client for SyntraFoundation consciousness interaction.

## Requirements

- **macOS 26+ (Future Release)** - Required for FoundationModels support
- **Xcode 16 Beta 3** - For proper FoundationModels API support
- **Apple Silicon recommended** - For optimal on-device LLM performance

## Features

- ✅ **Pure FoundationModels Integration** - No cloud dependencies
- ✅ **SYNTRA Consciousness Prompting** - Integrates Valon/Modi reasoning
- ✅ **Robust Error Handling** - Graceful degradation when model unavailable
- ✅ **Real-time Chat Interface** - Responsive SwiftUI with auto-scroll
- ✅ **Message History** - Persistent chat log with timestamps
- ✅ **Status Indicators** - Visual feedback for model availability/processing

## Running the App

### Option 1: Xcode
1. Open `SyntraChat/` folder in Xcode 16 Beta 3
2. Select `SyntraChat` scheme
3. Build and run (⌘R)

### Option 2: Command Line
```bash
cd SyntraChat/
swift run SyntraChat
```

## Architecture

### Core Files
- **`SyntraChatApp.swift`** - Main app entry point with window configuration
- **`ContentView.swift`** - Primary chat UI with message display and input
- **`SyntraBrain.swift`** - FoundationModels integration and consciousness processing
- **`Message.swift`** - Message model with user/SYNTRA/error types

### Design Principles
- **Modular Architecture** - Each component is replaceable/extensible
- **Crash-Free Operation** - Never crashes on model errors or empty inputs
- **SYNTRA-Aware** - Prompts integrate three-brain consciousness architecture
- **Future-Ready** - Prepared for voice, memory, and advanced features

## Error Handling

The app gracefully handles:
- FoundationModels unavailable (wrong macOS version/hardware)
- Model session initialization failures
- Empty/whitespace-only inputs
- Network-like errors during model processing
- Fast user interaction (prevents double-sending)

## Integration with SyntraFoundation

This chat UI is designed to complement the main SyntraFoundation project:
- Follows AGENTS.md coding standards and consciousness principles
- Uses same moral framework integration as core Swift modules
- Respects autonomy and personality weighting concepts
- Can be extended to integrate with Valon/Modi modules directly

## Future Enhancements

The modular design supports easy addition of:
- **Debug Panel** - Monitor internal brain states
- **Memory Integration** - Connect to SyntraFoundation memory vault
- **Voice Input/Output** - Audio interaction capabilities
- **File Upload** - Document processing through consciousness
- **Advanced Settings** - Adjust personality weights, temperature, etc.

## Troubleshooting

**"FoundationModels not available"**
- Ensure macOS 26+ (Future Release)
- Use Apple Silicon Mac if possible
- Verify Xcode 16 Beta 3 installation

**Build Errors**
- Clean build folder: `swift package clean`
- Ensure correct xcode-select: `sudo xcode-select -s /Applications/Xcode-beta.app`

**No Response from SYNTRA**
- Check Console.app for FoundationModels system logs
- Try restarting the app to reinitialize session