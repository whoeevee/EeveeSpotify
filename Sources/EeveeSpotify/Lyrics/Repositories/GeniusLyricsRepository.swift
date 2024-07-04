import Foundation

struct GeniusLyricsRepository: LyricsRepository {
    private let apiUrl = "https://api.genius.com"
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "X-Genius-iOS-Version": "6.21.0",
            "X-Genius-Logged-Out": "true",
            "User-Agent": "Genius/1109 \(URLSessionHelper.CFNetworkVersion) \(URLSessionHelper.DarwinVersion)"
        ]
        
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
    
    //
    
    private func searchSong(_ query: String) throws -> [GeniusHit] {
        let data = try perform("/search/song", query: ["q": query])
        
        guard
            case .sections(let sectionsResponse) = data,
            let section = sectionsResponse.sections.first
        else {
            throw LyricsError.DecodingError
        }
        
        return section.hits
    }

    private func getSongInfo(_ songId: Int) throws -> GeniusSong {
        let data = try perform("/songs/\(songId)", query: ["text_format": "plain"])
        
        guard case .song(let songResponse) = data else {
            throw LyricsError.DecodingError
        }
        
        return songResponse.song
    }
    
    //
    
    private func mostRelevantHitResult(hits: [GeniusHit], strippedTitle: String) -> GeniusHitResult? {
        return (
            hits.first(
                where: { $0.result.title.containsInsensitive(strippedTitle) }
            ) ?? hits.first
        )?.result
    }
    
    private func mapLyricsLines(_ rawLines: [String]) -> [String] {
        var lines = rawLines
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        lines.removeAll { $0 ~= "\\[.*\\]" }

        lines = Array(
            lines
                .drop(while: { $0.isEmpty })
                .dropLast(while: { $0.isEmpty })
        )
        
        return lines
    }
    
    func getLyrics(_ query: LyricsSearchQuery) throws -> LyricsDto {
        let strippedTitle = query.title.strippedTrackTitle
        if UserDefaults.romanizedLyrics {
            let queries = [
                "\(strippedTitle) \(query.primaryArtist) (Romanized)",
                "\(strippedTitle) \(query.primaryArtist)"
            ]
        } else {
            let queries = [
                "\(strippedTitle) \(query.primaryArtist)"
            ]
        }
    
        var hits: [GeniusHit] = []
    
        for searchQuery in queries {
            do {
                hits = try searchSong(searchQuery)
                if !hits.isEmpty {
                    break
                }
            } catch {
                // Continue to the next query if the current one fails
            }
        }
    
        guard !hits.isEmpty,
              let song = mostRelevantHitResult(hits: hits, strippedTitle: strippedTitle) else {
            throw LyricsError.NoSuchSong
        }
    
        let songInfo = try getSongInfo(song.id)
        let plainLines = songInfo.lyrics.plain.components(separatedBy: "\n")
    
        return LyricsDto(
            lines: mapLyricsLines(plainLines).map { line in LyricsLineDto(content: line) },
            timeSynced: false
        )
    }
}
