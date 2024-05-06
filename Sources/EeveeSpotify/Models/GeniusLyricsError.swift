import Foundation

enum GeniusLyricsError: Swift.Error {
    case NoCurrentTrack
    case DecodingError
    case NoSuchSong
}