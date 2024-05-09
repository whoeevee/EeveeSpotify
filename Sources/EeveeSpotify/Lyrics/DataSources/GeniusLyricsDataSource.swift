import Foundation

struct GeniusLyricsDataSource {
    
    private let apiUrl = "https://api.genius.com"
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["X-Genius-iOS-Version": "6.19.1"]
        
        session = URLSession(configuration: configuration)
    }
    
    private func perform(
        _ path: String, 
        query: [String:Any] = [:]
    ) throws -> GeniusDataResponse? {

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

        let rootResponse = try JSONDecoder().decode(GeniusRootResponse.self, from: data!)
        return rootResponse.response
    }
    
    func search(_ query: String) throws -> [GeniusHit] {
        
        let data = try perform("/search", query: ["q": query])
        
        guard case .hits(let hitsResponse) = data else {
            throw LyricsError.DecodingError
        }
        
        return hitsResponse.hits
    }

    func getSongInfo(_ songId: Int) throws -> GeniusSong {
        
        let data = try perform("/songs/\(songId)", query: ["text_format": "plain"])
        
        guard case .song(let songResponse) = data else {
            throw LyricsError.DecodingError
        }
        
        return songResponse.song
    }
}
