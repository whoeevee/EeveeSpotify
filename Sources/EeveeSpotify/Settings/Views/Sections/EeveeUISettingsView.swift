import SwiftUI
import UIKit

struct EeveeUISettingsView: View {
    
    @State var lyricsColors = UserDefaults.lyricsColors

    var body: some View {
        List {
            Section(
                header: Text("Lyrics Background Color"),
                footer: Text("""
    If you turn on Display Original Colors, the lyrics will appear in the original Spotify colors for tracks that have them.

    You can set a static color or a normalization factor based on the extracted track cover's color. This factor determines how much dark colors are lightened and light colors are darkened. Generally, you will see lighter colors with a higher normalization factor.
    """)) {
                Toggle(
                    "Display Original Colors",
                    isOn: $lyricsColors.displayOriginalColors
                )
                
                Toggle(
                    "Use Static Color",
                    isOn: $lyricsColors.useStaticColor
                )
                
                if lyricsColors.useStaticColor {
                    ColorPicker(
                        "Static Color",
                        selection: Binding<Color>(
                            get: { Color(hex: lyricsColors.staticColor) },
                            set: { lyricsColors.staticColor = $0.hexString }
                        ),
                        supportsOpacity: false
                    )
                }
                else {
                    VStack(alignment: .leading, spacing: 5) {

                        Text("Color Normalization Factor")
                        
                        Slider(
                            value: $lyricsColors.normalizationFactor,
                            in: 0.2...0.8,
                            step: 0.1
                        )
                    }
                }
            }
            
            .onChange(of: lyricsColors) { lyricsColors in
                UserDefaults.lyricsColors = lyricsColors
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
            
            if !UIDevice.current.isIpad {
                Spacer()
                    .frame(height: 40)
                    .listRowBackground(Color.clear)
                    .modifier(ListRowSeparatorHidden())
            }
        }
        .listStyle(GroupedListStyle())
        
        .animation(.default, value: lyricsColors)
    }
}
