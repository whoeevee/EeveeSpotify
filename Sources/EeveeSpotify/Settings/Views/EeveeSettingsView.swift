import SwiftUI
import UIKit

struct EeveeSettingsView: View {
    
    let navigationController: UINavigationController
    
    @State var latestVersion = ""
    @State var hasShownCommonIssuesTip = UserDefaults.hasShownCommonIssuesTip
    
    private func pushSettingsController(with view: any View, title: String) {
        let viewController = EeveeSettingsViewController(
            navigationController.view.frame,
            settingsView: AnyView(view),
            navigationTitle: title
        )
        navigationController.pushViewController(viewController, animated: true)
    }

    var body: some View {
        List {
            
            VersionSection()
            
            if !hasShownCommonIssuesTip {
                CommonIssuesTipView(
                    onDismiss: {
                        hasShownCommonIssuesTip = true
                        UserDefaults.hasShownCommonIssuesTip = true
                    }
                )
            }
            
            //
            
            Button {
                pushSettingsController(with: EeveePatchingSettingsView(), title: "Patching")
            } label: {
                NavigationSectionView(
                    color: .orange,
                    title: "Patching",
                    imageSystemName: "hammer.fill"
                )
            }
            
            Button {
                pushSettingsController(with: EeveeLyricsSettingsView(), title: "Lyrics")
            } label: {
                NavigationSectionView(
                    color: .blue,
                    title: "Lyrics",
                    imageSystemName: "quote.bubble.fill"
                )
            }
            
            Button {
                pushSettingsController(with: EeveeUISettingsView(), title: "Customization")
            } label: {
                NavigationSectionView(
                    color: Color(hex: "#64D2FF"),
                    title: "Customization",
                    imageSystemName: "paintpalette.fill"
                )
            }
            
            //
            
            Section(footer: Text("Clear cached data and restart the app.")) {
                Button {
                    try! OfflineHelper.resetPersistentCache()
                    exitApplication()
                } label: {
                    Text("Reset Data")
                }
            }
        }
        
        .listStyle(GroupedListStyle())
        
        .animation(.default, value: latestVersion)
        .animation(.default, value: hasShownCommonIssuesTip)
        
        .onAppear {
            WindowHelper.shared.overrideUserInterfaceStyle(.dark)
            
            Task {
                try await loadVersion()
            }
        }
    }
}
