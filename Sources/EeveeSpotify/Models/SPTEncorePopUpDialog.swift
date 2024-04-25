import Foundation

@objc protocol SPTEncorePopUpDialog {
    func `init`() -> SPTEncorePopUpDialog
    func update(_ popUpModel: SPTEncorePopUpDialogModel)
    func setEventHandler(_ handler: @escaping () -> Void)
}