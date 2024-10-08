import SwiftUI

struct EeveeAboutSettingsView: View {
    let firstSectionLinks = [
        ("whoeevee", "https://github.com/whoeevee"),
        ("asdfzxcvbn", "https://github.com/asdfzxcvbn")
    ]
    
    let secondSectionLinks = [
        ("ElliotCHEN37", "https://github.com/ElliotCHEN37"),
        ("Richard-NDC", "https://github.com/Richard-NDC"),
        ("5jd", "https://github.com/5jd"),
        ("UnexcitingDean", "https://github.com/UnexcitingDean"),
        ("gototheskinny", "https://github.com/gototheskinny"),
        ("LIKVIDATOR1337", "https://github.com/LIKVIDATOR1337"),
        ("xiangfeidexiaohuo", "https://github.com/xiangfeidexiaohuo"),
        ("wlxxd", "https://github.com/wlxxd"),
        ("longopy", "https://github.com/longopy"),
        ("yodaluca23", "https://github.com/yodaluca23"),
        ("3xynos7", "https://github.com/3xynos7"),
        ("An0n-00", "https://github.com/An0n-00"),
        ("by3lish", "https://github.com/by3lish"),
        ("emal0n", "https://github.com/emal0n"),
        ("CukierDev", "https://github.com/CukierDev"),
        ("Incognito-Coder", "https://github.com/Incognito-Coder"),
        ("speedyfriend433", "https://github.com/speedyfriend433"),
        ("Neo1102", "https://github.com/Neo1102"),
        ("schweppes-0x", "https://github.com/schweppes-0x"),
        ("LivioZ", "https://github.com/LivioZ"),
        ("lockieluke", "https://github.com/lockieluke")
    ]
    
    var body: some View {
        List {
            Section(header: Text("about_main_title".localized), alignment: .leading) {
                ForEach(firstSectionLinks, id: \.0) { link in
                    createLink(title: link.0, url: link.1)
                }
            }
            
            Section(header: Text("about_sec_title".localized), footer: Text("sort_source".localized), alignment: .leading) {
                ForEach(secondSectionLinks, id: \.0) { link in
                    createLink(title: link.0, url: link.1)
                }
            }
        }
    }
    
    private func createLink(title: String, url: String) -> some View {
        HStack {
            Link(title, destination: URL(string: url)!)
            Spacer()
            Image(systemName: "arrow.up.right.square")
        }
    }
}
