import SwiftUI

struct EeveeAboutSettingsView: View {
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("about_main_title".localized)
                    Text("about_main_des".localized)
                }
            }
        }
    }
}
