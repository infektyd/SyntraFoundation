#!/bin/bash
# tools/build-scripts/build-stable.sh
# Small helper to run a reproducible build using the stable Swift/Xcode toolchain (target: Swift 6.2)
#
# Usage:
#   ./tools/build-scripts/build-stable.sh            # full clean, resolve, build, test
#   ./tools/build-scripts/build-stable.sh --target Modi   # build only Modi target
#
set -euo pipefail

# Prefer stable Xcode unless developer explicitly overrides DEVELOPER_DIR.
# This makes builds reproducible for contributors and CI while allowing
# local overrides when needed.
# If /Applications/Xcode.app isn't present, fall back to xcode-select -p.
if [ -z "${DEVELOPER_DIR:-}" ]; then
  if [ -d "/Applications/Xcode.app/Contents/Developer" ]; then
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
  else
    # Try xcode-select, then default to system swift location
    XCODE_SEL_PATH="$(xcode-select -p 2>/dev/null || true)"
    if [ -n "$XCODE_SEL_PATH" ] && [ -d "$XCODE_SEL_PATH" ]; then
      export DEVELOPER_DIR="$XCODE_SEL_PATH"
      echo "⚠️  /Applications/Xcode.app not found — using xcode-select: $DEVELOPER_DIR"
    else
      # As a last resort, leave DEVELOPER_DIR empty and rely on PATH's swift
      unset DEVELOPER_DIR
      echo "⚠️  No Xcode found at /Applications/Xcode.app and xcode-select returned nothing. Using system swift in PATH."
    fi
  fi
fi

export TOOLCHAIN_DIR="${TOOLCHAIN_DIR:-${DEVELOPER_DIR:-}/Toolchains/XcodeDefault.xctoolchain}"
if [ -n "${DEVELOPER_DIR:-}" ]; then
  export PATH="$DEVELOPER_DIR/usr/bin:$PATH"
fi

echo "🔎 Checking Swift toolchain..."

SWIFT_VERSION=$(swift --version 2>/dev/null || true)
if [ -z "$SWIFT_VERSION" ]; then
  echo "Error: swift not found in PATH. Make sure Xcode / swift toolchain is installed and xcode-select is configured."
  exit 1
fi

echo "Detected: $SWIFT_VERSION"

# Require Swift 6.2 as primary target (best-effort check)
if echo "$SWIFT_VERSION" | grep -q "6.2"; then
  echo "✅ Swift 6.2 detected (stable target)."
else
  echo "⚠️  Warning: Swift 6.2 not detected. This script targets the stable Swift 6.2 toolchain."
  echo "    Proceeding nevertheless — builds may fail on mismatched toolchains."
  echo "    To use the stable toolchain, install the matching Xcode and/or swift toolchain and run:"
  echo "      sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  echo "    or use swiftenv / asdf if you manage multiple toolchains."
fi

# Simple helper to run steps with a label
run_step() {
  echo
  echo "---- $1 ----"
  shift
  "$@"
}

# Clean build artifacts
run_step "Cleaning package artifacts" swift package clean
run_step "Removing .build directory" rm -rf .build

# Resolve packages
run_step "Resolving Swift packages" swift package resolve

# Build (optionally accept additional swift build args)
if [ "$#" -gt 0 ]; then
  echo "Building with arguments: $@"
  run_step "Building (custom args)" swift build "$@"
else
  run_step "Building (full debug)" swift build --configuration debug
fi

# Run tests unless --no-test is provided
if [[ " $* " != *" --no-test "* ]]; then
  run_step "Running tests" swift test
else
  echo "Skipping tests (passed --no-test)"
fi

echo
echo "✅ Build script completed successfully."
