import SwiftUI
import UIKit 

class EeveeSettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = UIHostingController(rootView: EeveeSettingsView())
        hostingController.view.frame = view.bounds

        view.addSubview(hostingController.view)
        addChild(hostingController)
        hostingController.didMove(toParent: self)
    }
}
