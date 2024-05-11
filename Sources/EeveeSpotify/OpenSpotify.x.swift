import Orion
import UIKit

class SpotifySceneDelegateHook: ClassHook<NSObject> {

    static let targetName = "MusicApp_ContainerWiring.SpotifySceneDelegate"

    func scene(_ scene: UIScene, continueUserActivity userActivity: NSUserActivity) {
        orig.scene(scene, continueUserActivity: userActivity)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {

        let url = URLContexts.first!.url

        if url.host == "eevee" {
            
            let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
            userActivity.webpageURL = URL(string: "https:/\(url.path)")

            orig.scene(scene, continueUserActivity: userActivity)
            return
        }
    
        orig.scene(scene, openURLContexts: URLContexts)
    }
}
