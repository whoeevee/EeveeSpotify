import UIKit
import Orion
import Foundation

class PopUpHelper {
    
    static let sharedPresenter = type(
        of: Dynamic.SPTEncorePopUpPresenter
        .alloc(interface: SPTEncorePopUpPresenter.self)
    )
    .shared()

    static func showPopUp(
        message: String,
        buttonText: String
    ) {

        let model = Dynamic.SPTEncorePopUpDialogModel
            .alloc(interface: SPTEncorePopUpDialogModel.self)
            .initWithTitle(
                "EeveeSpotify",
                description: message,
                image: nil,
                primaryButtonTitle: buttonText,
                secondaryButtonTitle: nil
            )

        let dialog = Dynamic.SPTEncorePopUpDialog
            .alloc(interface: SPTEncorePopUpDialog.self)
            .`init`()
        
        dialog.update(model)
        dialog.setEventHandler({ 
            sharedPresenter.dismissPopupWithAnimate(true, clearQueue: false, completion: nil)
        })

       sharedPresenter.presentPopUp(dialog)
    }
}
