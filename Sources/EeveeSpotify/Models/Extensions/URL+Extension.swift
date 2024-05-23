import Foundation

extension URL {
    var isLyrics: Bool {
        self.path.contains("color-lyrics/v2")
    }

    var isOpenSpotifySafariExtension: Bool {
        self.host == "eevee"
    }
}