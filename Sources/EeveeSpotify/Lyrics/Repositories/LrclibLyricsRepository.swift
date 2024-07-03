import Foundation

struct LrcLibLyricsRepository: LyricsRepository {
    private let apiUrl = "https://lrclib.net/api"
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "User-Agent": "EeveeSpotify v\(EeveeSpotify.version) https://github.com/whoeevee/EeveeSpotify"
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
    
    private func searchSong(_ query: String) throws -> [LrclibSong] {
        let data = try perform("/search", query: ["q": query])
        return try JSONDecoder().decode([LrclibSong].self, from: data)
    }
    
    //
    
    private func mostRelevantSong(songs: [LrclibSong], strippedTitle: String) -> LrclibSong? {
        return songs.first(
           where: { $0.name.containsInsensitive(strippedTitle) }
       ) ?? songs.first
    }
    
    private func mapSyncedLyricsLines(_ lines: [String]) -> [LyricsLineDto] {
        return lines.compactMap { line in
            guard let match = line.firstMatch(
                "\\[(?<minute>\\d*):(?<seconds>\\d*\\.?\\d*)\\] ?(?<content>.*)"
            ) else {
                return nil
            }
            
            var captures: [String: String] = [:]
            
            for name in ["minute", "seconds", "content"] {
                
                let matchRange = match.range(withName: name)
                
                if let substringRange = Range(matchRange, in: line) {
                    captures[name] = String(line[substringRange])
                }
            }
            
            let minute = Int(captures["minute"]!)!
            let seconds = Float(captures["seconds"]!)!
            let content = captures["content"]!
            
            return LyricsLineDto(
                content: content.lyricsNoteIfEmpty,
                offsetMs: Int(minute * 60 * 1000 + Int(seconds * 1000))
            )
        }
    }

    func getLyrics(_ query: LyricsSearchQuery) throws -> LyricsDto {
        let strippedTitle = query.title.strippedTrackTitle
        let songs = try searchSong("\(strippedTitle) \(query.primaryArtist)")
        
        guard let song = mostRelevantSong(songs: songs, strippedTitle: strippedTitle) else {
            throw LyricsError.NoSuchSong
        }
        
        if let syncedLyrics = song.syncedLyrics {
            return LyricsDto(
                lines: mapSyncedLyricsLines(
                    syncedLyrics.components(separatedBy: "\n").dropLast()
                ),
                timeSynced: true
            )
        }
        
        guard let plainLyrics = song.plainLyrics else {
            throw LyricsError.DecodingError
        }
        
        return LyricsDto(
            lines: plainLyrics
                .components(separatedBy: "\n")
                .dropLast()
                .map { content in LyricsLineDto(content: content) },
            timeSynced: false
        )
    }
}
