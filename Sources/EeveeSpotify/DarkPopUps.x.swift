import Orion
import UIKit
import SwiftUI

struct DarkPopUps: HookGroup { }

class EncoreLabelHook: ClassHook<UIView> {

    typealias Group = DarkPopUps
    static let targetName = "SPTEncoreLabel"

    func intrinsicContentSize() -> CGSize {

        if String(
            describing: WindowHelper.shared.viewController(for: target)
        ) ~= "SPTEncorePopUpContainer" {

            let label = Dynamic.convert(target.subviews.first!, to: UILabel.self)
            
            let superview: UIView?
            
            if #available(iOS 15.0, *) {
                superview = target.superview?.superview?.superview?.superview
            } else {
                superview = target.superview?.superview?.superview
            }

            if !(String(describing: superview) ~= "Primary") {
                label.textColor = .white
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
