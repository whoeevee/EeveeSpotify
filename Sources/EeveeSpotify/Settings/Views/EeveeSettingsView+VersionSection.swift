import SwiftUI

extension EeveeSettingsView {
    func loadVersion() async throws {
        let (data, _) = try await URLSession.shared.data(
            from: URL(string: "https://api.github.com/repos/whoeevee/EeveeSpotify/releases/latest")!
        )
        
        let tag = try JSONDecoder().decode(GitHubReleaseInfo.self, from: data).tag_name
        latestVersion = String(tag.dropFirst(5))
    }
    
    private var isUpdateAvailable: Bool {
        guard
            let latest = Double(latestVersion),
            let current = Double(EeveeSpotify.version)
        else {
            return false
        }
        
        return latest > current
    }
    
    @ViewBuilder func VersionSection() -> some View {
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
                
                if latestVersion.isEmpty {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("checking_for_update".localized)
                    }
                }
            }
        }
    }
}
