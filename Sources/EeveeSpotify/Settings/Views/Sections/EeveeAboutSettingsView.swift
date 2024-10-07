import SwiftUI

struct EeveeAboutSettingsView: View {
    
    var body: some View {
        List {
            Section(header: Text("about_main_title".localized)) {
                VStack(alignment: .leading) {
                    Link("whoeevee", destination: URL(string: "https://github.com/whoeevee")!)
					Link("asdfzxcvbn", destination: URL(string: "https://github.com/asdfzxcvbn")!)
                }
            }
			Section(header: Text("about_sec_title".localized)) {
                VStack(alignment: .leading) {
                    Link("ElliotCHEN37", destination: URL(string: "https://github.com/ElliotCHEN37")!)
					Link("Richard-NDC", destination: URL(string: "https://github.com/Richard-NDC")!)
					Link("5jd", destination: URL(string: "https://github.com/5jd")!)
					Link("UnexcitingDean", destination: URL(string: "https://github.com/UnexcitingDean")!)
					Link("gototheskinny", destination: URL(string: "https://github.com/gototheskinny")!)
					Link("LIKVIDATOR1337", destination: URL(string: "https://github.com/LIKVIDATOR1337")!)
					Link("xiangfeidexiaohuo", destination: URL(string: "https://github.com/xiangfeidexiaohuo")!)
					Link("wlxxd", destination: URL(string: "https://github.com/wlxxd")!)
					Link("longopy", destination: URL(string: "https://github.com/longopy")!)
					Link("yodaluca23", destination: URL(string: "https://github.com/yodaluca23")!)
					Link("3xynos7", destination: URL(string: "https://github.com/3xynos7")!)
					Link("An0n-00", destination: URL(string: "https://github.com/An0n-00")!)
					Link("by3lish", destination: URL(string: "https://github.com/by3lish")!)
					Link("emal0n", destination: URL(string: "https://github.com/emal0n")!)
					Link("CukierDev", destination: URL(string: "https://github.com/CukierDev")!)
					Link("Incognito-Coder", destination: URL(string: "https://github.com/Incognito-Coder")!)
					Link("speedyfriend433", destination: URL(string: "https://github.com/speedyfriend433")!)
					Link("Neo1102", destination: URL(string: "https://github.com/Neo1102")!)
					Link("schweppes-0x", destination: URL(string: "https://github.com/schweppes-0x")!)
					Link("LivioZ", destination: URL(string: "https://github.com/LivioZ")!)
					Link("lockieluke", destination: URL(string: "https://github.com/lockieluke")!)
                }
            }
			Section{
				VStack(alignment: .leading) {
				Link("sort_source".localized, destination: URL(string: "https://github.com/whoeevee/EeveeSpotify/graphs/contributors")!)
				}
			}
        }
    }
}
