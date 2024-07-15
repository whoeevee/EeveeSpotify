import Foundation

struct PetitLyricsRepository: LyricsRepository {
    private let searchUrl = "https://petitlyrics.com/search_lyrics"
    private let csrfUrl = "https://petitlyrics.com/lib/pl-lib.js"
    private let lyricsUrl = "https://petitlyrics.com/com/get_lyrics.ajax"
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "User-Agent": "EeveeSpotify v\(EeveeSpotify.version) https://github.com/whoeevee/EeveeSpotify"
        ]
        session = URLSession(configuration: configuration)
    }

    private func perform(_ url: String, method: String = "GET", headers: [String: String] = [:], body: [String: String] = [:]) throws -> Data {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers

        if method == "POST" {
            request.httpBody = body.queryString.data(using: .utf8)
        }

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

    private func extractLyricId(from html: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "/lyrics/(\\d+)")
        let range = NSRange(location: 0, length: html.utf16.count)
        if let match = regex.firstMatch(in: html, options: [], range: range) {
            if let range = Range(match.range(at: 1), in: html) {
                return String(html[range])
            }
        }
        return nil
    }

    private func extractCsrfToken(from js: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "X-CSRF-Token',\\s*'([^']+)'")
        let range = NSRange(location: 0, length: js.utf16.count)
        if let match = regex.firstMatch(in: js, options: [], range: range) {
            if let range = Range(match.range(at: 1), in: js) {
                return String(js[range])
            }
        }
        return nil
    }

    func getLyrics(_ query: LyricsSearchQuery, options: LyricsOptions) throws -> LyricsDto {
        let searchData = ["title": query.title, "artist": query.primaryArtist]
        let searchResponse = try perform(searchUrl, method: "POST", headers: ["Content-Type": "application/x-www-form-urlencoded"], body: searchData)
        guard let lyricId = extractLyricId(from: String(data: searchResponse, encoding: .utf8)!) else {
            throw LyricsError.NoSuchSong
        }

        let initialUrl = "https://petitlyrics.com/lyrics/\(lyricId)"
        _ = try perform(initialUrl)

        let csrfResponse = try perform(csrfUrl)
        guard let csrfToken = extractCsrfToken(from: String(data: csrfResponse, encoding: .utf8)!) else {
            throw LyricsError.DecodingError
        }

        let cookies = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == "PLSESSION" })
        guard let plsessionCookie = cookies?.value else {
            throw LyricsError.DecodingError
        }

        let lyricsData = ["lyrics_id": lyricId]
        let lyricsResponse = try perform(lyricsUrl, method: "POST", headers: [
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
            "Cookie": "PLSESSION=\(plsessionCookie)",
            "X-CSRF-Token": csrfToken,
            "X-Requested-With": "XMLHttpRequest"
        ], body: lyricsData)

        let lyricsJson = try JSONSerialization.jsonObject(with: lyricsResponse, options: []) as! [[String: Any]]
        let lyricsLines = lyricsJson.map { item -> LyricsLineDto in
            let decodedLyrics = String(data: Data(base64Encoded: item["lyrics"] as! String)!, encoding: .utf8)!
            return LyricsLineDto(content: decodedLyrics)
        }

        return LyricsDto(lines: lyricsLines, timeSynced: false)
    }
}
