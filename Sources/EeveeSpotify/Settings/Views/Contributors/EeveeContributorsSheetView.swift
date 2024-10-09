import SwiftUI

struct EeveeContributorsSheetView: View {
    @State private var users: [GitHubUser] = []
    @State private var sections: [EeveeContributorSection] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if users.isEmpty && sections.isEmpty {
                    ProgressView("Loading".uiKitLocalized)
                }
                else {
                    List {
                        ForEach(sections, id: \.title) { section in
                            Section {
                                ForEach(
                                    section.shuffled
                                        ? section.contributors.shuffled()
                                        : section.contributors,
                                    id: \.username
                                ) { contributor in
                                    if let user = users.first(where: { $0.login == contributor.username }) {
                                        EeveeContributorView(contributor: contributor, githubUser: user)
                                    }
                                }
                            } header: {
                                Text(section.title)
                            }
                        }
                    }
                }
            }
            .navigationTitle("contributors".localized)
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                Button {
                    WindowHelper.shared.dismissCurrentViewController()
                } label: {
                    Text("Done".uiKitLocalized)
                        .font(.headline)
                }
            }
            
            .animation(.default, value: users)
            .animation(.default, value: sections)
            
            .onAppear {
                Task {
                    users = try await GitHubHelper.shared.getContributors()
                    sections = try await GitHubHelper.shared.getEeveeContributorSections()
                }
            }
        }
    }
}
