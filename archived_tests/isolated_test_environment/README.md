# Isolated Test Environment

This directory provides an isolated testing environment for rapid iteration when converting Python PDF processing to Swift, comparing Gemini (Python) vs Apple Foundation Models (Swift).

## Structure

```
isolated_test_environment/
├── python_tests/          # Python + Gemini tests
│   ├── test_gemini_pdf.py
│   ├── compare_results.py
│   └── setup_gemini_test.py
├── swift_tests/           # Swift + Apple Foundation Models tests
│   ├── Sources/
│   ├── Package.swift
│   └── README.md
├── source_pdfs/           # Test PDFs (Foundation Trilogy, etc.)
│   └── Foundation Trilogy.pdf
├── results/               # Output results from both tests
└── README.md             # This file
```

## Quick Start

### Python + Gemini Test
```bash
cd python_tests
python setup_gemini_test.py  # Install dependencies
# Edit test_gemini_pdf.py to add your Gemini API key
python test_gemini_pdf.py    # Run test
```

### Swift + Apple Foundation Models Test
```bash
cd swift_tests
swift run syntra-cli "source_pdfs/Foundation Trilogy.pdf" --provider apple
```

## Test Comparison

Both tests process the same PDFs to ensure fair comparison:

- **Python + Gemini**: Uses Gemini 1.5-pro (1M+ tokens) via API
- **Swift + Apple Foundation Models**: Uses Apple's 3B parameter model on-device

## Rapid Iteration Workflow

1. **Modify Python test** in `python_tests/`
2. **Run Python test** and check results
3. **Convert logic to Swift** in `swift_tests/`
4. **Run Swift test** and compare outputs
5. **Iterate** until both produce similar quality results

## Results

All test outputs are saved to `results/` directory for easy comparison.

## Cleanup

This environment is isolated - you can safely delete the entire `isolated_test_environment/` folder when done testing. 