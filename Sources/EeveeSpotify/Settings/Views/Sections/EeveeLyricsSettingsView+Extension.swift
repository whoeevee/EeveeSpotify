import SwiftUI

extension EeveeLyricsSettingsView {
    func getMusixmatchToken(_ input: String) -> String? {
        if let match = input.firstMatch("\\[UserToken\\]: ([a-f0-9]+)"),
            let tokenRange = Range(match.range(at: 1), in: input) {
            return String(input[tokenRange])
        }
        else if input ~= "^[a-f0-9]+$" {
            return input
        }
        
        return nil
    }
    
    func showMusixmatchTokenAlert(_ oldSource: LyricsSource) {
        let alert = UIAlertController(
            title: "enter_user_token".localized,
            message: "enter_user_token_message".localized,
            preferredStyle: .alert
        )
        
        alert.addTextField() { textField in
            textField.placeholder = "---- Debug Info ---- [Device]: iPhone"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".uiKitLocalized, style: .cancel) { _ in
            lyricsSource = oldSource
        })

        alert.addAction(UIAlertAction(title: "OK".uiKitLocalized, style: .default) { _ in
            let text = alert.textFields!.first!.text!
            
            guard let token = getMusixmatchToken(text) else {
                lyricsSource = oldSource
                return
            }

            musixmatchToken = token
            UserDefaults.lyricsSource = .musixmatch
        })
        
        WindowHelper.shared.present(alert)
    }
}
 
