import FwiCore
import RIBs

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder {
    /// Class's public properties
    var window: UIWindow?

    /// Override Apple's default controls.
    func customAppearance() {
        window?.tintColor = Color.orange
        SVProgressHUD.setDefaultStyle(.light)
    }

    /// Class's private properties
    private var launchRouter: LaunchRouting?
}

// MARK: UIApplicationDelegate's members
extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        customAppearance()

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let launchRouter = RootBuilder(dependency: AppComponent()).build()
        self.launchRouter = launchRouter
        launchRouter.launch(from: window)

        
        return true
    }

     MARK: Application's lifecycle
    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}
