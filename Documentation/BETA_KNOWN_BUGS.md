# Known Bugs and Workarounds for macOS/iOS 26 Beta

This document tracks known bugs in the beta versions of macOS and iOS 26 and the workarounds implemented in the SYNTRA codebase.

## 1. SwiftUI TextField Input Bug (macOS 26 Beta 3 / iOS 26 Beta 3)

**Issue:**
Standard `TextField` and `TextEditor` components in SwiftUI can become unresponsive or cause crashes when used within certain view hierarchies. The most common issue is a threading crash related to `setKeyboardAppearance`.

**Affected Platforms:**
- macOS 26 Beta 3
- iOS 26 Beta 3

**Workaround:**
A custom, thread-safe input component has been implemented to bypass the SwiftUI bug.

- **Component:** `CrashSafeTextInput`
- **Location:** `Apps/iOS/SyntraChatIOS/SyntraChatIOS/CrashSafeTextDisplay.swift`
- **Implementation:** This component uses a `UIViewRepresentable` (`DirectUITextFieldRepresentable`) to bridge a UIKit `UITextField` into SwiftUI. It includes specific thread-safety checks to prevent the `setKeyboardAppearance` crash.

**Removal Plan:**
This workaround should be removed once Apple resolves the underlying SwiftUI bug in a future beta release. On each new beta:
1.  Test the standard `TextField` in the affected views.
2.  If the bug is fixed, replace all instances of `CrashSafeTextInput` with the standard `TextField`.
3.  Update this documentation to reflect the removal of the workaround. 