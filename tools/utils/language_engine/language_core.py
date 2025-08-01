# language_core.py

from utils.language_engine.wordnet_hook import get_word_info
from utils.language_engine.phi_bridge import query_phi3
from utils.mistral_bridge import mistral_summarize
from utils.language_engine.syntax_trainer import analyze_structure
from utils.language_engine.core_brain import process_through_brains
from utils.io_tools import load_config


def run_language_cycle(
    input_text,
    show_valon=None,
    show_modi=None,
    show_drift=None,
    debug_output_trace: bool = False,
):
    """Return full cognition output while mirroring run_language_loop."""
    print(f"\n🧠 SYNTRA Observing: “{input_text}”")

    config = load_config()
    # Two-pass feedback loop is handled in core_brain.process_through_brains
    # Optionally enable a two-pass feedback loop (Valon sees Modi summary and vice versa)
    if config.get("enable_two_pass_loop", False):
        # TODO: implement two-pass micro-feedback between Valon and Modi before final drift
        pass
    if show_valon is None:
        show_valon = config.get("enable_valon_output", True)
    if show_modi is None:
        show_modi = config.get("enable_modi_output", True)
    if show_drift is None:
        show_drift = config.get("enable_drift_output", True)

    mistral_result = mistral_summarize(input_text)
    phi_result = query_phi3(input_text)
    word_info = {word: get_word_info(word) for word in input_text.split()}
    syntax_map = analyze_structure(input_text)

    cognition = process_through_brains(input_text)

    if debug_output_trace:
        import json

        print("\n[DEBUG] COGNITION TRACE:")
        print(json.dumps(cognition, indent=2))

    if show_valon:
        print("\n🔮 VALON SAYS:\n", cognition["valon"])
    if show_modi:
        print("\n🧠 MODI SAYS:\n", cognition["modi"])
    if show_drift:
        print("\n⚖️ SYNTRA DRIFT OUTPUT:\n", cognition["drift"])

    return cognition


def run_language_loop(
    input_text,
    show_valon=None,
    show_modi=None,
    show_drift=None,
    debug_output_trace: bool = False,
):
    """Run the language loop with optional output toggles."""
    cognition = run_language_cycle(
        input_text,
        show_valon=show_valon,
        show_modi=show_modi,
        show_drift=show_drift,
        debug_output_trace=debug_output_trace,
    )
    return cognition["drift"]
