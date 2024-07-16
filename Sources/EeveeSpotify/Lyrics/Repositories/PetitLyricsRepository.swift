import Foundation

class XMLDictionaryParser: NSObject, XMLParserDelegate {
    private var dictionaryStack: [[String: Any]] = []
    private var textInProgress: String = ""
    
    func parse(data: Data) -> [String: Any]? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        guard parser.parse() else {
            NSLog("[EeveeSpotify] Failed to parse XML")
            return nil
        }
        return dictionaryStack.first
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        var dict: [String: Any] = [:]
        for (key, value) in attributeDict {
            if let intValue = Int(value) {
                dict[key] = intValue
            } else {
                dict[key] = value
            }
        }
        dictionaryStack.append(dict)
        textInProgress = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        textInProgress += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        var dict = dictionaryStack.popLast()!
        if !textInProgress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if let intValue = Int(textInProgress.trimmingCharacters(in: .whitespacesAndNewlines)) {
                dict[elementName] = intValue
            } else {
                dict[elementName] = textInProgress.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        if var top = dictionaryStack.last {
            if let existingValue = top[elementName] {
                if var array = existingValue as? [[String: Any]] {
                    array.append(dict)
                    top[elementName] = array
                } else {
                    top[elementName] = [existingValue, dict]
                }
            } else if dict.count == 1, let key = dict.keys.first, let value = dict[key] {
                top[elementName] = value
            } else {
                top[elementName] = dict
            }
            dictionaryStack[dictionaryStack.count - 1] = top
        } else {
            dictionaryStack.append(dict)
        }
        textInProgress = ""
        NSLog("[EeveeSpotify] End Element: \(elementName), dictionary: \(dict)")
    }
}

struct PetitLyricsRepository: LyricsRepository {
    private let apiUrl = "https://p1.petitlyrics.com/api/GetPetitLyricsData.php"
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent": "EeveeSpotify v\(EeveeSpotify.version) https://github.com/whoeevee/EeveeSpotify"
        ]
        
        session = URLSession(configuration: configuration)
    }
    
    private func perform(
        _ query: [String: Any]
    ) throws -> Data {
        NSLog("[EeveeSpotify] Perform Func")
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "POST"
        
        let queryString = query.queryString
        request.httpBody = queryString.data(using: .utf8)
        
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
    
    private func decodeBase64(_ base64String: String) throws -> Data {
        NSLog("[EeveeSpotify] Decoding Base64")
        guard let data = Data(base64Encoded: base64String) else {
            throw LyricsError.DecodingError
        }
        return data
    }
    
    private func mapTimeSyncedLyrics(_ xmlData: Data) throws -> [LyricsLineDto] {
        NSLog("[EeveeSpotify] Mapping Time synced (wsy)")
        guard let parsedDictionary = XMLDictionaryParser().parse(data: xmlData),
              let lines = parsedDictionary["line"] as? [[String: Any]] else {
            throw LyricsError.DecodingError
        }
        
        var lyricsLines: [LyricsLineDto] = []
        NSLog("[EeveeSpotify] Mapping Time synced (Lines)")
        for line in lines {
            guard let lineString = line["linestring"] as? String,
                  let words = line["word"] as? [[String: Any]],
                  let firstWord = words.first,
                  let startTimeInt = firstWord["starttime"] as? Int else {
                  continue // Skip lines that don't have necessary data
            }
            
            let lyricsLineDto = LyricsLineDto(content: lineString, offsetMs: startTimeInt)
            lyricsLines.append(lyricsLineDto)
        }
        
        return lyricsLines
    }
    
    func getLyrics(_ query: LyricsSearchQuery, options: LyricsOptions) throws -> LyricsDto {
        NSLog("[EeveeSpotify] getLyrics")
        var petitLyricsQuery = [
            "maxCount": "1",
            "key_title": query.title,
            "key_artist": query.primaryArtist,
            "terminalType": "10",
            "clientAppId": "p1232089",
            "lyricsType": "3"
        ]
        
        let response = try perform(petitLyricsQuery)
        let parser = XMLDictionaryParser()
        let parsedDictionary = parser.parse(data: response)
        
        guard let parsedDict = parsedDictionary,
              let songs = parsedDict["songs"] as? [String: Any],
              let song = songs["song"] as? [String: Any] else {
            throw LyricsError.NoSuchSong
        }

        
        guard let lyricsDataBase64 = song["lyricsData"] as? String,
              let lyricsType = song["lyricsType"] as? Int else {
            throw LyricsError.DecodingError
        }
        

        let lyricsData = try decodeBase64(lyricsDataBase64)
        
        if lyricsType == 2 {
            petitLyricsQuery["lyricsType"] = "1"
            let responsetype1 = try perform(petitLyricsQuery)
            let parser = XMLDictionaryParser()
            guard let parsedDictionary1 = parser.parse(data: responsetype1) else {
                throw LyricsError.DecodingError
            }
            
            guard let songs = parsedDictionary1["songs"] as? [String: Any],
                  let song = songs["song"] as? [String: Any],
                  let lyricsDataBase64 = song["lyricsData"] as? String else {
                throw LyricsError.DecodingError
            }
            
            let lyricsData = try decodeBase64(lyricsDataBase64)
            let lines = String(data: lyricsData, encoding: .utf8)?
                .components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { LyricsLineDto(content: $0) } ?? []
            return LyricsDto(lines: lines, timeSynced: false)
        }
        
        if lyricsType == 1 {
            let lines = String(data: lyricsData, encoding: .utf8)?
                .components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { LyricsLineDto(content: $0) } ?? []
            return LyricsDto(lines: lines, timeSynced: false)

        }
        
        if lyricsType == 3 {
            let lines = try mapTimeSyncedLyrics(lyricsData)
            return LyricsDto(lines: lines, timeSynced: true)
        }
        
        throw LyricsError.DecodingError
    }
}
