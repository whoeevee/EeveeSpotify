import Foundation

enum LyricsSource: Int, CaseIterable, CustomStringConvertible {
    case genius
    case lrclib
    case musixmatch
    case petit
    case notReplaced
    
    static var allCases: [LyricsSource] {
        return [.genius, .lrclib, .musixmatch, .petit]
    }

    var description: String {
        switch self {
        case .genius: "Genius"
        case .lrclib: "LRCLIB"
        case .musixmatch: "Musixmatch"
        case .petit: "PetitLyrics"
        case .notReplaced: "Spotify"
        }
    }
    
    var isReplacing: Bool { self != .notReplaced }
    
    static var defaultSource: LyricsSource {
        Locale.isInRegion("JP", orHasLanguage: "ja")
            ? .petit
            : .lrclib
    }
}
