#!/bin/bash

echo "🚀 Setting up Isolated Test Environment"
echo "========================================"

# Check if we're in the right directory
if [ ! -d "python_tests" ]; then
    echo "❌ Please run this script from the isolated_test_environment directory"
    exit 1
fi

echo "📦 Installing Python dependencies..."
cd python_tests
python3 setup_gemini_test.py
cd ..

echo "🔧 Setting up Swift environment..."
cd swift_tests
swift package resolve
cd ..

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit python_tests/test_gemini_pdf.py to add your Gemini API key"
echo "2. Run: python3 run_comparison.py"
echo "3. Or run tests individually:"
echo "   - Python: cd python_tests && python3 test_gemini_pdf.py"
echo "   - Swift: cd swift_tests && swift run syntra-cli 'source_pdfs/Foundation Trilogy.pdf' --provider apple" 