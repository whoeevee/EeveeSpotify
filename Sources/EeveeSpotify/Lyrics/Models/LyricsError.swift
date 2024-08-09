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
        case .NoSuchSong: "no_such_song".localized
        case .MusixmatchRestricted: "musixmatch_restricted".localized
        case .InvalidMusixmatchToken: "invalid_musixmatch_token".localized
        case .DecodingError: "decoding_error".localized
        case .NoCurrentTrack: "no_current_track".localized
        case .UnknownError: "unknown_error".localized
        }
    }
}
