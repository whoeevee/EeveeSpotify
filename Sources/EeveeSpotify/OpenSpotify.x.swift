import Orion
import UIKit

class UIOpenURLContextHook: ClassHook<NSObject> {

    static let targetName = "UIOpenURLContext"

    func URL() -> URL {
        let url = orig.URL()

        if url.isOpenSpotifySafariExtension {
            return Foundation.URL(string: "https:/\(orig.URL().path)")!
        }

        return url
    }
}
