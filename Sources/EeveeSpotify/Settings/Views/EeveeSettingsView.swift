import SwiftUI
import UIKit

struct EeveeSettingsView: View {

    @State var musixmatchToken = UserDefaults.musixmatchToken
    @State var patchType = UserDefaults.patchType
    @State var lyricsSource = UserDefaults.lyricsSource
    @State var overwriteConfiguration = UserDefaults.overwriteConfiguration
    
    private func getMusixmatchToken(_ input: String) -> String? {
        
        if let match = input.firstMatch("\\[UserToken\\]: ([a-f0-9]+)"),
            let tokenRange = Range(match.range(at: 1), in: input) {
            return String(input[tokenRange])
        }
        else if input ~= "^[a-f0-9]+$" {
            return input
        }
        
        return nil
    }

    private func showMusixmatchTokenAlert(_ oldSource: LyricsSource) {

        let alert = UIAlertController(
            title: "Enter User Token",
            message: "In order to use Musixmatch, you need to retrieve your user token from the official app. Download Musixmatch from the App Store, sign up, then go to Settings > Get help > Copy debug info, and paste it here. You can also extract the token using MITM.",
            preferredStyle: .alert
        )
        
        alert.addTextField() { textField in
            textField.placeholder = "---- Debug Info ---- [Device]: iPhone"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            lyricsSource = oldSource
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
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

    var body: some View {

        List {
            
            PremiumSections()
            
            LyricsSections()

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
        }
        
        .listStyle(GroupedListStyle())
        
        .padding(.bottom, 60)
        .ignoresSafeArea(.keyboard)
        
        .animation(.default, value: lyricsSource)
        .animation(.default, value: patchType)

        .onChange(of: musixmatchToken) { input in
            
            if input.isEmpty { return }
            
            if let token = getMusixmatchToken(input) {
                UserDefaults.musixmatchToken = token
                self.musixmatchToken = token
            }
            else {
                self.musixmatchToken = ""
            }
        }

        .onChange(of: lyricsSource) { [lyricsSource] newSource in

            if newSource == .musixmatch && musixmatchToken.isEmpty {
                showMusixmatchTokenAlert(lyricsSource)
                return
            }

            UserDefaults.lyricsSource = newSource
        }
        
        .onChange(of: patchType) { newPatchType in
            
            UserDefaults.patchType = newPatchType
            
            do {
                try OfflineHelper.resetOfflineBnk()
            }
            catch {
                NSLog("Unable to reset offline.bnk: \(error)")
            }
        }
        
        .onChange(of: overwriteConfiguration) { overwriteConfiguration in
            
            UserDefaults.overwriteConfiguration = overwriteConfiguration
            
            do {
                try OfflineHelper.resetOfflineBnk()
            }
            catch {
                NSLog("Unable to reset offline.bnk: \(error)")
            }
        }

        .onAppear {
            UIView.appearance(
                whenContainedInInstancesOf: [UIAlertController.self]
            ).tintColor = UIColor(Color(hex: "#1ed760"))

            WindowHelper.shared.overrideUserInterfaceStyle(.dark)
        }
    }
}
