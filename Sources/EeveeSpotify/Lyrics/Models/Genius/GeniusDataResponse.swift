import Foundation

enum GeniusDataResponse: Decodable {
    case sections(GeniusSectionsResponse)
    case song(GeniusSongResponse)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let sections = try? container.decode(GeniusSectionsResponse.self) {
            self = .sections(sections)
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
