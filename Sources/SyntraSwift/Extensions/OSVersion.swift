import Foundation
#if os(macOS)
import AppKit
#endif

extension ProcessInfo {
    /// Detects if running on problematic macOS/iOS 26 Beta 3
    var isBeta3Threading: Bool {
        let version = operatingSystemVersion
        let versionString = operatingSystemVersionString
        
        #if os(macOS)
        return version.majorVersion == 26 && 
               version.minorVersion == 0 &&
               (versionString.contains("Beta 3") || versionString.contains("23A5287"))
        #else
        return version.majorVersion == 26 && 
               version.minorVersion == 0 &&
               (versionString.contains("Beta 3") || versionString.contains("23A5287"))
        #endif
    }
    
    /// General beta detection for development features
    var isRunningBeta: Bool {
        operatingSystemVersionString.lowercased().contains("beta")
    }
    
    /// Comprehensive version info for SYNTRA debugging
    var osVersionInfo: String {
        let version = operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion) (\(operatingSystemVersionString))"
    }
}

#if os(macOS)
extension NSApplication {
    /// Check if current macOS version has text input threading issues
    static var hasTextInputThreadingBug: Bool {
        return ProcessInfo.processInfo.isBeta3Threading
    }
}
#endif 