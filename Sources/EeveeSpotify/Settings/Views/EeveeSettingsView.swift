import SwiftUI
import UIKit

struct EeveeSettingsView: View {

    @State var musixmatchToken = UserDefaults.musixmatchToken
    @State var patchType = UserDefaults.patchType
    @State var overwriteConfiguration = UserDefaults.overwriteConfiguration
    
    @State var lyricsSource = UserDefaults.lyricsSource
    @State var lyricsColors = UserDefaults.lyricsColors
    
    @State var latestVersion = ""

    var body: some View {

        List {
            VersionSection()
            
            PremiumSections()
            
            LyricsSections()
            
            LyricsColorsSection()

            Section {
                Toggle(
                    "Dark PopUps",
                    isOn: Binding<Bool>(
                        get: { UserDefaults.darkPopUps },
                        set: { UserDefaults.darkPopUps = $0 }
                    )
                )
            }
            
            Section(footer: Text("Clear cached data and restart the app.")) {
                Button {
                    try! OfflineHelper.resetPersistentCache()
                    exitApplication()
                } label: {
                    Text("Reset Data")
                }
            }
            
            if !UIDevice.current.isIpad {
                Spacer()
                    .frame(height: 40)
                    .listRowBackground(Color.clear)
                    .modifier(ListRowSeparatorHidden())
            }
        }
        
        .listStyle(GroupedListStyle())
        .ignoresSafeArea(.keyboard)
        
        .animation(.default, value: lyricsSource)
        .animation(.default, value: patchType)
        .animation(.default, value: lyricsColors)
        .animation(.default, value: latestVersion)
        
        .onAppear {
            UIView.appearance(
                whenContainedInInstancesOf: [UIAlertController.self]
            ).tintColor = UIColor(Color(hex: "#1ed760"))

            WindowHelper.shared.overrideUserInterfaceStyle(.dark)
            
            Task {
                try await loadVersion()
            }
        }
    }
}
