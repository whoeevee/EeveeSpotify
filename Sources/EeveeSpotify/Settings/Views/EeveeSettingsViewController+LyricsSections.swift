import SwiftUI

extension EeveeSettingsView {
    
    @ViewBuilder func LyricsSections() -> some View {
        
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
                    
                    TextField("Enter User Token or Paste Debug Info", text: $musixmatchToken)
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
}
 
