import Orion
import UIKit 

class UITabBarHook: ClassHook<UITabBar> {

    // there is only one UITabBar, so no problem
    func items() -> [UITabBarItem] {
        return Array(orig.items().prefix(3)) 
    }
}

class UITabBarButtonLabelHook: ClassHook<UIView> {

    static let targetName = "UITabBarButtonLabel"

    func text() -> String {
        
        let text = orig.text()
        
        if text == "Premium" {
            target.superview?.removeFromSuperview()
        }

        return text
    } 
}