import Foundation

@objc protocol SPTEncorePopUpPresenter {
    static func shared() -> SPTEncorePopUpPresenter
    func presentPopUp(_ popUp: SPTEncorePopUpDialog)
    func dismissPopupWithAnimate(_ animate: Bool, clearQueue: Bool, completion: Any?)
}
