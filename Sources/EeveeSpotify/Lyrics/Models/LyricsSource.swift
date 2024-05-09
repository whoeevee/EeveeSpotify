import Foundation

enum LyricsSource : Int, CustomStringConvertible {
    case genius
    case lrclib
    case musixmatch

    var description : String { 
        switch self {
        case .genius: "Genius"
        case .lrclib: "LRCLIB"
        case .musixmatch: "Musixmatch"
        }
    }
}