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

class FTPDownloadActionHook: ClassHook<NSObject> {
    typealias Group = PremiumPatching
    static let targetName = "ListUXPlatform_FreeTierPlaylistImpl.FTPDownloadAction"

    func execute(_ idk: Any) {
        showOfflineModePopUp()
    }
}

class UIButtonHook: ClassHook<UIButton> {
    typealias Group = PremiumPatching
    
    func setHighlighted(_ highlighted: Bool) {

        if highlighted {

            if let identifier = target.accessibilityIdentifier, identifier.contains("DownloadButton"),
            let viewController = WindowHelper.shared.viewController(for: target) {

                if !(NSStringFromClass(type(of: viewController)) ~= "Podcast|CreativeWorkPlatform") {

                    target.removeTarget(nil, action: nil, for: .allEvents)
                    showOfflineModePopUp()

                    return
                }
            }
        }

        orig.setHighlighted(highlighted)
    }
}
