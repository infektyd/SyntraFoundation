"""Utilities to generate progress reports during iterative development.

Each report is a Markdown file capturing implementation summaries,
code change snippets, test results, and next steps. Reports are
saved under 'codex_reports/' for later review and archival.
"""
import os
from datetime import datetime

def generate_progress_report(phase: str,
                             summary: str,
                             code_changes: str,
                             test_results: str,
                             next_steps: str,
                             report_dir: str = 'codex_reports') -> str:
    """
    Create a Markdown progress report.

    Args:
        phase: Name of the development phase or milestone.
        summary: High-level summary of what was implemented.
        code_changes: Code diff or key snippets demonstrating changes.
        test_results: Output or statuses of relevant tests.
        next_steps: Recommendations for subsequent tasks.
        report_dir: Directory to save the report in.

    Returns:
        Path to the generated report file.
    """
    os.makedirs(report_dir, exist_ok=True)
    timestamp = datetime.now().strftime('%Y%m%dT%H%M%S')
    filename = f'PROGRESS_REPORT_{phase}_{timestamp}.md'
    path = os.path.join(report_dir, filename)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(f"# Progress Report — {phase}\n")
        f.write(f"**Generated:** {timestamp}\n\n")
        f.write("## Summary\n")
        f.write(summary + "\n\n")
        f.write("## Code Changes\n```diff\n")
        f.write(code_changes + "\n```\n\n")
        f.write("## Test Results\n```text\n")
        f.write(test_results + "\n```\n\n")
        f.write("## Next Steps\n")
        f.write(next_steps + "\n")

    return path
