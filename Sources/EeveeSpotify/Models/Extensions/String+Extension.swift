import Foundation 

extension String {

    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }

    var range: NSRange { 
        NSRange(self.startIndex..., in: self) 
    }

    func containsInsensitive<S: StringProtocol>(_ s: S) -> Bool {
        self.range(of: s, options: .caseInsensitive) != nil
    }

    func matches(_ pattern: String) -> Bool {
        try! NSRegularExpression(pattern: pattern)
            .firstMatch(in: self, range: self.range) != nil
    }

    func removeMatches(_ pattern: String) -> String {
        try! NSRegularExpression(pattern: pattern)
            .stringByReplacingMatches(
                in: self, 
                range: self.range,
                withTemplate: ""
            )
    }
}