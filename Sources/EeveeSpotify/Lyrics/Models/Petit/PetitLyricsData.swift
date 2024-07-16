import Foundation

struct PetitLyricsData: Codable {
    var lines: [PetitLyricsLine]
    
    enum CodingKeys: String, CodingKey {
        case lines = "line"
    }
}
