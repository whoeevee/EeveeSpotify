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
            NSLog("[EeveeSpotify] Unable to apply tweak: \(error)")
        }
    }
}
