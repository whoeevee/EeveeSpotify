import Foundation

struct LrclibSong: Decodable {
    var name: String
    var plainLyrics: String?
    var syncedLyrics: String?
}