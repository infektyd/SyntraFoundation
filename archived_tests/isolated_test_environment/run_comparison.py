#!/usr/bin/env python3
"""
Test Runner for PDF Processing Comparison
Runs both Python (Gemini) and Swift (Apple Foundation Models) tests
"""

import os
import subprocess
import sys
from pathlib import Path

def run_python_test():
    """Run the Python + Gemini test"""
    print("🔍 Running Python + Gemini test...")
    try:
        result = subprocess.run(
            ["python", "python_tests/test_gemini_pdf.py"],
            capture_output=True,
            text=True,
            cwd=os.getcwd()
        )
        if result.returncode == 0:
            print("✅ Python test completed successfully")
            return True
        else:
            print(f"❌ Python test failed: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Error running Python test: {e}")
        return False

def run_swift_test():
    """Run the Swift + Apple Foundation Models test"""
    print("🔍 Running Swift + Apple Foundation Models test...")
    try:
        result = subprocess.run(
            ["swift", "run", "syntra-cli", "source_pdfs/Foundation Trilogy.pdf", "--provider", "apple"],
            capture_output=True,
            text=True,
            cwd="swift_tests"
        )
        if result.returncode == 0:
            print("✅ Swift test completed successfully")
            return True
        else:
            print(f"❌ Swift test failed: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Error running Swift test: {e}")
        return False

def compare_results():
    """Compare results from both tests"""
    print("\n📊 Comparing results...")
    
    # Look for result files
    python_results = Path("python_tests/gemini_test_results.json")
    swift_results = Path("swift_tests/syntra_output.json")
    
    if python_results.exists():
        print(f"📄 Python results: {python_results.stat().st_size} bytes")
    
    if swift_results.exists():
        print(f"📄 Swift results: {swift_results.stat().st_size} bytes")
    
    print("\n📋 Manual comparison needed - check the result files above")

def main():
    """Main test runner"""
    print("🚀 Starting PDF Processing Comparison Test")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not Path("python_tests").exists():
        print("❌ Please run this script from the isolated_test_environment directory")
        sys.exit(1)
    
    # Run tests
    python_success = run_python_test()
    swift_success = run_swift_test()
    
    # Compare results
    if python_success or swift_success:
        compare_results()
    
    print("\n" + "=" * 50)
    if python_success and swift_success:
        print("🎉 Both tests completed! Check results/ directory for outputs.")
    elif python_success:
        print("⚠️  Only Python test completed. Swift test may need setup.")
    elif swift_success:
        print("⚠️  Only Swift test completed. Python test may need API key.")
    else:
        print("❌ Both tests failed. Check setup and try again.")

if __name__ == "__main__":
    main() 