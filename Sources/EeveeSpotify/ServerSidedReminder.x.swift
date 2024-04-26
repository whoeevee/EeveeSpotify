import Orion
import UIKit

class StreamQualitySettingsSectionHook: ClassHook<NSObject> {
    
    static let targetName = "StreamQualitySettingsSection"

    func shouldResetSelection() -> Bool {

        PopUpHelper.showPopUp(
            message: "Very high audio quality is server-sided and is not available with this tweak.", 
            buttonText: "OK"
        )

        return true
    }
}

//

func showOfflineModePopUp() {
    PopUpHelper.showPopUp(
        message: "Native playlist downloading is server-sided and is not available with this tweak. You can download podcast episodes though.", 
        buttonText: "OK"
    )
}

class FTPDownloadActionHook: ClassHook<NSObject> {
    
    static let targetName = "ListUXPlatform_FreeTierPlaylistImpl.FTPDownloadAction"

    func execute(_ idk: Any) {
        showOfflineModePopUp()
    }
}

class UIButtonHook: ClassHook<UIButton> {

    func setHighlighted(_ highlighted: Bool) {

        if highlighted {

            if let identifier = target.accessibilityIdentifier, identifier.contains("DownloadButton") {

                let vcDescription = String(describing: WindowHelper.shared.viewController(for: target))

                if !(vcDescription ~= "Podcast|CreativeWorkPlatform") {

                    target.removeTarget(nil, action: nil, for: .allEvents)
                    showOfflineModePopUp()

                    return
                }
            }
        }

        orig.setHighlighted(highlighted)
    }
}