import Foundation

@objc protocol SPTEncoreLabel {
    func text() -> NSArray
    func setText(_ text: NSArray)
}
