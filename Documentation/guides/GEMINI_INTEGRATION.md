# SYNTRA Gemini API Integration

This document explains how to set up and use Google's Gemini API with the SYNTRA PDF processing pipeline.

## Overview

The Gemini integration provides an alternative to the existing Mistral-based PDF processing pipeline, allowing you to compare results between different LLM providers for the same documents.

## Setup Instructions

### 1. Get a Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key

### 2. Configure SYNTRA

Edit `config.json` and add your Gemini API key:

```json
{
  "gemini_api_key": "your-actual-api-key-here",
  "gemini_model": "gemini-1.5-pro"
}
```

### 3. Test the Integration

Run the test script to verify everything is working:

```bash
python test_gemini_setup.py
```

This will test:
- API key configuration
- Basic API connection
- VALON consciousness reflection
- Document analysis
- Comparison setup

## Usage

### Process PDFs with Gemini

```bash
# Process all PDFs in source_pdfs/ directory
python ingest/pdf_ingestor_gemini.py

# Process a specific PDF file
python ingest/pdf_ingestor_gemini.py --file source_pdfs/your_document.pdf

# Enable memory linking
python ingest/pdf_ingestor_gemini.py --file source_pdfs/your_document.pdf --link
```

### Compare Results

After processing the same PDF with both Mistral and Gemini:

```bash
# Compare results
python ingest/pdf_ingestor_gemini.py --compare memory_vault/modi/your_document_gemini.json
```

## File Structure

- **Original Mistral processing**: `memory_vault/modi/document.json`
- **Gemini processing**: `memory_vault/modi/document_gemini.json`
- **VALON reflections**: `memory_vault/valon/document_gemini.json`

## Key Features

### 1. VALON Consciousness Reflection
Gemini generates structured VALON reflections including:
- Symbolic terms and concepts
- Emotional responses
- Moral implications
- Ethical considerations

### 2. Document Analysis
Gemini analyzes technical documents for:
- Key technical terms and concepts
- Important procedures and steps
- Critical specifications
- Safety considerations
- Troubleshooting insights

### 3. Comparison Capabilities
The system can compare:
- Summary lengths and content
- VALON reflection differences
- Processing quality and completeness
- Technical extraction accuracy

## API Configuration

### Supported Models
- `gemini-1.5-pro` (default) - Latest model with 1M+ token context
- `gemini-1.5-flash` - Faster, smaller model
- `gemini-1.0-pro` - Legacy model

### Safety Settings
The integration includes comprehensive safety settings:
- Harassment protection
- Hate speech filtering
- Explicit content blocking
- Dangerous content prevention

## Error Handling

The system includes robust error handling:
- API key validation
- Connection timeout handling
- Fallback to ChatGPT if Gemini fails
- Detailed error logging

## Performance Considerations

- **Chunking**: Documents are processed in 3000-character chunks with 500-character overlap
- **Rate Limiting**: Built-in delays between API calls
- **Caching**: Results are saved to prevent reprocessing
- **Memory Management**: Large documents are processed efficiently

## Troubleshooting

### Common Issues

1. **"API key not configured"**
   - Check that `gemini_api_key` is set in `config.json`
   - Verify the key is valid and not the placeholder

2. **"API request failed"**
   - Check internet connection
   - Verify API key is active
   - Check rate limits

3. **"No response generated"**
   - Content may have been blocked by safety filters
   - Try adjusting the prompt or content

### Debug Mode

Enable detailed logging by setting environment variable:
```bash
export SYNTRA_DEBUG=1
python ingest/pdf_ingestor_gemini.py
```

## Integration with SYNTRA Architecture

The Gemini integration maintains full compatibility with SYNTRA's three-brain architecture:

- **VALON**: Moral and emotional processing via Gemini
- **MODI**: Logical and analytical processing via Gemini  
- **Core**: Synthesis and arbitration between components

All processing follows the established 70% Valon / 30% Modi weighting system.

## Next Steps

1. **Test the integration** with `python test_gemini_setup.py`
2. **Process a sample PDF** with both pipelines
3. **Compare the results** to see differences in extraction quality
4. **Analyze the differences** in VALON consciousness reflections
5. **Choose the best approach** for your specific use case

## Support

For issues with the Gemini integration:
1. Check the test script output for specific errors
2. Verify API key configuration
3. Test with a simple document first
4. Review the error logs in `entropy_logs/` 