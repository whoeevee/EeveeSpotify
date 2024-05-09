import Foundation

extension Data {

    static func random(_ length: Int) -> Data {
        return Data((0 ..< length).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) })
    }

    var hexEncodedString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }

    static var musixmatchTokenPlaceholder: String {
        "2" + self.random(53).hexEncodedString
    }
}
