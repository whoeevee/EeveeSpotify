import Foundation

struct LrcLibLyricsDataSource {
    
    private let apiUrl = "https://lrclib.net/api"
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "User-Agent": "EeveeSpotify v3.0 https://github.com/whoeevee/EeveeSpotify"
        ]
        
        session = URLSession(configuration: configuration)
    }
    
    private func perform(
        _ path: String, 
        query: [String:Any] = [:]
    ) throws -> Data {

        var stringUrl = "\(apiUrl)\(path)"

        if !query.isEmpty {
            let queryString = query.queryString.addingPercentEncoding(
                withAllowedCharacters: .urlHostAllowed
            )!

            stringUrl += "?\(queryString)"
        }
        
        let request = URLRequest(url: URL(string: stringUrl)!)

        let semaphore = DispatchSemaphore(value: 0)
        var data: Data?
        var error: Error?

        let task = session.dataTask(with: request) { response, _, err in
            error = err
            data = response
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        if let error = error {
            throw error
        }

        return data!
    }
    
    func search(_ query: String) throws -> [LrclibSong] {

        let data = try perform("/search", query: ["q": query])
        return try JSONDecoder().decode([LrclibSong].self, from: data)
    }
}
