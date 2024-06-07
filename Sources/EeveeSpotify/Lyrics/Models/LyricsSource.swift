import Foundation

enum LyricsSource : Int, CustomStringConvertible {
    case genius
    case lrclib
    case musixmatch
    case netease
    case qqmusic

    var description : String { 
        switch self {
        case .genius: "Genius"
        case .lrclib: "LRCLIB"
        case .musixmatch: "Musixmatch"
        case .netease: "Netease"
        case .qqmusic: "QQMusic"
        }
    }
}
