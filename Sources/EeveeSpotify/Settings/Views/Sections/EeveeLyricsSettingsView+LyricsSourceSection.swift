import SwiftUI

extension EeveeLyricsSettingsView {
    
    func lyricsSourceFooter() -> some View {
        var text = "lyrics_source_description".localized

        if Locale.isInRegion("JP", orHasLanguage: "ja") {
            text.append("\n\n")
            text.append("petitlyrics_description".localized)
        }
        
        text.append("\n\n")
        text.append("lyrics_additional_info".localized)
        
        return Text(text)
    }
    
    @ViewBuilder func LyricsSourceSection() -> some View {
        Section(footer: lyricsSourceFooter()) {
            Picker(
                "lyrics_source".localized,
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

                    Text("musixmatch_user_token".localized)
                    
                    TextField("user_token_placeholder".localized, text: $musixmatchToken)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        
        .onChange(of: musixmatchToken) { input in
            if input.isEmpty {
                return
            }
            
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
 
