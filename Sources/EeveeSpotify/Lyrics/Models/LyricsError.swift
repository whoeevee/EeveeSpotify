import Foundation

enum LyricsError: Error, CustomStringConvertible {
    case NoCurrentTrack
    case MusixmatchRestricted
    case InvalidMusixmatchToken
    case DecodingError
    case NoSuchSong
    case UnknownError
    
    var description: String {
        switch self {
        case .NoSuchSong: "No Song Found"
        case .MusixmatchRestricted: "Restricted"
        case .InvalidMusixmatchToken: "Unauthorized"
        case .DecodingError: "Decoding Error"
        case .NoCurrentTrack: "No Track Instance"
        case .UnknownError: "Unknown Error"
        }
    }
}
