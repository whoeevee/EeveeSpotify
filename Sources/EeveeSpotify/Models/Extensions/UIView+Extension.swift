import UIKit

extension UIView {
    func hasParent(matching regex: String) -> Bool {
       guard let parent = self.superview else {
           return false
       }

       let parentClassName = NSStringFromClass(type(of: parent))
       if parentClassName ~= regex {
           return true
       } else {
           return parent.hasParent(matching: regex)
       }
   }
    
    func subviews(matching regex: String) -> [UIView] {
        var matchingSubviews = [UIView]()
        var stack = [self]
        
        while !stack.isEmpty {
            let currentView = stack.removeLast()
            
            for subview in currentView.subviews {
                if NSStringFromClass(type(of: subview)) ~= regex {
                    matchingSubviews.append(subview)
                }
                stack.append(subview)
            }
        }
        
        return matchingSubviews
    }
}
