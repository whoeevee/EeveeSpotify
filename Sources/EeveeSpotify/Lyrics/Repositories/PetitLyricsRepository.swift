import Foundation

struct PetitLyricsRepository: LyricsRepository {
    private let url = "https://p1.petitlyrics.com/api/GetPetitLyricsData.php"
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        session = URLSession(configuration: configuration)
    }
    
    private func perform(_ data: [String: Any]) throws -> PetitResponse {
        var finalData = data

        finalData["clientAppId"] = "p1110417"
        finalData["terminalType"] = 10
        
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.httpBody = finalData.queryString.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        )!.data(using: .utf8)

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
        
        guard let response = try? XMLDecoder().decode(PetitResponse.self, from: data!) else {
            throw LyricsError.DecodingError
        }

        return response
    }
    
    //
    
    private func searchSong(_ title: String, artist: String) throws -> PetitSong {
        let response = try perform(
            ["key_title": title, "key_artist": artist, "max_count": 1]
        )
        
        guard let song = response.songs.first else {
            throw LyricsError.NoSuchSong
        }
        
        return song
    }
    
    //
    
    private func getSong(_ lyricsId: Int, availableLyricsType: PetitLyricsType) throws -> PetitSong {
        var lyricsType: PetitLyricsType
        
        if availableLyricsType == .linesSynced {
            lyricsType = .plain
        }
        else {
            lyricsType = availableLyricsType
        }
        
        let response = try perform(
            ["key_lyricsId": lyricsId, "lyricsType": lyricsType.rawValue]
        )
        
        guard let song = response.songs.first else {
            throw LyricsError.NoSuchSong
        }
        
        return song
    }
    
    //
    
    func getLyrics(_ query: LyricsSearchQuery, options: LyricsOptions) throws -> LyricsDto {
        let searchResult = try searchSong(query.title, artist: query.primaryArtist)
        let song = try getSong(
            searchResult.lyricsId,
            availableLyricsType: searchResult.availableLyricsType
        )
        
        guard let lyricsData = Data(base64Encoded: song.lyricsData) else {
            throw LyricsError.DecodingError
        }
        
        switch song.lyricsType {
            
        case .wordsSynced:
            guard let lyrics = try? XMLDecoder().decode(PetitLyricsData.self, from: lyricsData) 
            else {
                throw LyricsError.DecodingError
            }
            
            return LyricsDto(
                lines: lyrics.lines.map {
                    LyricsLineDto(
                        content: $0.linestring,
                        offsetMs: $0.words.first!.starttime
                    )
                },
                timeSynced: true,
                romanization: lyrics.lines.map { $0.linestring }.joined().canBeRomanized 
                    ? .canBeRomanized
                    : .original
            )
            
        case .plain:
            let stringLyrics = String(data: lyricsData, encoding: .utf8)!
            
            return LyricsDto(
                lines: stringLyrics
                    .components(separatedBy: "\n")
                    .map { LyricsLineDto(content: $0) },
                timeSynced: false,
                romanization: stringLyrics.canBeRomanized ? .canBeRomanized : .original
            )
            
        default:
            throw LyricsError.DecodingError
        }
    }
}
