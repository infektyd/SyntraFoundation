import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // TODO: Add state saving when shared instance is implemented
        // SyntraChatViewModel.shared?.saveCurrentAppState()
        // SyntraPerformanceLogger.logStage("App Lifecycle", message: "Application terminating - state saved")
    }
} 