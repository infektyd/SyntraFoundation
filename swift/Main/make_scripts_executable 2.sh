#!/bin/bash

echo "🔧 Making SYNTRA diagnostic scripts executable..."

chmod +x complete_legacy_fix.sh
chmod +x check_legacy_references.sh  
chmod +x verify_hidden_integrity.sh

echo "✅ All scripts are now executable:"
echo "  - complete_legacy_fix.sh"
echo "  - check_legacy_references.sh"
echo "  - verify_hidden_integrity.sh"
echo ""
echo "🚀 Run the main fix with:"
echo "  ./complete_legacy_fix.sh"