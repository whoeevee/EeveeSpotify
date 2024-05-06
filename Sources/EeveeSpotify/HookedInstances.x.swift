import Orion

class HookedInstances {
    static var productState: SPTCoreProductState?
    static var currentTrack: SPTPlayerTrack?
}

class SPTNowPlayingModelHook: ClassHook<NSObject> {

    static let targetName = "SPTNowPlayingModel"

    func currentTrack() -> SPTPlayerTrack? {

        if let track = orig.currentTrack() {
            HookedInstances.currentTrack = track
            return track
        }

        return nil
    }
}

class SPTCoreProductStateInstanceHook: ClassHook<NSObject> {

    static let targetName = "SPTCoreProductState"

    func stringForKey(_ key: String) -> NSString {

        HookedInstances.productState = Dynamic.convert(
            target,
            to: SPTCoreProductState.self
        )
        return orig.stringForKey(key)
    }
}
