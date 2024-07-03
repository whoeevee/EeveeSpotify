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

                if !label.hasParent("Primary") {
                    label.textColor = .white
                }
            }
        }

        return orig.intrinsicContentSize()
    }
}

class SPTEncorePopUpDialogHook: ClassHook<UIView> {

    typealias Group = DarkPopUps
    static let targetName = "_TtCO12EncoreMobile5ViewsP33_5A611B064D744992F9E8B522D8DE459B10ScrollView"

    func intrinsicContentSize() -> CGSize {

        if target.accessibilityIdentifier == "PopUp.Dialog" {
            target.backgroundColor = UIColor(Color(hex: "#242424"))
        }

        return orig.intrinsicContentSize()
    }
}
