/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Application's delegate.
*/

import UIKit
import ARKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
    var nav: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("此设备不支持AR")
        }

        window = UIWindow()
        window?.frame = UIScreen.main.bounds
        let mainVC: MainVC = MainVC()
        nav = UINavigationController.init(rootViewController: mainVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        return true
    }
}
