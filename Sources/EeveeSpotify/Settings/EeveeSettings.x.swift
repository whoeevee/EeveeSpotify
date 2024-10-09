import Orion
import SwiftUI
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
            
            let navigationController = rootSettingsController.navigationController!

            let eeveeSettingsController = EeveeSettingsViewController(
                rootSettingsController.view.bounds,
                settingsView: AnyView(EeveeSettingsView(navigationController: navigationController)),
                navigationTitle: "EeveeSpotify"
            )
            
            //
            
            let button = UIButton()

            button.setImage(
                BundleHelper.shared.uiImage("github").withRenderingMode(.alwaysOriginal),
                for: .normal
            )
            
            button.addTarget(
                eeveeSettingsController,
                action: #selector(eeveeSettingsController.openRepositoryUrl(_:)),
                for: .touchUpInside
            )
            
            //
            
            let menuBarItem = UIBarButtonItem(customView: button)
            
            menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 22).isActive = true
            menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 22).isActive = true

            eeveeSettingsController.navigationItem.rightBarButtonItem = menuBarItem
            
            navigationController.pushViewController(
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
