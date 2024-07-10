import Orion
import UIKit
import SwiftUI

struct DarkPopUps: HookGroup { }

class EncoreLabelHook: ClassHook<UIView> {

    typealias Group = DarkPopUps
    static let targetName = "SPTEncoreLabel"

    func intrinsicContentSize() -> CGSize {

        if let viewController = WindowHelper.shared.viewController(for: target) {
            
            if NSStringFromClass(type(of: viewController)) == "SPTEncorePopUpContainer" {

                let label = Dynamic.convert(target.subviews.first!, to: UILabel.self)

                if !label.hasParent(matching: "Primary") {
                    label.textColor = .white
                }
            }
        }

        return orig.intrinsicContentSize()
    }
}

class SPTEncorePopUpDialogHook: ClassHook<NSObject> {

    typealias Group = DarkPopUps
    static let targetName = "SPTEncorePopUpDialog"

    func uiView() -> UIView {
        let view = orig.uiView()
        view.backgroundColor = UIColor(Color(hex: "#242424"))
        
        return view
    }
}
