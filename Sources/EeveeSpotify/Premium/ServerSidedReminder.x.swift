import Orion
import UIKit

class StreamQualitySettingsSectionHook: ClassHook<NSObject> {
    typealias Group = PremiumPatchingGroup
    static let targetName = "StreamQualitySettingsSection"

    func shouldResetSelection() -> Bool {
        PopUpHelper.showPopUp(
            message: "high_audio_quality_popup".localized,
            buttonText: "OK".uiKitLocalized
        )

        return true
    }
}

class ContentOffliningUIHelperImplementationHook: ClassHook<NSObject> {
    typealias Group = PremiumPatchingGroup
    static let targetName = "Offline_ContentOffliningUIImpl.ContentOffliningUIHelperImplementation"
    
    func downloadToggledWithCurrentAvailability(
        _ availability: Int,
        addAction: NSObject,
        removeAction: NSObject,
        pageIdentifier: String,
        pageURI: URL
    ) -> String? {
        let isPlaylist = [
            "free-tier-playlist",
            "playlist/ondemand"
        ].contains(pageIdentifier)
        
        PopUpHelper.showPopUp(
            message: "playlist_downloading_popup".localized,
            buttonText: "OK".uiKitLocalized,
            secondButtonText: isPlaylist
                ? "download_local_playlist".localized
                : nil,
            onSecondaryClick: isPlaylist
                ? {
                    _ = self.orig.downloadToggledWithCurrentAvailability(
                        availability,
                        addAction: addAction,
                        removeAction: removeAction,
                        pageIdentifier: pageIdentifier,
                        pageURI: pageURI
                    )
                }
                : nil
        )
        
        return nil
    }
}
