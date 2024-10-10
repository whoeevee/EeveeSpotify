import Orion

class SPTPlayerTrackHook: ClassHook<NSObject> {
    typealias Group = LyricsGroup
    static let targetName = "SPTPlayerTrack"

    func metadata() -> [String:String] {
        var meta = orig.metadata()

        meta["has_lyrics"] = "true"
        return meta
    }
}

class LyricsScrollProviderHook: ClassHook<NSObject> {
    typealias Group = LyricsGroup
    
    static var targetName: String {
        return EeveeSpotify.isOldSpotifyVersion
            ? "Lyrics_CoreImpl.ScrollProvider"
            : "Lyrics_NPVCommunicatorImpl.ScrollProvider"
    }
    
    func isEnabledForTrack(_ track: SPTPlayerTrack) -> Bool {
        return true
    }
}
