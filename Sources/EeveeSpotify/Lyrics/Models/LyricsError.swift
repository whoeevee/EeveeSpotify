import Foundation

enum LyricsError: Error {
    case NoCurrentTrack
    case MusixmatchRestricted
    case InvalidMusixmatchToken
    case DecodingError
    case NoSuchSong
}
