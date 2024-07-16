import Foundation

struct GeniusLyricsRepository: LyricsRepository {
    
    private let jsonDecoder: JSONDecoder
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
        
        jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
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

        guard let rootResponse = try? jsonDecoder.decode(GeniusRootResponse.self, from: data!) else {
            throw LyricsError.DecodingError
        }
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
    
    private func mostRelevantHitResult(
        hits: [GeniusHit],
        strippedTitle: String,
        romanized: Bool,
        hasFoundRomanizedLyrics: inout Bool
    ) -> GeniusHitResult {
        let results = hits.map { $0.result }
        
        let matchingByTitle = results.filter(
            { $0.title.containsInsensitive(strippedTitle) }
        )
        
        if matchingByTitle.isEmpty {
            return results.first!
        }
        
        if romanized, let romanizedSong = matchingByTitle.first(
            where: { $0.artistNames == "Genius Romanizations" }
        ) {
            hasFoundRomanizedLyrics = true
            return romanizedSong
        }
        
        return matchingByTitle.first!
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
    
    func getLyrics(_ query: LyricsSearchQuery, options: LyricsOptions) throws -> LyricsDto {
        let strippedTitle = query.title.strippedTrackTitle
        let hits = try searchSong("\(strippedTitle) \(query.primaryArtist)")
    
        guard !hits.isEmpty else {
            throw LyricsError.NoSuchSong
        }
        
        var hasFoundRomanizedLyrics = false
        
        let song = mostRelevantHitResult(
            hits: hits,
            strippedTitle: strippedTitle,
            romanized: options.romanization,
            hasFoundRomanizedLyrics: &hasFoundRomanizedLyrics
        )
        
        let songInfo = try getSongInfo(song.id)
        let plainLines = songInfo.lyrics.plain.components(separatedBy: "\n")
    
        return LyricsDto(
            lines: mapLyricsLines(plainLines).map { line in LyricsLineDto(content: line) },
            timeSynced: false,
            romanized: hasFoundRomanizedLyrics
        )
    }
}
