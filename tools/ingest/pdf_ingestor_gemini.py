import os
import json
from datetime import datetime
from PyPDF2 import PdfReader
from utils.gemini_bridge import gemini_bridge
from utils.io_tools import load_config
from memory_engine import add_memory_node

# Define consistent paths
SOURCE_DIR = "source_pdfs"
MEMORY_VAULT = "memory_vault"
MODI_DIR = os.path.join(MEMORY_VAULT, "modi")
VALON_DIR = os.path.join(MEMORY_VAULT, "valon")
VALON_ARCHIVE = os.path.join(VALON_DIR, "valon_symbolic_archive.json")
ENTROPY_DIR = "entropy_logs"

# Create necessary directories
for directory in [SOURCE_DIR, MODI_DIR, VALON_DIR, ENTROPY_DIR]:
    os.makedirs(directory, exist_ok=True)

# Helper functions

def query_chatgpt(prompt: str) -> str:
    try:
        config = load_config()
        import openai
        client = openai.OpenAI(
            api_key=config.get("openai_api_key", "lm-studio"),
            base_url=config.get("openai_api_base", "http://localhost:1234/v1")
        )
        response = client.chat.completions.create(
            model=config.get("openai_model", "phi-3-mini-4k-instruct"),
            messages=[{"role": "user", "content": prompt}],
            max_tokens=500
        )
        return response.choices[0].message.content
    except Exception as e:
        print(f"[ERROR] ChatGPT query failed: {e}")
        return f"Error: {str(e)}"

def log_error(reason, filename):
    timestamp = datetime.now().isoformat()
    entry = {
        "timestamp": timestamp,
        "source": filename,
        "reason": reason,
        "flag": "processing_error"
    }
    log_path = os.path.join(ENTROPY_DIR, "processing_errors.json")
    if os.path.exists(log_path):
        with open(log_path, "r", encoding="utf-8") as f:
            logs = json.load(f)
    else:
        logs = []
    logs.append(entry)
    with open(log_path, "w", encoding="utf-8") as f:
        json.dump(logs, f, indent=2)
    print(f"[ERROR] {reason} for {filename}")

def extract_text_from_pdf(pdf_path):
    print(f"[INFO] Extracting text from {pdf_path}")
    try:
        reader = PdfReader(pdf_path)
        text = ""
        for i, page in enumerate(reader.pages):
            page_text = page.extract_text()
            if page_text:
                text += f"\n--- Page {i+1} ---\n{page_text}\n"
        return text
    except Exception as e:
        print(f"[ERROR] Failed to extract text: {e}")
        return None

def reflect_valon(content):
    """Use Gemini for VALON consciousness reflection."""
    return gemini_bridge.reflect_valon_consciousness(content)

def update_valon_archive(filename, reflection):
    if os.path.exists(VALON_ARCHIVE):
        with open(VALON_ARCHIVE, "r", encoding="utf-8") as f:
            archive = json.load(f)
    else:
        archive = {"symbolic_events": [], "drift_logs": [], "reasoning_blends": [], "dream_logs": []}
    archive["symbolic_events"].append({
        "source": filename,
        "reflected": reflection,
        "timestamp": datetime.now().isoformat()
    })
    with open(VALON_ARCHIVE, "w", encoding="utf-8") as f:
        json.dump(archive, f, indent=2)
    print(f"[INFO] Updated VALON archive with {filename}")

