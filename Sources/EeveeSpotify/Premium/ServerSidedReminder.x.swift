import Orion
import UIKit

class StreamQualitySettingsSectionHook: ClassHook<NSObject> {
    typealias Group = PremiumPatching
    static let targetName = "StreamQualitySettingsSection"

    func shouldResetSelection() -> Bool {
        PopUpHelper.showPopUp(
            message: "high_audio_quality_popup".localized,
            buttonText: "ok".localized
        )

        return true
    }
}

//

private func showOfflineModePopUp() {
    PopUpHelper.showPopUp(
        message: "playlist_downloading_popup".localized,
        buttonText: "ok".localized
    )
}

class ContentOffliningUIHelperImplementationHook: ClassHook<NSObject> {
    typealias Group = PremiumPatching
    static let targetName = "Offline_ContentOffliningUIImpl.ContentOffliningUIHelperImplementation"
    
    func downloadToggledWithCurrentAvailability(
        _ availability: Int,
        addAction: NSObject,
        removeAction: NSObject,
        pageIdentifier: String,
        pageURI: URL
    ) -> String {
        showOfflineModePopUp()
        return pageIdentifier
    }
}
