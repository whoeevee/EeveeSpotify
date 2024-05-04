import Orion

class HookedInstances {
    static var productState: SPTCoreProductState?
    static var currentTrack: SPTPlayerTrack?
}

class SPTNowPlayingContentLayerViewModelHook: ClassHook<NSObject> {

    static let targetName = "SPTNowPlayingContentLayerViewModel"

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
