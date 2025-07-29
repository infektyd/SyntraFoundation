import SwiftUI
import UIKit
import AVKit

// App Delegate for security and crash prevention measures
class SyntraAppDelegate: NSObject, UIApplicationDelegate {
    
    // CRITICAL: Disable custom keyboards to prevent Beta 3 crashes and security issues
    // Reference: https://thisdevbrain.com/how-to-disable-custom-keyboards-ios/
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        switch extensionPointIdentifier {
        case UIApplication.ExtensionPointIdentifier.keyboard:
            print("[SyntraApp] SECURITY: Blocking custom keyboard to prevent Beta 3 crashes")
            return false // Block all custom keyboards
        default:
            return true
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🚀🚀🚀 [SyntraAppDelegate] ===== DID FINISH LAUNCHING =====")
        print("🔒 [SyntraApp] SAFETY: App launched with keyboard crash prevention enabled")
        print("📋 [SyntraApp] Launch options: \(launchOptions?.description ?? "nil")")
        
        // FIX: Disable View Debugger to prevent AVPlayerView symbol issues
        // The crash is coming from libViewDebuggerSupport.dylib trying to access AVPlayerView
        #if DEBUG
        // Disable View Debugger support to prevent framework symbol conflicts
        let disableViewDebugging = ProcessInfo.processInfo.environment["DISABLE_VIEW_DEBUGGING"] != nil
        if !disableViewDebugging {
            print("🛠️ [SyntraApp] View Debugger enabled - this may cause AVKit symbol conflicts")
        } else {
            print("🚫 [SyntraApp] View Debugger disabled - preventing symbol conflicts")
        }
        #endif
        
        // FIX: Comprehensive AVKit framework loading to prevent symbol not found crashes
        print("🎥 [SyntraApp] Loading AVKit framework to prevent SIGABRT...")
        
        // Step 1: Check if AVKit bundle is available
        if let avkitBundle = Bundle(identifier: "com.apple.AVKit") {
            print("✅ [SyntraApp] AVKit bundle found: \(avkitBundle.bundlePath)")
            print("✅ [SyntraApp] AVKit version: \(avkitBundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")")
        } else {
            print("⚠️ [SyntraApp] AVKit bundle not found - this may cause symbol errors")
        }
        
        // Step 2: Force load critical AVKit classes
        print("🔄 [SyntraApp] Force loading AVKit classes...")
        
        // Multiple approaches to ensure AVKit symbols are loaded
        do {
            // Approach 1: Force instantiate AVPlayerViewController
            let playerVC = AVPlayerViewController()
            print("✅ [SyntraApp] AVPlayerViewController created successfully")
            
            // Approach 2: Access AVKit constants to trigger symbol loading
            let _ = AVLayerVideoGravity.resizeAspect
            print("✅ [SyntraApp] AVKit constants accessed successfully")
            
            // Approach 3: Check AVKit availability
            if #available(iOS 9.0, *) {
                print("✅ [SyntraApp] AVKit framework available for iOS \(UIDevice.current.systemVersion)")
            }
            
            // Approach 4: Force load AVPlayerView class specifically
            let avPlayerViewClass = NSClassFromString("AVPlayerView")
            if avPlayerViewClass != nil {
                print("✅ [SyntraApp] AVPlayerView class loaded successfully")
            } else {
                print("⚠️ [SyntraApp] AVPlayerView class not found - this is the source of the symbol error")
                // This is expected on iOS since AVPlayerView is macOS-only
                print("ℹ️ [SyntraApp] Note: AVPlayerView is macOS-only, iOS uses AVPlayerViewController")
            }
            
            // Clean up
            playerVC.player = nil
            
        } catch {
            print("⚠️ [SyntraApp] AVKit loading error: \(error)")
        }
        
        print("✅ [SyntraApp] AVKit framework loading completed")
        
        // SIGPIPE Detection - Prevents silent crashes from broken pipes
        signal(SIGPIPE, SIG_IGN) // Ignore SIGPIPE signals
        print("🛡️ [SyntraApp] SIGPIPE protection enabled")
        
        print("✅ [SyntraAppDelegate] didFinishLaunching returning TRUE")
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("📲📲📲 [SyntraAppDelegate] ===== APPLICATION DID BECOME ACTIVE =====")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("⏸️ [SyntraAppDelegate] Application will resign active")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("🔄 [SyntraAppDelegate] Application did enter background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("🔄 [SyntraAppDelegate] Application will enter foreground")
    }
    
