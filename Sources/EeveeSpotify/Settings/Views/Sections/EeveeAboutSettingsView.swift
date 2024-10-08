import SwiftUI

struct Contributor: Codable, Identifiable {
    let id: Int
    let login: String
    let contributions: Int
    let html_url: String
}

class GitHubViewModel: ObservableObject {
    @Published var contributors: [Contributor] = []
    
    func fetchContributors() {
        guard let url = URL(string: "https://api.github.com/repos/whoeevee/EeveeSpotify/contributors") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    var fetchedContributors = try JSONDecoder().decode([Contributor].self, from: data)
                    
                    fetchedContributors.removeAll { $0.login == "whoeevee" || $0.login == "asdfzxcvbn" }
                    
                    fetchedContributors.sort { $0.contributions > $1.contributions }
                    
                    DispatchQueue.main.async {
                        self.contributors = fetchedContributors
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            } else if let error = error {
                print("Error fetching contributors: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct EeveeAboutSettingsView: View {
    @ObservedObject var viewModel = GitHubViewModel()
    
    let firstSectionLinks = [
        ("whoeevee", "https://github.com/whoeevee"),
        ("asdfzxcvbn", "https://github.com/asdfzxcvbn")
    ]
    
    var body: some View {
        List {
            Section(header: Text("about_main_title".localized)) {
                ForEach(firstSectionLinks, id: \.0) { link in
                    createLink(title: link.0, url: link.1)
                }
            }
            
            Section(header: Text("about_sec_title".localized), footer: Text("sort_source".localized)) {
                ForEach(viewModel.contributors) { contributor in
                    createLink(title: contributor.login, url: contributor.html_url)
                }
            }
        }
        .onAppear {
            viewModel.fetchContributors()
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
