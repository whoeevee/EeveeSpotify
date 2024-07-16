import SwiftUI

extension EeveeLyricsSettingsView {
    
    func lyricsSourceFooter() -> some View {
        var text = """
You can select the lyrics source you prefer.

Genius: Offers the best quality lyrics, provides the most songs, and updates lyrics the fastest. Does not and will never be time-synced.

LRCLIB: The most open service, offering time-synced lyrics. However, it lacks lyrics for many songs.

Musixmatch: The service Spotify uses. Provides time-synced lyrics for many songs, but you'll need a user token to use this source.
"""

        if Locale.isInRegion("JP", orHasLanguage: "ja") {
            text.append("\n\n")
            text.append("PetitLyrics: Offers plenty of time-synced Japanese and some international lyrics.")
        }
        
        text.append("\n\n")

        text.append("""
If the tweak is unable to find a song or process the lyrics, you'll see a "Couldn't load the lyrics for this song" message. The lyrics might be wrong for some songs when using Genius due to how the tweak searches songs. I've made it work in most cases.
""")
        
        return Text(text)
    }
    
    @ViewBuilder func LyricsSourceSection() -> some View {
        Section(footer: lyricsSourceFooter()) {
            Picker(
                "Lyrics Source",
                selection: $lyricsSource
            ) {
                Text("Genius").tag(LyricsSource.genius)
                Text("LRCLIB").tag(LyricsSource.lrclib)
                Text("Musixmatch").tag(LyricsSource.musixmatch)
                if Locale.isInRegion("JP", orHasLanguage: "ja") {
                    Text("PetitLyrics").tag(LyricsSource.petit)
                }
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
    }
}
 
