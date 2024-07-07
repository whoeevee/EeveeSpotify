import SwiftUI

extension EeveeSettingsView {
    @ViewBuilder func LyricsOptionsSection() -> some View {
        if lyricsSource == .genius || geniusFallback {
            Section {
                Toggle(
                    "Romanized Genius Lyrics",
                    isOn: $lyricsOptions.geniusRomanizations
                )
            }
            .onChange(of: lyricsOptions) { lyricsOptions in
                UserDefaults.lyricsOptions = lyricsOptions
            }
        }
        if lyricsSource == .musixmatch {
            Section {
                Toggle(
                    "Romanized MusixMatch Lyrics",
                    isOn: $lyricsOptions.musixmatchRomanizations
                )
            }
            .onChange(of: lyricsOptions) { lyricsOptions in
                UserDefaults.lyricsOptions = lyricsOptions
            }
        }
    }
}
