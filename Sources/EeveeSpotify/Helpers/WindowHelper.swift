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

    func viewController(for view: UIView) -> UIViewController? {
        var responder: UIResponder? = view
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
