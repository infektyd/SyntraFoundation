# SYNTRA CLI Test - LLM Agnostic PDF Processing

This is a **Swift-based CLI tool** that replicates the Python PDF ingestion functionality for SYNTRA, supporting multiple LLM providers including **Apple Foundation Models**, **OpenAI GPT**, and **Google Gemini**.

## Purpose

- **Test** the conversion from Python to Swift for SYNTRA's document processing
- **Compare** different LLM providers for SYNTRA consciousness processing
- **Future-proof** the codebase by abstracting LLM dependencies
- **Enable** faster on-device processing with Apple Foundation Models

## Features

✅ **LLM Provider Agnostic** - Switch between Apple, OpenAI, and Gemini models  
✅ **PDF Text Extraction** - Using native PDFKit  
✅ **Intelligent Chunking** - Overlapping text segments for context preservation  
✅ **SYNTRA Consciousness Processing** - VALON + MODI analysis  
✅ **JSON Output** - Compatible with Python pipeline format  
✅ **Environment-based Configuration** - Secure API key management  

## Installation & Setup

### 1. Build the CLI

```bash
cd SyntraCLITest
swift build -c release
```

### 2. Set API Keys (Environment Variables)

```bash
# For OpenAI
export OPENAI_API_KEY="your-openai-api-key-here"

# For Google Gemini  
export GEMINI_API_KEY="your-gemini-api-key-here"

# Apple Foundation Models - No API key needed (on-device)
```

### 3. Run Tests

```bash
# Test with Apple Foundation Models (default, no API key needed)
./syntra-cli document.pdf

# Test with OpenAI GPT
./syntra-cli document.pdf --provider openai

# Test with Google Gemini (your API key)
./syntra-cli document.pdf --provider gemini
```

## Usage Examples

### Basic Usage
```bash
# Process a PDF with Apple Foundation Models
./syntra-cli "1995 Dodge Ram Service Manual.pdf"
```

### Provider-Specific Testing
```bash
# Compare outputs across providers
./syntra-cli document.pdf --provider apple > apple_results.json
./syntra-cli document.pdf --provider openai > openai_results.json  
./syntra-cli document.pdf --provider gemini > gemini_results.json
```

### Batch Processing
```bash
# Process multiple PDFs
for pdf in *.pdf; do
    echo "Processing $pdf..."
    ./syntra-cli "$pdf" --provider apple
    mv syntra_output.json "${pdf%.*}_syntra.json"
done
```

## Expected Output

The CLI generates a comprehensive JSON file with:

```json
{
  "documentMetadata": {
    "filename": "document.pdf",
    "totalCharacters": 25000,
    "totalChunks": 12,
    "processingDate": "2025-01-27T10:30:00Z",
    "llmProvider": "apple"
  },
  "chunkAnalyses": [
    {
      "chunkIndex": 0,
      "valonAnalysis": {
        "emotionalTone": "neutral",
        "symbolicMeaning": "Technical documentation represents...",
        "intuitiveInsights": ["Human impact assessment", "Cultural implications"]
      },
      "modiAnalysis": {
        "keyFacts": ["Fact 1", "Fact 2"],
        "logicalRelationships": ["A → B because...", "C leads to D"],
        "analyticalConclusions": ["Therefore X", "Evidence suggests Y"]
      },
      "synthesis": {
        "integratedUnderstanding": "Combined VALON+MODI perspective...",
        "actionableInsights": ["Recommendation 1", "Suggestion 2"],
        "confidenceScore": 0.85
      }
    }
  ],
  "globalInsights": {
    "overallValonSentiment": "positive",
    "primaryThemes": ["Theme 1", "Theme 2"],
    "consensusScore": 0.78,
    "recommendedActions": ["Action 1", "Action 2"]
  }
}
```

## API Provider Setup

### Google Gemini API

1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Create a new project or select existing
3. Generate an API key
4. Set environment variable: `export GEMINI_API_KEY="your-key"`

**Gemini API Features:**
- **Model**: `gemini-1.5-pro` (latest with 1M+ token context)
- **Safety Settings**: Configured for document analysis
- **Cost**: Pay-per-use pricing
- **Context Window**: Massive (perfect for large PDFs)

### OpenAI API

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Create API key
3. Set environment variable: `export OPENAI_API_KEY="your-key"`

### Apple Foundation Models

- **No API key required** - runs entirely on-device
- **Available on**: macOS 15+, iOS 18+
- **Privacy**: Complete local processing
- **Models**: Base, refined, instruction-tuned variants

## Performance Comparison

| Provider | Speed | Privacy | Cost | Context | Quality |
|----------|-------|---------|------|---------|---------|
| **Apple** | ⚡⚡⚡ Fastest | 🔒 Complete | 💰 Free | ~8K tokens | ⭐⭐⭐ |
| **Gemini** | ⚡⚡ Fast | ☁️ Cloud | 💰💰 Low | ~1M tokens | ⭐⭐⭐⭐ |
| **OpenAI** | ⚡ Moderate | ☁️ Cloud | 💰💰💰 High | ~128K tokens | ⭐⭐⭐⭐⭐ |

## Integration with Main SYNTRA

Once validated, this CLI can be integrated into the main SYNTRA system by:

1. **Moving LLM abstraction** to shared Swift package
2. **Updating iOS app** to use local Apple Foundation Models
3. **Replacing Python PDF pipeline** with Swift version
4. **Maintaining API compatibility** for existing workflows

## Testing Strategy

### Phase 1: Functional Testing
- ✅ PDF text extraction accuracy
- ✅ Chunking preservation 
- ✅ VALON/MODI processing logic
- ✅ JSON output compatibility

### Phase 2: Quality Comparison  
- 📊 Compare outputs vs Python pipeline
- 📊 Evaluate VALON vs MODI insights
- 📊 Measure consensus scores
- 📊 Assess provider differences

### Phase 3: Performance Testing
- ⚡ Processing speed benchmarks
- 💾 Memory usage analysis  
- 🔋 Battery impact (mobile)
- 💰 Cost analysis per provider

## Troubleshooting

### Common Issues

**"Apple Foundation Models not available"**
- Update to macOS 15+ or iOS 18+
- Check Xcode version supports Foundation Models

**"API key not found"**
- Verify environment variables are set
- Check API key validity with provider

**"PDF cannot be loaded"**  
- Ensure PDF is not password-protected
- Check file path is correct
- Verify PDF is not corrupted

### Debug Mode

Enable verbose logging:
```bash
SYNTRA_DEBUG=1 ./syntra-cli document.pdf --provider apple
```

## Contributing

This is a **test system** for validating SYNTRA's Swift migration. Key areas for enhancement:

- 🔧 **More LLM providers** (Anthropic Claude, local models)
- 🧠 **Enhanced SYNTRA prompting** for better consciousness processing  
- 📊 **Performance optimization** for large documents
- 🔒 **Security enhancements** for API key management

---

**Note**: This CLI tool is designed for **testing and validation**. Production integration should go through the main SYNTRA architecture review process. 