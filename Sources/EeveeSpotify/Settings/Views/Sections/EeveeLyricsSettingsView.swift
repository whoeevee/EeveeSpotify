import SwiftUI

struct EeveeLyricsSettingsView: View {
    
    @State var musixmatchToken = UserDefaults.musixmatchToken
    @State var lyricsSource = UserDefaults.lyricsSource
    @State var geniusFallback = UserDefaults.geniusFallback
    @State var lyricsOptions = UserDefaults.lyricsOptions

    @State var showLanguageWarning = false
    
    var body: some View {
        List {
            
            LyricsSourceSection()

            if lyricsSource != .genius {
                Section(
                    footer: Text("Load lyrics from Genius if there is a problem with \(lyricsSource).")
                ) {
                    Toggle(
                        "Genius Fallback",
                        isOn: $geniusFallback
                    )
                    
                    if geniusFallback {
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
            
            //
            
            Section(footer: Text("Display romanized lyrics for Japanese, Korean, and Chinese.")) {
                Toggle(
                    "Romanized Lyrics",
                    isOn: $lyricsOptions.romanization
                )
            }
            
            if lyricsSource == .musixmatch {
                Section {
                    HStack {
                        if showLanguageWarning {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title3)
                                .foregroundColor(.yellow)
                        }
                        
                        Text("Musixmatch Lyrics Language")

                        Spacer()
                        
                        TextField("en", text: $lyricsOptions.musixmatchLanguage)
                            .frame(maxWidth: 20)
                            .foregroundColor(.gray)
                    }
                } footer: {
                    Text("You can enter a 2-letter Musixmatch language code and see translated lyrics on Musixmatch if they are available.")
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
        
        .animation(.default, value: lyricsSource)
        .animation(.default, value: showLanguageWarning)
        .animation(.default, value: geniusFallback)
        
        .onChange(of: geniusFallback) { geniusFallback in
            UserDefaults.geniusFallback = geniusFallback
        }
        
        .onChange(of: lyricsOptions) { lyricsOptions in
            
            let selectedLanguage = lyricsOptions.musixmatchLanguage
            
            if selectedLanguage.isEmpty || selectedLanguage ~= "^[\\w\\d]{2}$" {
                showLanguageWarning = false
                
                MusixmatchLyricsRepository.shared.selectedLanguage = selectedLanguage
                UserDefaults.lyricsOptions = lyricsOptions
                
                return
            }
            
            showLanguageWarning = true
        }
    }
}
