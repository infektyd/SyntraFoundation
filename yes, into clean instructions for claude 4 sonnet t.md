<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

# yes, into clean instructions for claude 4 sonnet to understand, not hallucinate, and set up for the task oriented cursor pro IDE im using them in...

Here are clean, **precise instructions for Claude4 Sonnet** (or any codegen LLM) to follow, with zero ambiguity or “hallucination,” oriented for a Cursor Pro IDE workflow and modern Swift multi-platform/project context:

# Swift Build/CI/CD Failure – Action Plan for Large Language Model Code Assistant

## 1. Docker Image Tag Correction

**Task:**

- Identify all Dockerfiles and GitHub Actions workflows referencing the image tag `swift:6.2-noble`.
- Replace with a tag that exists in Docker Hub.
    - Query https://hub.docker.com/_/swift/tags for recent, supported tags (e.g., `swift:6.0`, `swift:nightly`, or `swift:<latest>-ubuntu-24.04`).
- Save, commit, and push these changes.

**How:**

- Search for `swift:6.2-noble` in all `.github`, `Dockerfile`, and CI/CD config files.
- Example fix:

```dockerfile
FROM swift:6.0 as builder
# or
FROM swift:6.0-focal as builder
```

- For Github Actions workflow YAML:

```yaml
image: swift:6.0
```


## 2. GitHub Actions Deprecation Fix

**Task:**

- Find any usage of `actions/upload-artifact@v3`.
- Replace with the newest supported version as of mid-2025 (consult [GitHub Actions artifact docs](https://github.com/actions/upload-artifact) if needed).
    - Example: `actions/upload-artifact@v4`

**How:**

- Search `.github/workflows/*` for `upload-artifact@v3`
- Update each instance:

```yaml
- uses: actions/upload-artifact@v4
```

- Save, commit, and push.


## 3. Swift Package Dependency Constraint Correction

**Task:**

- Open `Package.swift`.
- Find dependency line for `swift-foundation`.
- Update version requirement to match a tag that exists in the repo.
    - If no tag, use branch: `.branch("main")` or similar.

**How:**

```swift
.package(url: "https://github.com/apple/swift-foundation.git", from: "0.3.0")
// or, if no tags available:
.package(url: "https://github.com/apple/swift-foundation.git", branch: "main")
```

- Save, commit, and push.


## 4. Ensure Each Executable Target Has `main.swift`

**Task:**

- For every product/target defined as `.executable` in `Package.swift`, ensure the target subfolder contains a `main.swift` file.
- If missing, add a minimal entry point:

```swift
// Sources/<TargetName>/main.swift
import Foundation
print("Hello from <TargetName>")
```

- Save, commit, and push.


## 5. Actions Workflow Swift Version Safety

**Task:**

- In all GitHub Actions using `swift-actions/setup-swift`, confirm the `swift-version` is a value known to exist (e.g., "6.0" or "5.10").
- Change any `swift-version: 6.0` lines to a released version per [release docs](https://github.com/actions/setup-swift#available-swift-versions).

**How:**

```yaml
- uses: swift-actions/setup-swift@v1
  with:
    swift-version: '6.0'  # Or lower if 6.0 not available in runners yet
```

- Save, commit, and push.


## 6. General Clean-Up

**Task:**

- Remove tracked build artifacts or logs from version control.
    - For each, run:

```
git rm --cached <file-or-folder>
```

- Confirm `.gitignore` covers all machine/user-generated files and config logs.
- Commit and push with a message:
`"Clean: Remove tracked artifacts, update ignores, modernize build config"`


## 7. CI/CD Test \& Validation

**Task:**

- Push your changes, ensuring CI/CD workflows run cleanly.
- If failures persist, copy exact error messages and reference them for further targeted troubleshooting.

**Cursor Pro IDE and Claude 4 Sonnet can now use these SPECIFIC, stepwise edits without ambiguity or code-model “guesswork.”**

If you want code snippets or concrete splices for any of these steps, just specify which. This sequence is safe, standard, and current for mid-2025 Swift, Docker, and GitHub Actions.

