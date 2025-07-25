# Gemini PDF Test - Quick Setup

Simple test to compare Gemini vs Mistral PDF processing results.

## Quick Setup

1. **Install dependencies:**
   ```bash
   python tests/setup_gemini_test.py
   ```

2. **Edit the API key:**
   Open `tests/test_gemini_pdf.py` and change:
   ```python
   GEMINI_API_KEY = "YOUR_GEMINI_API_KEY_HERE"
   ```
   to your actual Gemini API key.

3. **Run the test:**
   ```bash
   python tests/test_gemini_pdf.py
   ```

4. **Compare results:**
   ```bash
   python tests/compare_results.py
   ```

5. **Clean up:**
   Delete the test files when done to remove your API key.

## Files Created

- `gemini_test_results.json` - Gemini processing results
- `tests/test_gemini_pdf.py` - Main test script (edit API key here)
- `tests/compare_results.py` - Comparison script
- `tests/setup_gemini_test.py` - Dependency installer

## Manual Installation

If the setup script fails, install manually:
```bash
pip install requests PyPDF2
```

## Get Gemini API Key

1. Go to https://makersuite.google.com/app/apikey
2. Create a new API key
3. Copy the key and paste it in `test_gemini_pdf.py`

## What It Does

- Processes all PDFs in the project with Gemini
- Generates technical analysis and VALON consciousness reflections
- Compares results with existing Mistral processing
- Shows differences in extraction quality and content

## Clean Up

When done testing, delete:
- `tests/test_gemini_pdf.py`
- `tests/compare_results.py` 
- `tests/setup_gemini_test.py`
- `tests/README_GEMINI_TEST.md`
- `gemini_test_results.json`

This removes your API key from the project. 