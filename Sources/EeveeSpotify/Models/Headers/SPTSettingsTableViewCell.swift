import Foundation

@objc protocol SPTSettingsTableViewCell {
    func initWithStyle(_ style: Int, reuseIdentifier: String) -> SPTSettingsTableViewCell
}