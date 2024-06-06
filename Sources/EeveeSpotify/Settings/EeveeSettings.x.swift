import Orion
import UIKit

class ProfileSettingsSectionHook: ClassHook<NSObject> {

    static let targetName = "ProfileSettingsSection"

    func numberOfRows() -> Int {
        return 2
    }

    func didSelectRow(_ row: Int) {

        if row == 1 {

            let rootSettingsController = WindowHelper.shared.findFirstViewController(
                "RootSettingsViewController"
            )!

            let eeveeSettingsController = EeveeSettingsViewController(rootSettingsController.view.bounds)
            
            rootSettingsController.navigationController!.pushViewController(
                eeveeSettingsController,
                animated: true
            )

            return
        }

        orig.didSelectRow(row)
    }

    func cellForRow(_ row: Int) -> UITableViewCell {
        
        if row == 1 {

            let settingsTableCell = Dynamic.SPTSettingsTableViewCell
                .alloc(interface: SPTSettingsTableViewCell.self)
                .initWithStyle(3, reuseIdentifier: "EeveeSpotify")
            
            let tableViewCell = Dynamic.convert(settingsTableCell, to: UITableViewCell.self)

            tableViewCell.accessoryView = type(
                of: Dynamic.SPTDisclosureAccessoryView
                    .alloc(interface: SPTDisclosureAccessoryView.self)
            )
            .disclosureAccessoryView()
            
            tableViewCell.textLabel?.text = "EeveeSpotify"
            return tableViewCell
        }

        return orig.cellForRow(row)
    }
}
