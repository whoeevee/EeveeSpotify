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

    func present(_ viewController: UIViewController) {
        rootViewController.present(viewController, animated: true)
    }

    func findFirstViewController(_ regex: String) -> UIViewController? {
    
        let rootView = self.rootViewController.view!
        var result: UIViewController?
        
        func searchViews(_ view: UIView) {
            if let viewController = self.viewController(for: view) {
                if String(describing: type(of: viewController)) ~= regex { 
                    result = viewController
                    return
                }    
            }

            for subview in view.subviews {
                searchViews(subview) 
            }
        }
        
        searchViews(rootView)
        return result
    }

    func overrideUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        window.overrideUserInterfaceStyle = style
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
