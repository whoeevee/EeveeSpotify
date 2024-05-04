import Foundation

enum GeniusDataResponse: Decodable {
    case hits(GeniusHitsResponse)
    case song(GeniusSongResponse)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let hits = try? container.decode(GeniusHitsResponse.self) {
            self = .hits(hits)
        }
        else if let song = try? container.decode(GeniusSongResponse.self) {
            self = .song(song)
        }
        else {
            throw DecodingError.typeMismatch(
                GeniusDataResponse.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid data format"
                )
            )
        }
    }
}