import Foundation

extension Locale {
    static func isInRegion(_ regionCode: String, orHasLanguage languageCode: String) -> Bool {
        self.current.regionCode == regionCode || self.preferredLanguages.contains(languageCode)
    }
}
