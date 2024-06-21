import UIKit

@objc protocol SPTEncoreAttributes {
    func `init`(_: (SPTEncoreAttributes) -> Void) -> SPTEncoreAttributes
    func foregroundColor() -> UIColor
    func setForegroundColor(_ color: UIColor)
}
