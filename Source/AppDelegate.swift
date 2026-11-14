import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Kích hoạt Anti-Debug & Anti-Frida
        SecurityGuard.shared.activateAllProtections()

        // Khởi động giao diện chính
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = Theme.bg
        window?.rootViewController = LoginViewController()
        window?.makeKeyAndVisible()

        return true
    }
}

