import UIKit

extension UIView {
    func hasParent(_ regex: String) -> Bool {
       guard let parent = self.superview else {
           return false
       }

       let parentClassName = NSStringFromClass(type(of: parent))
       if parentClassName ~= regex {
           return true
       } else {
           return parent.hasParent(regex)
       }
   }
}
