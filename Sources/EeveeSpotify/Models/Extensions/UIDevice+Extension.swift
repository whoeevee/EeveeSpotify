import UIKit

extension UIDevice {
    var isIpad: Bool {
        self.userInterfaceIdiom == .pad
    }
}
