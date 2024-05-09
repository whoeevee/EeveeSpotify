import Foundation

enum LyricsError: Swift.Error {
    case NoCurrentTrack
    case DecodingError
    case NoSuchSong
}