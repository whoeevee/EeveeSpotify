import UIKit

class SPTPageViewController: UIViewController {

    override func conforms(to aProtocol: Protocol) -> Bool {
        
        if NSStringFromProtocol(aProtocol) ~= "SPTPageController" {
            return true
        }
        
        return super.conforms(to: aProtocol)
    }

    @objc func spt_pageIdentifier() -> String? {
        return "EeveeSpotify"
    }

    @objc func spt_pageURI() -> NSURL? {
        return NSURL(string: "")
    }
}
