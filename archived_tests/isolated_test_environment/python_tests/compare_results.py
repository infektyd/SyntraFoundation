import json
import os

def compare_results():
    """Compare Gemini results with existing Mistral results"""
    print("=== SYNTRA Results Comparison ===")
    
    # Check for Gemini results
    gemini_file = "gemini_test_results.json"
    if not os.path.exists(gemini_file):
        print(f"❌ {gemini_file} not found. Run test_gemini_pdf.py first.")
        return
    
    # Check for existing Mistral results
    mistral_files = []
    for root, dirs, files in os.walk("memory_vault"):
        for file in files:
            if file.endswith(".json") and not file.endswith("_gemini.json"):
                mistral_files.append(os.path.join(root, file))
    
    if not mistral_files:
        print("❌ No existing Mistral results found in memory_vault/")
        return
    
    print(f"Found {len(mistral_files)} Mistral result files")
    
    # Load Gemini results
    with open(gemini_file, "r") as f:
        gemini_results = json.load(f)
    
    print(f"Found {len(gemini_results)} Gemini results")
    
    # Compare each result
    for gemini_result in gemini_results:
        if not isinstance(gemini_result, dict):
            continue
            
        source_name = gemini_result.get("source", "unknown")
        print(f"\n--- Comparing {source_name} ---")
        
        # Find matching Mistral file
        matching_mistral = None
        for mistral_file in mistral_files:
            if source_name.replace(".pdf", "") in mistral_file:
                matching_mistral = mistral_file
                break
        
        if matching_mistral:
            try:
                with open(matching_mistral, "r") as f:
                    mistral_data = json.load(f)
                
                print(f"✅ Found matching Mistral file: {matching_mistral}")
                
                # Compare summary lengths
                gemini_analysis_len = len(gemini_result.get("analysis", ""))
                mistral_summary_len = len(mistral_data.get("summary", ""))
                
                print(f"Analysis length - Gemini: {gemini_analysis_len}, Mistral: {mistral_summary_len}")
                
                # Compare VALON reflections
                gemini_valon = gemini_result.get("valon_reflection", "")
                mistral_valon = mistral_data.get("valon_reflection", "")
                
                if isinstance(mistral_valon, dict):
                    mistral_valon = str(mistral_valon)
                
                gemini_valon_len = len(gemini_valon)
                mistral_valon_len = len(mistral_valon)
                
                print(f"VALON reflection length - Gemini: {gemini_valon_len}, Mistral: {mistral_valon_len}")
                
                # Show sample of differences
                print(f"\nGemini Analysis (first 200 chars):")
                print(gemini_result.get("analysis", "")[:200] + "...")
                
                print(f"\nMistral Summary (first 200 chars):")
                print(mistral_data.get("summary", "")[:200] + "...")
                
            except Exception as e:
                print(f"❌ Error comparing {source_name}: {e}")
        else:
            print(f"❌ No matching Mistral file found for {source_name}")
    
    print(f"\n--- Comparison complete ---")
    print("Delete gemini_test_results.json when done to remove API key.")

if __name__ == "__main__":
    compare_results() 