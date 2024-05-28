import SwiftUI
import UIKit

struct EeveeSettingsView: View {

    @State private var musixmatchToken = UserDefaults.musixmatchToken
    @State private var patchType = UserDefaults.patchType
    @State private var lyricsSource = UserDefaults.lyricsSource

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
            let token: String

            if let match = text.firstMatch("\\[UserToken\\]: ([a-f0-9]+)"), 
                let tokenRange = Range(match.range(at: 1), in: text) {
                token = String(text[tokenRange])
            }
            else if text ~= "^[a-f0-9]+$" {
                token = text
            }
            else {
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
            
            Section(footer: patchType == .disabled ? nil : Text("""
You can select the Premium patching method you prefer. App restart is required after changing.

Static: The original method. On app start, the tweak composes cache data by inserting your username into a blank file with preset Premium parameters. When Spotify reloads user data, you'll be switched to the Free plan and see a popup with quick restart app and reset data actions.

Dynamic: This method intercepts requests to load user data, deserializes it, and modifies the parameters in real-time. It's much more stable and is recommended.

If you have an active Premium subscription, you can turn on Do Not Patch Premium. The tweak won't patch the data or restrict the use of Premium server-sided features.
""")) {
                Toggle(
                    "Do Not Patch Premium",
                    isOn: Binding<Bool>(
                        get: { patchType == .disabled },
                        set: { patchType = $0 ? .disabled : .offlineBnk }
                    )
                )
                if patchType != .disabled {
                    Picker(
                        "Patching Method",
                        selection: $patchType
                    ) {
                        Text("Static").tag(PatchType.offlineBnk)
                        Text("Dynamic").tag(PatchType.requests)
                    }
                }
            }
            
            Section(footer: Text("""
You can select the lyrics source you prefer.

Genius: Offers the best quality lyrics, provides the most songs, and updates lyrics the fastest. Does not and will never be time-synced.

LRCLIB: The most open service, offering time-synced lyrics. However, it lacks lyrics for many songs.

Musixmatch: The service Spotify uses. Provides time-synced lyrics for many songs, but you'll need a user token to use this source.

If the tweak is unable to find a song or process the lyrics, you'll see a "Couldn't load the lyrics for this song" message. The lyrics might be wrong for some songs (e.g. another song, song article) when using Genius due to how the tweak searches songs. I've made it work in most cases.
""")) {
                Picker(
                    "Lyrics Source", 
                    selection: $lyricsSource
                ) {
                    Text("Genius").tag(LyricsSource.genius)
                    Text("LRCLIB").tag(LyricsSource.lrclib)
                    Text("Musixmatch").tag(LyricsSource.musixmatch)
                }

                if lyricsSource == .musixmatch {

                    VStack(alignment: .leading, spacing: 5) {

                        Text("Musixmatch User Token")
                        
                        TextField("Enter User Token", text: $musixmatchToken)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if lyricsSource != .genius {
                Section(
                    footer: Text("Load lyrics from Genius if there is a problem with \(lyricsSource).")
                ) {
                    Toggle(
                        "Genius Fallback",
                        isOn: Binding<Bool>(
                            get: { UserDefaults.geniusFallback },
                            set: { UserDefaults.geniusFallback = $0 }
                        )
                    )
                }
            }

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

        .padding(.bottom, 40)
        
        .animation(.default, value: lyricsSource)
        .animation(.default, value: patchType)

        .onChange(of: musixmatchToken) { token in
            UserDefaults.musixmatchToken = token
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

        .listStyle(GroupedListStyle())

        .onAppear {
            UIView.appearance(
                whenContainedInInstancesOf: [UIAlertController.self]
            ).tintColor = UIColor(Color(hex: "#1ed760"))

            WindowHelper.shared.overrideUserInterfaceStyle(.dark)
        }
    }
}