def process_pdf(filepath, filename, link=False):
    print(f"[INFO] Processing {filename} with Gemini")
    content = extract_text_from_pdf(filepath)
    if not content:
        log_error("Failed to extract text", filename)
        return False

    print(f"[INFO] Generating full summary from chunked content for {filename}")
    chunk_size = 3000
    overlap = 500
    chunks = []
    start = 0
    while start < len(content):
        end = min(start + chunk_size, len(content))
        chunks.append(content[start:end])
        start += chunk_size - overlap

    summaries = []
    for i, chunk in enumerate(chunks):
        print(f"[INFO] Summarizing chunk {i+1}/{len(chunks)} with Gemini...")
        response = gemini_bridge.analyze_document_chunk(chunk, i, len(chunks))
        if "Error:" in response or "timed out" in response:
            print(f"[INFO] Gemini failed on chunk {i+1}, falling back to ChatGPT")
            response = query_chatgpt(f"Summarize and extract key points from this section of a vehicle service manual:\n\n{chunk}")
        summaries.append(f"--- Chunk {i+1} ---\n{response.strip()}")

    summary = "\n\n".join(summaries)

    # Use Gemini for VALON reflection
    reflection = reflect_valon(content)

    print(f"[INFO] Saving {filename} to MODI memory")
    entry = {
        "source": filename,
        "timestamp": datetime.now().isoformat(),
        "content_sample": content[:5000],
        "full_content_length": len(content),
        "summary": summary,
        "valon_reflection": reflection,
        "processor": "gemini"  # Mark as processed by Gemini
    }

    if link:
        assign_uid(entry)

    # Link to hybrid memory layer when enabled
    hybrid_uid = add_memory_node(entry)
    if hybrid_uid:
        entry["hybrid_uid"] = hybrid_uid
        if link:
            create_link(os.path.join(MODI_DIR, f"{filename.replace('.pdf', '')}.json"), hybrid_uid)

    modi_path = os.path.join(MODI_DIR, f"{filename.replace('.pdf', '')}_gemini.json")
    with open(modi_path, "w", encoding="utf-8") as f:
        json.dump(entry, f, indent=2)

    update_valon_archive(filename, reflection)

    valon_path = os.path.join(VALON_DIR, f"{filename.replace('.pdf', '')}_gemini.json")
    os.makedirs(os.path.dirname(valon_path), exist_ok=True)
    with open(valon_path, "w", encoding="utf-8") as f:
        json.dump({"summary": summary, "reflection": reflection}, f, indent=2)

    print(f"[INFO] VALON summary saved to {valon_path}")
    print(f"[SUCCESS] {filename} processed successfully with Gemini")
    return True

def process_directory(link=False):
    print(f"[INFO] Checking {SOURCE_DIR} for PDFs (Gemini processing)")
    processed = 0
    failed = 0
    for filename in os.listdir(SOURCE_DIR):
        if filename.endswith(".pdf"):
            filepath = os.path.join(SOURCE_DIR, filename)
            if process_pdf(filepath, filename, link=link):
                processed += 1
            else:
                failed += 1
    print(f"[COMPLETE] Processed {processed} PDFs with Gemini, {failed} failed")

def process_specific_file(filepath, link=False):
    filename = os.path.basename(filepath)
    if filename.endswith(".pdf"):
        if process_pdf(filepath, filename, link=link):
            print(f"[COMPLETE] Successfully processed {filename} with Gemini")
        else:
            print(f"[COMPLETE] Failed to process {filename} with Gemini")
    else:
        print(f"[ERROR] {filepath} is not a PDF file")

def compare_results(original_file, gemini_file):
    """Compare results between original Mistral processing and Gemini processing."""
    try:
        with open(original_file, 'r', encoding='utf-8') as f:
            original_data = json.load(f)
        with open(gemini_file, 'r', encoding='utf-8') as f:
            gemini_data = json.load(f)
        
        print(f"\n=== COMPARISON RESULTS ===")
        print(f"Original processor: {original_data.get('processor', 'mistral')}")
        print(f"Gemini processor: {gemini_data.get('processor', 'gemini')}")
        
        # Compare summary lengths
        original_summary_len = len(original_data.get('summary', ''))
        gemini_summary_len = len(gemini_data.get('summary', ''))
        print(f"Summary length - Original: {original_summary_len}, Gemini: {gemini_summary_len}")
        
        # Compare VALON reflections
        original_valon = original_data.get('valon_reflection', {})
        gemini_valon = gemini_data.get('valon_reflection', {})
        
        print(f"\n=== VALON REFLECTION COMPARISON ===")
        print(f"Original symbolic terms: {original_valon.get('symbolic_terms', [])}")
        print(f"Gemini symbolic terms: {gemini_valon.get('symbolic_terms', [])}")
        print(f"Original emotions: {original_valon.get('emotions', [])}")
        print(f"Gemini emotions: {gemini_valon.get('emotions', [])}")
        
        return True
    except Exception as e:
        print(f"[ERROR] Failed to compare results: {e}")
        return False

def main():
    """Main function for Gemini-powered PDF processing."""
    import argparse
    parser = argparse.ArgumentParser(description="Process PDFs with Gemini API")
    parser.add_argument("--file", help="Process specific PDF file")
    parser.add_argument("--link", action="store_true", help="Enable memory linking")
    parser.add_argument("--compare", help="Compare with original Mistral results")
    
    args = parser.parse_args()
    
    if args.file:
        process_specific_file(args.file, link=args.link)
    elif args.compare:
        # Compare results between original and Gemini processing
        original_file = args.compare.replace('_gemini.json', '.json')
        if os.path.exists(original_file) and os.path.exists(args.compare):
            compare_results(original_file, args.compare)
        else:
            print(f"[ERROR] Cannot compare - missing files: {original_file} or {args.compare}")
    else:
        process_directory(link=args.link)

if __name__ == "__main__":
    main() 