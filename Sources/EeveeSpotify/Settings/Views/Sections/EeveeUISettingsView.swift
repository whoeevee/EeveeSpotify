import SwiftUI
import UIKit

struct EeveeUISettingsView: View {
    @State var lyricsColors = UserDefaults.lyricsColors

    var body: some View {
        List {
            if UserDefaults.lyricsSource.isReplacing {
                Section(
                    header: Text("lyrics_background_color_section".localized),
                    footer: Text("lyrics_background_color_section_description".localized)
                ) {
                    Toggle(
                        "display_original_colors".localized,
                        isOn: $lyricsColors.displayOriginalColors
                    )
                    
                    Toggle(
                        "use_static_color".localized,
                        isOn: $lyricsColors.useStaticColor
                    )
                    
                    if lyricsColors.useStaticColor {
                        ColorPicker(
                            "static_color".localized,
                            selection: Binding<Color>(
                                get: { Color(hex: lyricsColors.staticColor) },
                                set: { lyricsColors.staticColor = $0.hexString }
                            ),
                            supportsOpacity: false
                        )
                    }
                    else {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("color_normalization_factor".localized)
                            
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
            }
            
            Section {
                Toggle(
                    "dark_popups".localized,
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
