import Foundation

@objc protocol SPTEncoreLabel {
    func text() -> NSArray
    func setNumberOfLines(_ number: Int)
    func setText(_ text: NSArray)
}
