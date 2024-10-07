import Orion
import UIKit

func exitApplication() {
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
        exit(EXIT_SUCCESS)
    }
}

struct PremiumPatching: HookGroup { }

struct EeveeSpotify: Tweak {
    
    static let version = "5.4"
    static let isOldSpotifyVersion = NSClassFromString("Lyrics_NPVCommunicatorImpl.LyricsOnlyViewController") == nil
    
    init() {
        if UserDefaults.darkPopUps {
            DarkPopUps().activate()
        }
        
        if UserDefaults.patchType.isPatching {
            PremiumPatching().activate()
        }
    }
}
