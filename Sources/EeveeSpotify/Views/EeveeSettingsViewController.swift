import SwiftUI
import UIKit 

class EeveeSettingsViewController: UIViewController {
    
    let frame: CGRect
    init(_ frame: CGRect) {
        self.frame = frame
        super.init(nibName: nil, bundle: nil)
    }

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

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
        hostingController.view.frame = frame

        view.addSubview(hostingController.view)
        addChild(hostingController)
        hostingController.didMove(toParent: self)
    }
}
