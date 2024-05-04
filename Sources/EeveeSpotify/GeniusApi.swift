import Foundation

struct GeniusApi {
    
    private static let apiUrl = "https://api.genius.com"
    
    private static func perform(
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
        
        var request = URLRequest(url: URL(string: stringUrl)!)
        request.addValue("6.19.1", forHTTPHeaderField: "X-Genius-iOS-Version")

        let semaphore = DispatchSemaphore(value: 0)
        var data: Data?

        let task = URLSession.shared.dataTask(with: request) { response, _, _ in 
            data = response
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        let rootResponse = try JSONDecoder().decode(GeniusRootResponse.self, from: data!)
        return rootResponse.response
    }
    
    static func search(_ query: String) throws -> [GeniusHit] {
        
        let data = try perform("/search", query: ["q": query])
        
        guard case .hits(let hitsResponse) = data else {
            throw GeniusLyricsError.DecodingError
        }
        
        return hitsResponse.hits
    }

    static func getSongInfo(_ songId: Int) throws -> GeniusSong {
        
        let data = try perform("/songs/\(songId)", query: ["text_format": "plain"])
        
        guard case .song(let songResponse) = data else {
            throw GeniusLyricsError.DecodingError
        }
        
        return songResponse.song
    }

}
