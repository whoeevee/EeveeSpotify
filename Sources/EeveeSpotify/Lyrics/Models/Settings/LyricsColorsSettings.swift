import Foundation

struct LyricsColorsSettings: Codable, Equatable {
    var displayOriginalColors: Bool
    var useStaticColor: Bool
    var staticColor: String
    var normalizationFactor: CGFloat
}
