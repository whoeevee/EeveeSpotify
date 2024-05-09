import Foundation

struct MusixmatchSubtitle: Decodable {
    var text: String
    var time: MusixmatchTime
}