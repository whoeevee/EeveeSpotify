import Foundation
import UIKit

class MusixmatchLyricsRepository: LyricsRepository {
    
    private let apiUrl = "https://apic.musixmatch.com"
    
    var selectedLanguage: String
    
    static let shared = MusixmatchLyricsRepository(
        language: UserDefaults.lyricsOptions.musixmatchLanguage
    )
    
    private init(language: String) {
        selectedLanguage = language
    }

    private func perform(
        _ path: String,
        query: [String: Any] = [:]
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
    
    //
    
    private func getMacroCalls(_ data: Data) throws -> [String: Any] {
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
        
        return macroCalls
    }
    
    private func getFirstSubtitle(_ subtitlesMessage: [String: Any]) throws -> [String: Any] {
        guard
            let subtitlesHeader = subtitlesMessage["header"] as? [String: Any],
            let subtitlesStatusCode = subtitlesHeader["status_code"] as? Int
        else {
            throw LyricsError.DecodingError
        }
        
        guard 
            let subtitlesBody = subtitlesMessage["body"] as? [String: Any],
            let subtitleList = subtitlesBody["subtitle_list"] as? [[String: Any]],
            let firstSubtitle = subtitleList.first,
            let subtitle = firstSubtitle["subtitle"] as? [String: Any]
        else {
            throw LyricsError.DecodingError
        }
            
        if let restricted = subtitle["restricted"] as? Bool, restricted {
            throw LyricsError.MusixmatchRestricted
        }
        
        return subtitle
    }
    
    //
    
    private func getTranslations(_ spotifyTrackId: String, selectedLanguage: String) throws -> [String: String] {
        let data = try perform(
            "/ws/1.1/crowd.track.translations.get",
            query: [
                "track_spotify_id": spotifyTrackId,
                "selected_language": selectedLanguage
            ]
        )
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let message = json["message"] as? [String: Any],
            let body = message["body"] as? [String: Any],
            let translationsList = body["translations_list"] as? [[String: Any]]
        else {
            throw LyricsError.DecodingError
        }

        let translations = translationsList.map {
            $0["translation"] as! [String: Any]
        }
        
        return Dictionary(uniqueKeysWithValues: translations.map {
            ($0["subtitle_matched_line"] as! String, $0["description"] as! String)
        })
    }
    
    //
    
    func getLyrics(_ query: LyricsSearchQuery, options: LyricsOptions) throws -> LyricsDto {
        
        var musixmatchQuery = [
            "track_spotify_id": query.spotifyTrackId,
            "subtitle_format": "mxm",
            "q_track": " "
        ]
        
        if !selectedLanguage.isEmpty {
            musixmatchQuery["selected_language"] = selectedLanguage
            musixmatchQuery["part"] = "subtitle_translated"
        }
        
        let data = try perform(
            "/ws/1.1/macro.subtitles.get",
            query: musixmatchQuery
        )

        // 😭😭😭

        var romanized = false
        var translation: LyricsTranslationDto? = nil
        
        let macroCalls = try getMacroCalls(data)

        if let trackSubtitlesGet = macroCalls["track.subtitles.get"] as? [String: Any],
            let subtitlesMessage = trackSubtitlesGet["message"] as? [String: Any],
            let subtitle = try? getFirstSubtitle(subtitlesMessage),
            let subtitleLanguage = subtitle["subtitle_language"] as? String,
            let subtitleBody = subtitle["subtitle_body"] as? String,
            let subtitles = try? JSONDecoder().decode(
                [MusixmatchSubtitle].self, from: subtitleBody.data(using: .utf8)!
            ) {
            
            let romanizationLanguage = "r\(subtitleLanguage.prefix(1))"
            
            var lyricsLines = subtitles.dropLast().map { subtitle in
                LyricsLineDto(
                    content: subtitle.text.lyricsNoteIfEmpty,
                    offsetMs: Int(subtitle.time.total * 1000)
                )
            }
            
            lyricsLines.append(
                LyricsLineDto(
                    content: "",
                    offsetMs: Int(subtitles.last!.time.total * 1000)
                )
            )
            
            if let subtitleTranslated = subtitle["subtitle_translated"] as? [String: Any],
               let subtitleTranslatedBody = subtitleTranslated["subtitle_body"] as? String,
               let subtitlesTranslated = try? JSONDecoder().decode(
                    [MusixmatchSubtitle].self, from: subtitleTranslatedBody.data(using: .utf8)!
               ) {
                
                if selectedLanguage == romanizationLanguage {
                    romanized = true
                    
                    for (index, subtitleTranslated) in subtitlesTranslated.enumerated() {
                        if !subtitleTranslated.text.isEmpty {
                            lyricsLines[index].content = subtitleTranslated.text
                        }
                    }
                }
                else {
                    translation = LyricsTranslationDto(
                        languageCode: selectedLanguage,
                        lines: subtitlesTranslated.map { $0.text }
                    )
                }
            }
            
            if options.musixmatchLanguage.isEmpty
                && options.romanization
                && selectedLanguage != romanizationLanguage {
                
                selectedLanguage = romanizationLanguage
                
                if let translations = try? getTranslations(
                    query.spotifyTrackId,
                    selectedLanguage: romanizationLanguage
                ) {
                    romanized = true
                    
                    for (original, translation) in translations {
                        for i in 0..<lyricsLines.count {
                            if lyricsLines[i].content == original {
                                lyricsLines[i].content = translation
                            }
                        }
                    }
                }
            }
            
            return LyricsDto(
                lines: lyricsLines,
                timeSynced: true,
                romanized: romanized,
                translation: translation
            )
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
                
                return LyricsDto(
                    lines: plainLyrics
                        .components(separatedBy: "\n")
                        .dropLast()
                        .map { LyricsLineDto(content: $0.lyricsNoteIfEmpty) },
                    timeSynced: false
                )
            }
        }

        throw LyricsError.DecodingError
    }
}
