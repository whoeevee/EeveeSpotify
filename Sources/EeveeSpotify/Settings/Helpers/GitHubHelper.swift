import Foundation

struct GitHubHelper {
    private let apiUrl = "https://api.github.com"
    private let decoder = JSONDecoder()
    
    static let shared = GitHubHelper()
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    private func perform(_ path: String) async throws -> Data {
        let url = URL(string: "\(apiUrl)\(path)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return data
    }
    
    func getLatestRelease() async throws -> GitHubRelease {
        let data = try await perform("/repos/whoeevee/EeveeSpotify/releases/latest")
        return try decoder.decode(GitHubRelease.self, from: data)
    }
    
    func getUser(_ username: String) async throws -> GitHubUser {
        let data = try await perform("/users/\(username)")
        return try decoder.decode(GitHubUser.self, from: data)
    }
    
    func getContributors() async throws -> [GitHubUser] {
        let data = try await perform("/repos/whoeevee/EeveeSpotify/contributors")
        return try decoder.decode([GitHubUser].self, from: data)
    }
    
    func getEeveeContributorSections() async throws -> [EeveeContributorSection] {
        let (data, _) = try await URLSession.shared.data(
            from: URL(
                string: "https://raw.githubusercontent.com/whoeevee/EeveeSpotify/swift/contributors.json"
            )!
        )
        return try decoder.decode([EeveeContributorSection].self, from: data)
    }
}
