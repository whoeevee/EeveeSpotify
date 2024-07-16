import Foundation

struct PetitLyricsLine: Codable {
    var linestring: String
    var words: [PetitLyricsWord]
    
    enum CodingKeys: String, CodingKey {
        case linestring
        case words = "word"
    }
}
