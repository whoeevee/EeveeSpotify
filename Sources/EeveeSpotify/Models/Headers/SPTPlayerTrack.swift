import Foundation

@objc protocol SPTPlayerTrack {
    func setMetadata(_ metadata: [String:String])
    func extractedColorHex() -> String
    func trackTitle() -> String
    func artistTitle() -> String
    func URI() -> SPTURL
    func metadata() -> [String:String]
    func artistsString() -> String
}
