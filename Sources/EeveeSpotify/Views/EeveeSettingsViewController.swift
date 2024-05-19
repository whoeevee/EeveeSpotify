import SwiftUI
import UIKit 

class EeveeSettingsViewController: UIViewController {

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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = UIHostingController(rootView: EeveeSettingsView())
        hostingController.view.frame = view.bounds

        view.addSubview(hostingController.view)
        addChild(hostingController)
        hostingController.didMove(toParent: self)
    }
}
