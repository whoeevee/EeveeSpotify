import Foundation

struct MusixmatchLyricsDataSource {
    
    private let apiUrl = "https://apic.musixmatch.com"

    private func perform(
        _ path: String, 
        query: [String:Any] = [:]
    ) throws -> Data {

        var stringUrl = "\(apiUrl)\(path)"

        var finalQuery = query

        finalQuery["usertoken"] = UserDefaults.musixmatchToken
        finalQuery["app_id"] = "mac-ios-v2.0"

        let queryString = finalQuery.queryString.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        )!

        stringUrl += "?\(queryString)"
        
        let request = URLRequest(url: URL(string: stringUrl)!)

        let semaphore = DispatchSemaphore(value: 0)
        var data: Data?
        var error: Error?

        let task = URLSession.shared.dataTask(with: request) { response, _, err in
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
    
    func getLyrics(_ spotifyTrackId: String) throws -> PlainLyrics {
        
        let data = try perform(
            "/ws/1.1/macro.subtitles.get", 
            query: [
                "track_spotify_id": spotifyTrackId,
                "subtitle_format": "mxm",
                "q_track": " "
            ]
        )

        // 😭😭😭

        guard 
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let message = json["message"] as? [String: Any],
            let body = message["body"] as? [String: Any],
            let macroCalls = body["macro_calls"] as? [String: Any]
        else {
            throw LyricsError.DecodingError
        }

        if let trackSubtitlesGet = macroCalls["track.subtitles.get"] as? [String: Any],
            let subtitlesMessage = trackSubtitlesGet["message"] as? [String: Any],
            let subtitlesBody = subtitlesMessage["body"] as? [String: Any],
            let subtitlesList = subtitlesBody["subtitle_list"] as? [Any],
            let firstSubtitle = subtitlesList.first as? [String: Any],
            let subtitle = firstSubtitle["subtitle"] as? [String: Any],
            let subtitleBody = subtitle["subtitle_body"] as? String {
                return PlainLyrics(content: subtitleBody, timeSynced: true)
        }

        guard 
            let trackLyricsGet = macroCalls["track.lyrics.get"] as? [String: Any],
            let lyricsMessage = trackLyricsGet["message"] as? [String: Any],
            let lyricsBody = lyricsMessage["body"] as? [String: Any],
            let lyrics = lyricsBody["lyrics"] as? [String: Any],
            let plainLyrics = lyrics["lyrics_body"] as? String
        else {
            throw LyricsError.DecodingError
        }

        return PlainLyrics(content: plainLyrics, timeSynced: false)
    }
}
