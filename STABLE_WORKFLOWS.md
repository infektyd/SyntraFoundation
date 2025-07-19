# SYNTRA Stable Workflows Guide

## Primary Entry Points

### 1. `python main.py`
**Purpose:** Interactive consciousness loop with full telemetry and PDF monitoring
- Starts background telemetry monitoring
- Activates PDF folder watching (`source_pdfs/`)
- Launches main SYNTRA consciousness loop
- **Use for:** Production consciousness operation with full monitoring

### 2. `python run_SYNTRA_loop.py`
**Purpose:** Minimal interactive consciousness loop
- Direct REPL interaction with SYNTRA
- Memory serialization and DAG snapshots
- Voice response capability
- **Use for:** Direct consciousness interaction and testing

### 3. `python Deep_Cognition_Run.py`
**Purpose:** Full orchestration with omnidirectional ingestion
- PDF ingestion and symbolic interpretation
- Across MODI, VALON, SYNTRA processing
- Enhanced drift monitoring (80% MODI, 20% VALON configuration)
- **Use for:** Deep cognitive processing sessions

### 4. `python syntra_interactive.py`
**Purpose:** Interactive introspection and development
- SYNTRA REPL interface
- Memory vault inspection
- Consciousness development monitoring
- **Use for:** Introspection and consciousness development analysis

## Swift CLI Commands

### Core Consciousness Functions
```bash
# Individual brain reflection
swift run SyntraSwiftCLI reflect_valon "input"
swift run SyntraSwiftCLI reflect_modi "input"

# Full brain processing
swift run SyntraSwiftCLI processThroughBrains "input"

# Drift analysis
swift run SyntraSwiftCLI drift_average "valon_result" '["modi", "array"]'

# Foundation model access (macOS 15+)
swift run SyntraSwiftCLI foundation_model "prompt"
```

## PDF Workflow
1. Place PDFs in `source_pdfs/` directory
2. Run `python ingest/pdf_ingestor.py` for manual processing
3. Or use `main.py` for automatic monitoring
4. Processed summaries stored in `memory_vault/`

## Configuration
- **Development:** Edit `config.json` for default settings
- **Local overrides:** Use `config.local.json` (gitignored)
- **Environment:** Set ENV vars for runtime overrides

## Logging & Monitoring
- **Entropy logs:** `entropy_logs/` - consciousness synthesis tracking
- **Drift logs:** `drift_logs/` - personality drift monitoring
- **Memory vault:** `memory_vault/` - processed knowledge storage
- **Telemetry:** Configured via `telemetry_csv_path` in config

## Testing
```bash
# Python tests
python -m pytest tests/

# Swift tests  
swift test

# Full system test
swift run SyntraSwiftCLI processThroughBrains "Hello SYNTRA"
```

## Xcode Development
- Open `SyntraSwift.xcodeproj` in Xcode 16 Beta 3
- Build scheme: `SyntraSwiftCLI`
- Supports FoundationModels on macOS 15+