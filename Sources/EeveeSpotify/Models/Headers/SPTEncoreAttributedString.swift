import Foundation

@objc protocol SPTEncoreAttributedString {
    func initWithString(_ string: String, typeStyle: Any, attributes: Any) -> SPTEncoreAttributedString
    func text() -> String
    func typeStyle() -> Any
    func attributes() -> SPTEncoreAttributes
}
