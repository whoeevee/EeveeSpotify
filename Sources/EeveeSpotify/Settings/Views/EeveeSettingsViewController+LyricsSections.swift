import SwiftUI

extension EeveeSettingsView {
    
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
    
    
    @ViewBuilder func LyricsSections() -> some View {
        
        Section(footer: Text("""
You can select the lyrics source you prefer.

Genius: Offers the best quality lyrics, provides the most songs, and updates lyrics the fastest. Does not and will never be time-synced.

LRCLIB: The most open service, offering time-synced lyrics. However, it lacks lyrics for many songs.

Musixmatch: The service Spotify uses. Provides time-synced lyrics for many songs, but you'll need a user token to use this source.

If the tweak is unable to find a song or process the lyrics, you'll see a "Couldn't load the lyrics for this song" message. The lyrics might be wrong for some songs when using Genius due to how the tweak searches songs. I've made it work in most cases.
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
                    
                    TextField("Enter User Token or Paste Debug Info", text: $musixmatchToken)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        
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
                
                Toggle(
                    "Show Fallback Reasons",
                    isOn: Binding<Bool>(
                        get: { UserDefaults.fallbackReasons },
                        set: { UserDefaults.fallbackReasons = $0 }
                    )
                )
            }
        }
    }
}
 
