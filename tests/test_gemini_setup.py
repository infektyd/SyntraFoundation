#!/usr/bin/env python3
"""
Test script for Gemini API setup and integration with SYNTRA PDF pipeline.
This script helps verify that Gemini API is properly configured and working.
"""

import os
from utils.gemini_bridge import gemini_bridge, query_gemini
from utils.io_tools import load_config

def test_gemini_config():
    """Test if Gemini API key is configured."""
    config = load_config()
    api_key = config.get("gemini_api_key")
    
    print("=== GEMINI API CONFIGURATION TEST ===")
    print(f"API Key configured: {'Yes' if api_key and api_key != 'YOUR_GEMINI_API_KEY' else 'No'}")
    print(f"Model: {config.get('gemini_model', 'gemini-1.5-pro')}")
    
    if not api_key or api_key == "YOUR_GEMINI_API_KEY":
        print("\n❌ Gemini API key not configured!")
        print("Please set your Gemini API key in config.json:")
        print('  "gemini_api_key": "your-actual-api-key-here"')
        print("\nTo get a Gemini API key:")
        print("1. Go to https://makersuite.google.com/app/apikey")
        print("2. Create a new API key")
        print("3. Copy the key and update config.json")
        return False
    
    print("✅ Gemini API key is configured")
    return True

def test_gemini_connection():
    """Test basic Gemini API connection."""
    print("\n=== GEMINI API CONNECTION TEST ===")
    
    test_prompt = "Hello! Please respond with 'Gemini API is working correctly' if you can see this message."
    
    try:
        response = query_gemini(test_prompt)
        print(f"Response: {response}")
        
        if "Gemini API is working correctly" in response:
            print("✅ Gemini API connection successful!")
            return True
        elif "Error:" in response:
            print(f"❌ Gemini API error: {response}")
            return False
        else:
            print("⚠️  Gemini API responded but not as expected")
            return True  # Still working, just different response
    except Exception as e:
        print(f"❌ Gemini API connection failed: {e}")
        return False

def test_consciousness_reflection():
    """Test VALON consciousness reflection with Gemini."""
    print("\n=== VALON CONSCIOUSNESS REFLECTION TEST ===")
    
    test_content = """
    Engine Oil Change Procedure:
    1. Warm up engine to operating temperature
    2. Drain old oil completely
    3. Replace oil filter
    4. Add new oil to specified level
    5. Check for leaks
    """
    
    try:
        reflection = gemini_bridge.reflect_valon_consciousness(test_content)
        print("VALON Reflection Results:")
        print(f"Symbolic terms: {reflection.get('symbolic_terms', [])}")
        print(f"Emotions: {reflection.get('emotions', [])}")
        print(f"Structure: {reflection.get('structure', '')}")
        print(f"Meaning: {reflection.get('meaning', '')[:200]}...")
        
        if reflection.get('symbolic_terms') and reflection.get('emotions'):
            print("✅ VALON consciousness reflection working!")
            return True
        else:
            print("⚠️  VALON reflection incomplete")
            return False
    except Exception as e:
        print(f"❌ VALON reflection failed: {e}")
        return False

def test_document_analysis():
    """Test document chunk analysis with Gemini."""
    print("\n=== DOCUMENT ANALYSIS TEST ===")
    
    test_chunk = """
    Brake System Maintenance:
    - Check brake fluid level monthly
    - Inspect brake pads every 10,000 miles
    - Replace brake fluid every 2 years
    - Test brake pedal feel and response
    """
    
    try:
        analysis = gemini_bridge.analyze_document_chunk(test_chunk, 0, 1)
        print(f"Document Analysis Result:")
        print(analysis[:300] + "..." if len(analysis) > 300 else analysis)
        
        if "Error:" not in analysis and len(analysis) > 50:
            print("✅ Document analysis working!")
            return True
        else:
            print("❌ Document analysis failed")
            return False
    except Exception as e:
        print(f"❌ Document analysis failed: {e}")
        return False

def compare_with_mistral():
    """Compare Gemini results with existing Mistral processing."""
    print("\n=== COMPARISON WITH MISTRAL ===")
    
    # Check if we have existing Mistral-processed files
    modi_dir = "memory_vault/modi"
    if os.path.exists(modi_dir):
        mistral_files = [f for f in os.listdir(modi_dir) if f.endswith('.json') and not f.endswith('_gemini.json')]
        gemini_files = [f for f in os.listdir(modi_dir) if f.endswith('_gemini.json')]
        
        print(f"Found {len(mistral_files)} Mistral-processed files")
        print(f"Found {len(gemini_files)} Gemini-processed files")
        
        if mistral_files and gemini_files:
            print("✅ Both Mistral and Gemini results available for comparison")
            print("Run comparison with: python ingest/pdf_ingestor_gemini.py --compare <gemini_file>")
            return True
        else:
            print("⚠️  Need both Mistral and Gemini processed files for comparison")
            return False
    else:
        print("❌ No memory vault found")
        return False

def main():
    """Run all Gemini setup and integration tests."""
    print("SYNTRA Gemini API Integration Test")
    print("=" * 50)
    
    tests = [
        ("Configuration", test_gemini_config),
        ("Connection", test_gemini_connection),
        ("VALON Reflection", test_consciousness_reflection),
        ("Document Analysis", test_document_analysis),
        ("Comparison Setup", compare_with_mistral)
    ]
    
    results = []
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ {test_name} test failed with exception: {e}")
            results.append((test_name, False))
    
    print("\n" + "=" * 50)
    print("TEST RESULTS SUMMARY:")
    print("=" * 50)
    
    passed = 0
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name}: {status}")
        if result:
            passed += 1
    
    print(f"\nOverall: {passed}/{len(results)} tests passed")
    
    if passed == len(results):
        print("\n🎉 All tests passed! Gemini integration is ready.")
        print("\nNext steps:")
        print("1. Process a PDF with Gemini: python ingest/pdf_ingestor_gemini.py --file your_file.pdf")
        print("2. Process with original pipeline: python ingest/pdf_ingestor.py")
        print("3. Compare results: python ingest/pdf_ingestor_gemini.py --compare memory_vault/modi/your_file_gemini.json")
    else:
        print("\n⚠️  Some tests failed. Please check the configuration and try again.")

if __name__ == "__main__":
    main() 