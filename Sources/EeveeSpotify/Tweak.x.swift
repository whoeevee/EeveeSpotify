import Orion

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

struct EeveeSpotify: Tweak {
    
    init() {

        do {

            defer {
                NSFileCoordinator.addFilePresenter(OfflineObserver())
            }

            do {
                try OfflineHelper.restoreFromEeveeBnk()
                NSLog("[EeveeSpotify] Restored from eevee.bnk")

                return
            }

            catch CocoaError.fileReadNoSuchFile {
                NSLog("[EeveeSpotify] Not restoring from eevee.bnk: doesn't exist")
            }

            //

            do {
                try OfflineHelper.patchOfflineBnk()
                try OfflineHelper.backupToEeveeBnk()
            }

            catch CocoaError.fileReadNoSuchFile {

                NSLog("[EeveeSpotify] Not activating: offline.bnk doesn't exist")

                PopUpHelper.showPopUp(
                    delayed: true,
                    message: "Please log in and restart the app to get Premium.", 
                    buttonText: "Okay!"
                )
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