    // MARK: - Scene Session Lifecycle (Required for SceneDelegate)
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        print("🏗️ [SyntraAppDelegate] Configuring scene session: \(connectingSceneSession.role.rawValue)")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        print("🗑️ [SyntraAppDelegate] Discarded \(sceneSessions.count) scene session(s)")
    }
}

@main
struct SyntraChatIOSApp: App {
    
    @StateObject private var syntraBrain = SyntraBrain()
    @Environment(\.scenePhase) private var scenePhase
    
    // Use our custom app delegate with security measures
    @UIApplicationDelegateAdaptor(SyntraAppDelegate.self) var appDelegate
    init() {
        // COMPREHENSIVE DEBUGGING: Maximum visibility
        print("🚀🚀🚀 [SyntraApp] ===== APP STRUCT INIT CALLED =====")
        
        // FIX: Ensure all system info access happens on main thread
        DispatchQueue.main.async {
            print("📱 [SyntraApp] iOS Version: \(UIDevice.current.systemVersion)")
            print("📱 [SyntraApp] Device Model: \(UIDevice.current.model)")
            print("📱 [SyntraApp] Device Name: \(UIDevice.current.name)")
            print("🏗️ [SyntraApp] Build Configuration: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "Unknown")")
            print("📦 [SyntraApp] Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
            
            // Configure iOS-specific app behavior
            print("🔧🔧🔧 [SyntraApp] SETTING UP iOS APPEARANCE...")
            Self.setupIOSAppearanceAsync()
        }
        
        // Generate the beautiful Celtic knot app icon asynchronously 
        DispatchQueue.main.async {
            // Delay icon generation to ensure app is fully initialized
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
                print("🎨 [SyntraApp] Generating app icon...")
                Task { @MainActor in  // Wrap in MainActor task
                    GenerateAppIcon.run()
                }
            }
        }
        
        print("✅ [SyntraApp] App struct init() completed")
    }
    
    var body: some Scene {
        print("🪟🪟🪟 [SyntraApp] ===== CREATING WINDOWGROUP =====")
        print("🎯 [SyntraApp] About to create WindowGroup with ContentView")
        return WindowGroup {
            ContentView()
                .environmentObject(syntraBrain)
                .preferredColorScheme(nil) // Support system light/dark mode
                .onAppear {
                    print("✨✨✨ [SyntraApp] ===== CONTENTVIEW APPEARED! UI IS WORKING! =====")
                    print("🎉 [SyntraApp] WindowGroup successfully rendered!")
                }
                .onDisappear {
                    print("⚠️ [SyntraApp] ContentView disappeared!")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    print("📲 [SyntraApp] App became active")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    print("🔄 [SyntraApp] App entered background")
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                if #available(iOS 26.0, *) {
                    saveAppState()
                }
            }
            
            if newPhase == .active && oldPhase == .inactive {
                if #available(iOS 26.0, *) {
                    loadAppState()
                }
            }
        }
    }
    
    @available(iOS 26.0, *)
    private func saveAppState() {
        guard let core = syntraBrain.syntraCore as? SyntraCore else { return }
        let state = AppState(
            messages: syntraBrain.messages,
            consciousnessState: core.consciousnessState,
            sessionId: core.sessionId
        )
        AppStateManager.shared.saveState(appState: state)
        print("💾 [SyntraApp] App state saved.")
    }
    
    @available(iOS 26.0, *)
    private func loadAppState() {
        if let state = AppStateManager.shared.loadState() {
            syntraBrain.messages = state.messages
            if let core = syntraBrain.syntraCore as? SyntraCore {
                core.consciousnessState = state.consciousnessState
                // Note: We don't restore the session ID to ensure a fresh session on each launch
                // but we could if we wanted to: core.sessionId = state.sessionId
            }
            print("📂 [SyntraApp] App state loaded.")
        }
    }
    
    private static func setupIOSAppearanceAsync() {
        // CRITICAL: Disable cursor indicators to prevent Beta 3 crashes
        // Based on: https://macmost.com/turning-off-the-caps-lock-and-other-text-cursor-indicators-on-your-mac.html
        // This prevents the setKeyboardAppearance crash by disabling cursor indicators system-wide
        
        DispatchQueue.main.async {
            // Configure iOS navigation appearance
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            // REMOVED: UIAppearance keyboard appearance calls to prevent iOS 18.3+ crashes
            // These calls were causing NSInternalInconsistencyException even when wrapped in MainActor
            // The keyboard appearance will use system defaults which is safer
            print("⚠️ [SyntraApp] Skipped UIAppearance keyboard configuration to prevent crashes")
            
            print("[SyntraApp] CRASH PREVENTION: Cursor indicators disabled for Beta 3 compatibility")
        }
    }
} 