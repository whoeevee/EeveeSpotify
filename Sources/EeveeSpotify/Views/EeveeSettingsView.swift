import SwiftUI
import UIKit

struct EeveeSettingsView: View {

    @State private var musixmatchToken = UserDefaults.musixmatchToken
    @State private var lyricsSource = UserDefaults.lyricsSource

    private func showMusixmatchTokenAlert(_ oldSource: LyricsSource) {

        let alert = UIAlertController(
            title: "Enter User Token",
            message: "In order to use Musixmatch, you need to retrieve your user token from the official app. Download Musixmatch from the App Store, sign up, and extract the token using MITM.",
            preferredStyle: .alert
        )
        
        alert.addTextField() { textField in
            textField.placeholder = Data.musixmatchTokenPlaceholder
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            lyricsSource = oldSource
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let token = alert.textFields!.first!.text!

            if !(token ~= "^[a-f0-9]+$") {
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

            Section(footer: Text("""
You can select the lyrics source you prefer.

Genius: Offers the best quality lyrics, provides the most songs, and updates lyrics the fastest. Does not and will never be time-synced.

LRCLIB: The most open service, offering time-synced lyrics. However, it lacks lyrics for many songs.

Musixmatch: The service Spotify uses. Provides time-synced lyrics for many songs, but you'll need a user token to use this source.

If the tweak is unable to find a song or process the lyrics, you'll see the original Spotify one or a "Couldn't load the lyrics for this song" message. The lyrics might be wrong for some songs (e.g. another song, song article) when using Genius due to how the tweak searches songs. I've made it work in most cases.
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
        }

        .padding(.bottom, 50)

        .animation(.default, value: lyricsSource)

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

        .listStyle(GroupedListStyle())

        .onAppear {
            UIView.appearance(
                whenContainedInInstancesOf: [UIAlertController.self]
            ).tintColor = UIColor(Color(hex: "#1ed760"))

            WindowHelper.shared.overrideUserInterfaceStyle(.dark)
        }
    }
}