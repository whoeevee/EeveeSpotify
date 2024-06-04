import Foundation

enum LyricsError: Swift.Error {
    case NoCurrentTrack
    case InvalidMusixmatchToken
    case DecodingError
    case NoSuchSong
}
