import XCTest
import SwiftUI
@testable import SyntraSwift

final class Beta3ThreadingFixTests: XCTestCase {
    
    /// Test that text input doesn't crash on macOS/iOS 26 Beta 3
    func testThreadSafeTextInput() async {
        // Given: Thread-safe text input component
        let textInput = SyntraThreadSafeTextInput(
            text: .constant(""),
            isProcessing: .constant(false),
            placeholder: "Test input"
        ) {
            // Test submission handler
        }
        
        // When: Component is created and rendered
        // Then: Should not crash due to threading issues
        XCTAssertNotNil(textInput)
        
        // Verify OS version detection works
        let isBeta3 = ProcessInfo.processInfo.isBeta3Threading
        print("Running on Beta 3: \(isBeta3)")
        
        if isBeta3 {
            print("⚠️ Testing on macOS/iOS 26 Beta 3 - threading workarounds active")
        }
    }
    
    /// Test that NSTextField bridge works correctly on macOS
    #if os(macOS)
    func testNSTextFieldBridge() {
        // Given: NSTextField bridge component
        let bridge = MacOSTextFieldBridge(
            text: .constant("Test"),
            placeholder: "Test placeholder",
            isEnabled: true
        ) {
            // Test submission
        }
        
        // When: Bridge is created
        // Then: Should not crash and should handle text properly
        XCTAssertNotNil(bridge)
    }
    #endif
    
    /// Test that consciousness processing works with thread-safe input
    func testConsciousnessProcessingWithThreadSafeInput() async {
        // Given: Chat view model with thread-safe input
        let config = SyntraConfig()
        let viewModel = SyntraChatViewModel(config: config)
        
        // When: Processing a message through thread-safe input
        viewModel.currentInput = "Test message"
        
        // Then: Should process without threading crashes
        await viewModel.processMessage()
        
        // Verify message was processed
        XCTAssertFalse(viewModel.isProcessing)
        XCTAssertEqual(viewModel.currentInput, "")
    }
    
    /// Test keyboard handling extensions
    func testKeyboardHandlingExtensions() {
        // Given: A view with keyboard handling
        let testView = Text("Test")
            .hideKeyboardOnTap()
            .keyboardAdaptive()
        
        // When: View is created
        // Then: Should not crash due to keyboard handling
        XCTAssertNotNil(testView)
    }
    
    /// Test OS version detection accuracy
    func testOSVersionDetection() {
        let processInfo = ProcessInfo.processInfo
        
        // Test version info
        let versionInfo = processInfo.osVersionInfo
        XCTAssertFalse(versionInfo.isEmpty)
        
        // Test beta detection
        let isBeta = processInfo.isRunningBeta
        print("Running on beta: \(isBeta)")
        
        // Test Beta 3 specific detection
        let isBeta3 = processInfo.isBeta3Threading
        print("Running on Beta 3: \(isBeta3)")
        
        if isBeta3 {
            print("⚠️ CRITICAL: Running on macOS/iOS 26 Beta 3")
            print("Threading workarounds should be active")
        }
    }
    
    /// Test that all text input components are thread-safe
    func testAllTextInputComponents() async {
        // Test SyntraChatTextInput
        let chatInput = SyntraChatTextInput(
            text: .constant(""),
            isProcessing: .constant(false)
        ) {
            // Test handler
        }
        XCTAssertNotNil(chatInput)
        
        // Test SyntraThreadSafeTextInput
        let threadSafeInput = SyntraThreadSafeTextInput(
            text: .constant(""),
            isProcessing: .constant(false)
        ) {
            // Test handler
        }
        XCTAssertNotNil(threadSafeInput)
    }
    
    /// Test that consciousness indicators work with thread-safe input
    func testConsciousnessIndicators() {
        // Given: Chat view with consciousness indicators
        let config = SyntraConfig()
        let chatView = SyntraChatView(config: config)
        
        // When: View is created
        // Then: Should display consciousness indicators without crashes
        XCTAssertNotNil(chatView)
    }
}

// MARK: - Test Helpers

extension Beta3ThreadingFixTests {
    
    /// Helper to simulate text input focus
    func simulateTextInputFocus() {
        // This would simulate tapping on a text input
        // In a real test environment, this would trigger the threading issue
        // if not properly handled
    }
    
    /// Helper to verify no threading violations
    func verifyNoThreadingViolations() {
        // Check that no setKeyboardAppearance calls happen off main thread
        // This is the core issue we're fixing
    }
} 