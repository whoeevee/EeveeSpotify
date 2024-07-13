import UIKit

@objc protocol SPTEncorePopUpDialog {
    func `init`() -> SPTEncorePopUpDialog
    func uiView() -> UIView
    func update(_ popUpModel: SPTEncorePopUpDialogModel)
    func setEventHandler(_ handler: @escaping (_ state: ClickState) -> Void)
}

@objc enum ClickState: Int {
    case primary
    case secondary
}
