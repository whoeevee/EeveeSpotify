import Foundation

@objc protocol SPTEncorePopUpDialogModel {
    func initWithTitle(
        _ title: String, 
        description: String, 
        image: Any?, 
        primaryButtonTitle: String, 
        secondaryButtonTitle: String?
    ) -> SPTEncorePopUpDialogModel
}