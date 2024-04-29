import Foundation
import UIKit

func exitApplication() {

    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
        exit(EXIT_SUCCESS)
    }
}

class OfflineObserver: NSObject, NSFilePresenter {
    
    var presentedItemURL: URL?
    var presentedItemOperationQueue: OperationQueue

    override init() {
        presentedItemURL = OfflineHelper.offlineBnkPath
        presentedItemOperationQueue = .main
    }
    
    func presentedItemDidChange() {

        let productState = HookedInstances.productState!

        if productState.stringForKey("player-license") == "premium" {

            do {
                try OfflineHelper.backupToEeveeBnk()
                NSLog("[EeveeSpotify] Settings has changed, updated eevee.bnk")
            }
            catch {
                NSLog("[EeveeSpotify] Unable to update eevee.bnk: \(error)")
            }

            return
        }

        PopUpHelper.showPopUp(
            message: "Spotify has just reloaded user data, and you've been switched to the Free plan. It's fine; simply restart the app, and the tweak will patch the data again. If this doesn't work, there might be a problem with the saved data. You can reset it and restart the app. Note: after resetting, you need to restart the app twice.", 
            buttonText: "Restart App",
            secondButtonText: "Reset Data and Restart App",
            onPrimaryClick: { 
                exitApplication() 
            },
            onSecondaryClick: {
                try! FileManager.default.removeItem(at: OfflineHelper.persistentCachePath)
                exitApplication()
            }
        )
    }
}
