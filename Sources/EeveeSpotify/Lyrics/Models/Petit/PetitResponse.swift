import Foundation

struct PetitResponse: Codable {
    var songs: [PetitSong]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        songs = try container.decode(PetitSongs.self, forKey: .songs).songs
    }
    
    struct PetitSongs: Decodable {
        var songs: [PetitSong]
        
        enum CodingKeys: String, CodingKey {
            case songs = "song"
        }
    }
}
