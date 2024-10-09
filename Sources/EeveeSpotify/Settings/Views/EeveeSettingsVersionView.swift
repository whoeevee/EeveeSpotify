import SwiftUI

struct EeveeSettingsVersionView: View {
    @State private var latestVersion: String?
    @State private var isPresentingContributorsSheet = false
    
    private func loadVersion() async throws {
        let release = try await GitHubHelper.shared.getLatestRelease()
        latestVersion = String(release.tagName.dropFirst(5)) // swiftX.X
    }
    
    private var isUpdateAvailable: Bool {
        latestVersion != nil && latestVersion != EeveeSpotify.version
    }
    
    var body: some View {
        Section {
            if isUpdateAvailable {
                Link(
                    "update_available".localized,
                    destination: URL(string: "https://github.com/whoeevee/EeveeSpotify/releases")!
                )
            }
        } footer: {
            VStack(alignment: .leading) {
                Text("v\(EeveeSpotify.version)")
                
                if latestVersion == nil {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("checking_for_update".localized)
                    }
                }
                else {
                    Button("\("contributors".localized)...") {
                        isPresentingContributorsSheet = true
                    }
                    .foregroundColor(.gray)
                    .font(.subheadline.weight(.semibold))
                }
            }
        }
        .sheet(isPresented: $isPresentingContributorsSheet) {
            EeveeContributorsSheetView()
        }
        
        .animation(.default, value: latestVersion)
        
        .onAppear {
            Task {
                try await loadVersion()
            }
        }
    }
}
