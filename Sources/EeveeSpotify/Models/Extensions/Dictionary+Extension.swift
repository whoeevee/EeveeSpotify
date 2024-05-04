import Foundation

extension Dictionary {
    var queryString: String {
        return self
            .compactMap({ (key, value) -> String in
                return "\(key)=\(value)"
            })
        .joined(separator: "&")
    }
}