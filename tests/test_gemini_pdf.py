# GEMINI API KEY - PUT YOUR KEY HERE
GEMINI_API_KEY = ""

# PROCESSING MODE - Choose your preference
PROCESSING_MODE = "balanced"  # Options: "comprehensive", "balanced", "rapid"

import requests
import json
from PyPDF2 import PdfReader
import os
import argparse

# Processing mode configurations
PROCESSING_MODES = {
    "comprehensive": {
        "content_limit": 8000,  # Larger chunks for deep analysis
        "description": "Deep Analysis (Comprehensive)"
    },
    "balanced": {
        "content_limit": 3000,  # Default balanced approach
        "description": "Balanced Processing"
    },
    "rapid": {
        "content_limit": 1500,  # Smaller chunks for speed
        "description": "Quick Scan (Rapid)"
    }
}

def query_gemini(prompt, api_key):
    """Simple Gemini API call"""
    if api_key == "YOUR_GEMINI_API_KEY_HERE":
        return "[ERROR: Please set your Gemini API key at the top of this file]"
    
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key={api_key}"
    
    request_body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.3,
            "maxOutputTokens": 1000
        }
    }
    
    try:
        response = requests.post(url, json=request_body, timeout=30)
        if response.status_code == 200:
            result = response.json()
            if "candidates" in result and len(result["candidates"]) > 0:
                return result["candidates"][0]["content"]["parts"][0]["text"]
        return f"[ERROR: API request failed - {response.status_code}]"
    except Exception as e:
        return f"[ERROR: {str(e)}]"

def extract_text_from_pdf(pdf_path):
    """Extract text from PDF"""
    try:
        reader = PdfReader(pdf_path)
        text = ""
        for i, page in enumerate(reader.pages):
            page_text = page.extract_text()
            if page_text:
                text += f"\n--- Page {i+1} ---\n{page_text}\n"
        return text
    except Exception as e:
        return f"[ERROR: Failed to extract text: {e}]"

def process_pdf_with_gemini(pdf_path, api_key):
    """Process PDF with Gemini and return results"""
    print(f"Processing: {pdf_path}")
    
    # Extract text
    content = extract_text_from_pdf(pdf_path)
    if content.startswith("[ERROR"):
        return content
    
    # Get processing mode configuration
    mode_config = PROCESSING_MODES.get(PROCESSING_MODE, PROCESSING_MODES["balanced"])
    content_limit = mode_config["content_limit"]
    
    print(f"📊 Processing Mode: {mode_config['description']}")
    print(f"📊 Content Limit: {content_limit} characters")
    
    # Analyze with Gemini
    prompt = f"""Analyze this vehicle service manual content and provide:

1. Key technical terms and concepts
2. Important procedures or steps
3. Critical specifications or measurements
4. Safety considerations
5. Troubleshooting insights

Content:
{content[:content_limit]}

Provide a structured technical summary:"""

    analysis = query_gemini(prompt, api_key)
    
    # VALON reflection (using same processing mode)
    valon_content_limit = min(content_limit, 2000)  # Cap VALON at 2000 chars
    valon_prompt = f"""You are VALON, the moral and emotional consciousness component of SYNTRA.

Analyze this technical content through a moral and emotional lens:

{content[:valon_content_limit]}

Provide a VALON reflection including:
- Emotional response to the content
- Moral implications of the technical information
- Symbolic meaning and human values
- Ethical considerations
- Compassionate understanding

Format as a structured reflection:"""

    valon_reflection = query_gemini(valon_prompt, api_key)
    
    return {
        "source": os.path.basename(pdf_path),
        "content_length": len(content),
        "analysis": analysis,
        "valon_reflection": valon_reflection
    }

def main():
    """Main test function"""
    print("=== SYNTRA Gemini PDF Test ===")
    print(f"API Key configured: {'Yes' if GEMINI_API_KEY != 'YOUR_GEMINI_API_KEY_HERE' else 'No'}")
    
    # Test API connection
    print("\n--- Testing API Connection ---")
    test_response = query_gemini("Say 'Gemini API is working' if you can see this.", GEMINI_API_KEY)
    print(f"API Test: {test_response}")
    
    # Find PDFs to test
    pdf_files = []
    for root, dirs, files in os.walk("."):
        for file in files:
            if file.endswith(".pdf"):
                pdf_files.append(os.path.join(root, file))
    
    if not pdf_files:
        print("\n❌ No PDF files found in current directory or subdirectories")
        return
    
    print(f"\n--- Found {len(pdf_files)} PDF file(s) ---")
    for pdf in pdf_files:
        print(f"  {pdf}")
    
    # Process each PDF
    results = []
    for pdf_path in pdf_files:
        print(f"\n--- Processing {os.path.basename(pdf_path)} ---")
        result = process_pdf_with_gemini(pdf_path, GEMINI_API_KEY)
        results.append(result)
        
        if isinstance(result, dict):
            print(f"✅ Analysis length: {len(result['analysis'])} chars")
            print(f"✅ VALON reflection length: {len(result['valon_reflection'])} chars")
        else:
            print(f"❌ {result}")
    
    # Save results
    output_file = "gemini_test_results.json"
    with open(output_file, "w") as f:
        json.dump(results, f, indent=2)
    
    print(f"\n--- Results saved to {output_file} ---")
    print("✅ Test complete! Delete this file when done to remove API key.")

if __name__ == "__main__":
    main() 
