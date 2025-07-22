import Foundation
#if os(macOS)
import AppKit
#endif

extension ProcessInfo {
    /// Detects if running on problematic macOS 26 Beta 3
    var isMacOS26Beta3: Bool {
        #if os(macOS)
        let version = operatingSystemVersion
        let versionString = operatingSystemVersionString
        
        return version.majorVersion == 26 && 
               version.minorVersion == 0 &&
               (versionString.contains("Beta 3") || versionString.contains("23A5287g"))
        #else
        return false
        #endif
    }
    
    /// General beta detection for development features
    var isRunningBeta: Bool {
        operatingSystemVersionString.lowercased().contains("beta")
    }
    
    /// Helper for SYNTRA debugging
    var osVersionInfo: String {
        let version = operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion) (\(operatingSystemVersionString))"
    }
}

#if os(macOS)
extension NSApplication {
    /// Check if current macOS version has text input threading issues
    static var hasTextInputThreadingBug: Bool {
        return ProcessInfo.processInfo.isMacOS26Beta3
    }
}
#endif 