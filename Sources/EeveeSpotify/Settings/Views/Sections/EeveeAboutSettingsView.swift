import SwiftUI

struct EeveeAboutSettingsView: View {
    
    var body: some View {
		List {
			Section {
					VStack(alignment: .leading) {
						VStack(alignment: .leading) {
							header: Text("about_main_title".localized),
							Text("about_main_des".localized)
						}
					}
				}
			}
        }
    }
}
