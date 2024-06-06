import SwiftUI
import UIKit 

class EeveeSettingsViewController: SPTPageViewController {
    
    let frame: CGRect
    
    init(_ frame: CGRect) {
        self.frame = frame
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "EeveeSpotify"
        
        let hostingController = UIHostingController(rootView: EeveeSettingsView())
        hostingController.view.frame = frame
        
        view.addSubview(hostingController.view)
        addChild(hostingController)
        hostingController.didMove(toParent: self)
    }
}
