import Orion
import UIKit

class HookedInstances {
    static var productState: SPTCoreProductState?
    static var currentTrack: SPTPlayerTrack?
    static var nowPlayingMetaBackgroundModel: SPTNowPlayingMetadataBackgroundViewModel?
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

class SPTNowPlayingMetadataBackgroundViewModelHook: ClassHook<NSObject> {
    static let targetName = "SPTNowPlayingMetadataBackgroundViewModel"
    
    func color() -> UIColor {
        HookedInstances.nowPlayingMetaBackgroundModel = Dynamic.convert(
            target,
            to: SPTNowPlayingMetadataBackgroundViewModel.self
        )
        return orig.color()
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
