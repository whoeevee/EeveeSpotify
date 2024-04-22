import UIKit
import Foundation

class WindowHelper {
    
    static let shared = WindowHelper()
    
    let window: UIWindow
    let rootViewController: UIViewController
    
    private init() { 
        self.window = UIApplication.shared.windows.first!
        self.rootViewController = window.rootViewController!
    }
    
    func presentViewController(_ viewController: UIViewController) {
        rootViewController.present(viewController, animated: true)
    }

    func showPopup(message: String, buttonText: String) {

        let alert = UIAlertController(title: "EeveeSpotify", message: message, preferredStyle: .alert)

        alert.overrideUserInterfaceStyle = .dark
        alert.addAction(UIAlertAction(title: buttonText, style: .default))

        presentViewController(alert)
    }
}
