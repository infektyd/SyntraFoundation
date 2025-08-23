# Build Scripts - Stable Toolchain

This folder contains small helper scripts to run reproducible builds against the stable Swift/Xcode toolchain.

Primary script:
- build-stable.sh — Clean, resolve, build, and test using the local swift toolchain (targeting Swift 6.2).

Usage:
- ./tools/build-scripts/build-stable.sh
- ./tools/build-scripts/build-stable.sh --target Modi
- ./tools/build-scripts/build-stable.sh --no-test   (skip tests)

Notes:
- The script checks for a Swift version string containing "6.2" and will warn if a different toolchain is active.
- If you maintain multiple Xcode/toolchains, prefer configuring `xcode-select` to point to the stable Xcode before running the script:
  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

CI:
- Add a macOS job that checks out the repo, runs the script, and fails on test failures. This ensures the repo stays compatible with the stable toolchain.
