import Foundation

extension UserDefaults {
    
    private static let defaults = UserDefaults.standard
    
    private static let lyricsSourceKey = "lyricsSource"
    private static let musixmatchTokenKey = "musixmatchToken"
    private static let geniusFallbackKey = "geniusFallback"

    static var lyricsSource: LyricsSource {
        get {
            if let rawValue = defaults.object(forKey: lyricsSourceKey) as? Int {
                return LyricsSource(rawValue: rawValue)!
            }

            return .lrclib
        }
        set (newSource) {
            defaults.set(newSource.rawValue, forKey: lyricsSourceKey)
        }
    }

    static var musixmatchToken: String {
        get {
            defaults.string(forKey: musixmatchTokenKey) ?? ""
        }
        set (token) {
            defaults.set(token, forKey: musixmatchTokenKey)
        }
    }

    static var geniusFallback: Bool {
        get {
            defaults.object(forKey: geniusFallbackKey) as? Bool ?? true
        }
        set (fallback) {
            defaults.set(fallback, forKey: geniusFallbackKey)
        }
    }
}