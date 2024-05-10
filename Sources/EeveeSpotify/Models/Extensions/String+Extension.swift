import Foundation 

extension String {

    static func ~= (lhs: String, rhs: String) -> Bool {
        lhs.firstMatch(rhs) != nil
    }

    var range: NSRange { 
        NSRange(self.startIndex..., in: self) 
    }

    var strippedTrackTitle: String {
        String(
            self
            .removeMatches("\\(.*\\)")
            .removeMatches("- .*")
            .prefix(30)
            //.trimmingCharacters(in: .whitespaces)
        )
    }

    var isHex: Bool {
        self ~= "^[a-f0-9]+$"
    }

    var lyricsNoteIfEmpty: String {
        self.isEmpty ? "♪" : self
    }

    func containsInsensitive<S: StringProtocol>(_ s: S) -> Bool {
        self.range(of: s, options: .caseInsensitive) != nil
    }

    func firstMatch(_ pattern: String) -> NSTextCheckingResult? {
        try! NSRegularExpression(pattern: pattern)
            .firstMatch(in: self, range: self.range)
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