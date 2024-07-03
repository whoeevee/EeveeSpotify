import Orion
import UIKit

struct ServerSidedReminder: HookGroup { }

class StreamQualitySettingsSectionHook: ClassHook<NSObject> {
    
    typealias Group = ServerSidedReminder
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

private func showOfflineModePopUp() {
    PopUpHelper.showPopUp(
        message: "Native playlist downloading is server-sided and is not available with this tweak. You can download podcast episodes though.", 
        buttonText: "OK"
    )
}

class FTPDownloadActionHook: ClassHook<NSObject> {

    typealias Group = ServerSidedReminder
    static let targetName = "ListUXPlatform_FreeTierPlaylistImpl.FTPDownloadAction"

    func execute(_ idk: Any) {
        showOfflineModePopUp()
    }
}

class UIButtonHook: ClassHook<UIButton> {

    typealias Group = ServerSidedReminder
    
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
