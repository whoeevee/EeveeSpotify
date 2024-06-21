import Foundation
import UIKit

struct MusixmatchLyricsDataSource {
    
    private let apiUrl = "https://apic.musixmatch.com"

    private func perform(
        _ path: String, 
        query: [String:Any] = [:]
    ) throws -> Data {

        var stringUrl = "\(apiUrl)\(path)"

        var finalQuery = query

        finalQuery["usertoken"] = UserDefaults.musixmatchToken
        finalQuery["app_id"] = UIDevice.current.isIpad
            ? "mac-ios-ipad-v1.0"
            : "mac-ios-v2.0"

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

        if let header = message["header"] as? [String: Any], 
            header["status_code"] as? Int == 401 {
            throw LyricsError.InvalidMusixmatchToken
        }

        if let trackSubtitlesGet = macroCalls["track.subtitles.get"] as? [String: Any],
           let subtitlesMessage = trackSubtitlesGet["message"] as? [String: Any],
           let subtitlesHeader = subtitlesMessage["header"] as? [String: Any],
           let subtitlesStatusCode = subtitlesHeader["status_code"] as? Int {
            
            if subtitlesStatusCode == 404 {
                throw LyricsError.NoSuchSong
            }
            
            if let subtitlesBody = subtitlesMessage["body"] as? [String: Any],
               let subtitleList = subtitlesBody["subtitle_list"] as? [[String: Any]],
               let firstSubtitle = subtitleList.first,
               let subtitle = firstSubtitle["subtitle"] as? [String: Any] {
                
                if let restricted = subtitle["restricted"] as? Bool, restricted {
                    throw LyricsError.MusixmatchRestricted
                }
                
                if let subtitleBody = subtitle["subtitle_body"] as? String {
                    return PlainLyrics(content: subtitleBody, timeSynced: true)
                }
            }
        }

        if let trackLyricsGet = macroCalls["track.lyrics.get"] as? [String: Any],
           let lyricsMessage = trackLyricsGet["message"] as? [String: Any],
           let lyricsHeader = lyricsMessage["header"] as? [String: Any],
           let lyricsStatusCode = lyricsHeader["status_code"] as? Int {
            
            if lyricsStatusCode == 404 {
                throw LyricsError.NoSuchSong
            }
            
            if let lyricsBody = lyricsMessage["body"] as? [String: Any],
               let lyrics = lyricsBody["lyrics"] as? [String: Any],
               let plainLyrics = lyrics["lyrics_body"] as? String {
                
                if let restricted = lyrics["restricted"] as? Bool, restricted {
                    throw LyricsError.MusixmatchRestricted
                }
                
                return PlainLyrics(content: plainLyrics, timeSynced: false)
            }
        }

        throw LyricsError.DecodingError
    }
}
