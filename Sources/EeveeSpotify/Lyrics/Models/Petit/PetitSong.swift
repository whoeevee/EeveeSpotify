import Foundation

struct PetitSong: Codable {
    var lyricsId: Int
    var title: String
    var availableLyricsType: PetitLyricsType
    var lyricsType: PetitLyricsType
    var lyricsData: String
}
