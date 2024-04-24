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

            let filePath = FileManager.default.urls(
                for: .applicationSupportDirectory, in: .userDomainMask
            )
            .first!
            .appendingPathComponent("PersistentCache")
            .appendingPathComponent("offline.bnk")

            if !FileManager.default.fileExists(atPath: filePath.path) {

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {

                    WindowHelper.shared.showPopup(
                        message: "Please log in and restart the app to get Premium.", 
                        buttonText: "Okay!"
                    )
                }

                NSLog("[EeveeSpotify] Not activating due to nonexistent file: \(filePath)")
                return
            }

            let fileData = try Data(contentsOf: filePath)

            let usernameLength = Int(fileData[8])
            let username = Data(fileData[9..<9 + usernameLength])

            var blankData = try BundleHelper.shared.premiumBlankData()

            blankData.insert(UInt8(usernameLength), at: 8)
            blankData.insert(contentsOf: username, at: 9)

            try blankData.write(to: filePath)
            NSLog("[EeveeSpotify] Successfully applied")
        }

        catch {

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {

                WindowHelper.shared.showPopup(
                    message: "Unable to apply tweak: \(error)", 
                    buttonText: "OK"
                )
            }

            NSLog("[EeveeSpotify] Unable to apply tweak: \(error)")
        }
    }
}
