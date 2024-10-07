import SwiftUI

struct EeveeAboutSettingsView: View {
    
    let mainLinks = [
        ("whoeevee", "https://github.com/whoeevee"),
        ("asdfzxcvbn", "https://github.com/asdfzxcvbn")
    ]
    
    let contributors = [
        "ElliotCHEN37", "Richard-NDC", "5jd", "UnexcitingDean", "gototheskinny",
        "LIKVIDATOR1337", "xiangfeidexiaohuo", "wlxxd", "longopy", "yodaluca23",
        "3xynos7", "An0n-00", "by3lish", "emal0n", "CukierDev", "Incognito-Coder",
        "speedyfriend433", "Neo1102", "schweppes-0x", "LivioZ", "lockieluke"
    ]
    
    var body: some View {
        List {
            Section(header: Text("about_main_title".localized)) {
                VStack(alignment: .leading) {
                    ForEach(mainLinks, id: \.0) { name, url in
                        Link(name, destination: URL(string: url)!)
                    }
                }
            }
            
            Section(header: Text("about_sec_title".localized)) {
                VStack(alignment: .leading) {
                    ForEach(contributors, id: \.self) { name in
                        Link(name, destination: URL(string: "https://github.com/whoeevee/EeveeSpotify/graphs/contributors")!)
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text("sort_source".localized)
                }
            }
        }
    }
}
