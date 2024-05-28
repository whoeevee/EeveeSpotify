import Orion
import UIKit

func exitApplication() {

    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
        exit(EXIT_SUCCESS)
    }
}

class URLHook: ClassHook<NSURL> {

    func initWithString(_ urlString: String, relativeToURL URL: NSURL) -> NSURL {

        var finalString = urlString

        if finalString.contains("artistview") {
            finalString = finalString.replacingOccurrences(
                of: "trackRows=false", 
                with: "trackRows=true"
            )
            finalString = finalString.replacingOccurrences(
                of: "video=false", 
                with: "video=true"
            )
        }

        return orig.initWithString(finalString, relativeToURL: URL)
    }
}

class ProfileSettingsSectionHook: ClassHook<NSObject> {

    static let targetName = "ProfileSettingsSection"

    func numberOfRows() -> Int {
        return 2
    }

    func didSelectRow(_ row: Int) {

        if row == 1 {

            let rootSettingsController = WindowHelper.shared.findFirstViewController(
                "RootSettingsViewController"
            )!

            let eeveeSettingsController = EeveeSettingsViewController()
            eeveeSettingsController.title = "EeveeSpotify"
            
            rootSettingsController.navigationController!.pushViewController(
                eeveeSettingsController,
                animated: true
            )

            return
        }

        orig.didSelectRow(row)
    }

    func cellForRow(_ row: Int) -> UITableViewCell {
        
        if row == 1 {

            let settingsTableCell = Dynamic.SPTSettingsTableViewCell
                .alloc(interface: SPTSettingsTableViewCell.self)
                .initWithStyle(3, reuseIdentifier: "EeveeSpotify")
            
            let tableViewCell = Dynamic.convert(settingsTableCell, to: UITableViewCell.self)

            tableViewCell.accessoryView = type(
                of: Dynamic.SPTDisclosureAccessoryView
                    .alloc(interface: SPTDisclosureAccessoryView.self)
            )
            .disclosureAccessoryView()
            
            tableViewCell.textLabel?.text = "EeveeSpotify"
            return tableViewCell
        }

        return orig.cellForRow(row)
    }
}

struct EeveeSpotify: Tweak {
    
    static let version = "4.0"
    
    init() {

        do {

            defer {

                if UserDefaults.darkPopUps {
                    DarkPopUps().activate()
                }
                
                let patchType = UserDefaults.patchType
                
                if patchType.isPatching {
                    
                    if patchType == .offlineBnk {
                        NSFileCoordinator.addFilePresenter(OfflineObserver())
                    }
                    
                    ServerSidedReminder().activate()
                }
            }

            switch UserDefaults.patchType {
            
            case .disabled:
                
                NSLog("[EeveeSpotify] Not activating: patchType is disabled")
                return
            
            case .offlineBnk:
                
                do {
                    try OfflineHelper.restoreFromEeveeBnk()
                    
                    NSLog("[EeveeSpotify] Restored from eevee.bnk")
                    return
                }
                
                catch CocoaError.fileReadNoSuchFile {
                    NSLog("[EeveeSpotify] Not restoring from eevee.bnk: doesn't exist")
                }
                
                do {
                    try OfflineHelper.patchOfflineBnk()
                    try OfflineHelper.backupToEeveeBnk()
                }
                
                catch CocoaError.fileReadNoSuchFile {
                    
                    NSLog("[EeveeSpotify] Not activating: offline.bnk doesn't exist")
                    
                    PopUpHelper.showPopUp(
                        delayed: true,
                        message: "Please log in and restart the app to get Premium.",
                        buttonText: "OK"
                    )
                }
            
            default:
                break
            }
        }

        catch {
            
            NSLog("[EeveeSpotify] Unable to apply tweak: \(error)")

            PopUpHelper.showPopUp(
                delayed: true,
                message: "Unable to apply tweak: \(error)", 
                buttonText: "OK"
            )
        }
    }
}
