import UIKit

class LyricsHelper {
    
    static func composeLyricsData(_ plain: PlainLyrics, source: LyricsSource) throws -> LyricsData {

        var lyricLines: [LyricsLine] = []
        
        switch source {

        case .genius:

            var lines = plain
                .content
                .components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            
            lines.removeAll { $0 ~= "\\[.*\\]" }

            lines = Array(
                lines
                    .drop(while: { $0.isEmpty })
                    .dropLast(while: { $0.isEmpty })
            )

            lyricLines = lines.map { line in 
                LyricsLine.with { $0.content = line }
            }
        
        case .lrclib:

            let lines = plain
                .content
                .components(separatedBy: "\n")
                .dropLast()

            if plain.timeSynced {

                lyricLines = lines.map { line in
                
                    let match = line.firstMatch(
                        "\\[(?<minute>\\d{2}):(?<seconds>\\d{2}\\.?\\d*)\\] ?(?<content>.*)"
                    )!

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

                    return LyricsLine.with { 
                        $0.offsetMs = Int32(minute * 60 * 1000 + Int(seconds * 1000))
                        $0.content = content.lyricsNoteIfEmpty
                    }
                }

                break
            }

            lyricLines = lines.map { line in 
                LyricsLine.with { $0.content = line }
            }

        case .musixmatch:

            if plain.timeSynced {

                let lines = try JSONDecoder().decode(
                    [MusixmatchSubtitle].self, 
                    from: plain.content.data(using: .utf8)!
                )
                .dropLast()

                lyricLines = lines.map { line in 
                    LyricsLine.with {
                        $0.offsetMs = Int32(Int(line.time.total * 1000))
                        $0.content = line.text.lyricsNoteIfEmpty
                    }
                }

                break
            }

            let lines = plain
                .content
                .components(separatedBy: "\n")
                .dropLast()

            lyricLines = lines.map { line in 
                LyricsLine.with { 
                    $0.content = line.lyricsNoteIfEmpty 
                }
            }
        case .netease:
            
            let lines = plain
                .content
                .components(separatedBy: "\n")
                .dropLast()
            
            
            // 检查是不是真的timeSynced
            var realSynced = true
            if plain.timeSynced {
                let match0 = plain.content.firstMatch(
                    "\\[(?<minute>\\d{2}):(?<seconds>\\d{2}\\.?\\d*).*\\] ?(?<content>.*)"
                )
                if match0 == nil {
                    realSynced = false
                }
            }

            if plain.timeSynced && realSynced {

                var translationDict = [String:String]()
                if UserDefaults.neteaseShowTranslation, let translation = plain.translation {
                    let translateLines = translation
                        .components(separatedBy: "\n")
                        .dropLast()
                    
                    for line in translateLines {
                        let match0 = line.firstMatch(
                            "\\[(?<timestamp>.*)\\] ?(?<content>.*)"
                        )
                        
                        guard let match = match0 else {
                            continue
                        }
                        
                        var captures: [String: String] = [:]
                        
                        for name in ["timestamp", "content"] {

                            let matchRange = match.range(withName: name)

                            if let substringRange = Range(matchRange, in: line) {
                                captures[name] = String(line[substringRange])
                            }
                        }

                        let timestamp = captures["timestamp"]!
                        let content = captures["content"]!
                        
                        translationDict[timestamp] = content
                        
                    }

                }

                var lastOffset: Int32 = -1
                lyricLines = lines.map { line in
                    
                    let match = line.firstMatch(
                        "\\[(?<timestamp>(?<minute>\\d{2}):(?<seconds>\\d{2}\\.?\\d*).*)\\] ?(?<content>.*)"
                    )
                    
                    var captures: [String: String] = [:]
                    
                    for name in ["minute", "seconds", "content", "timestamp"] {
                        
                        let matchRange = match!.range(withName: name)
                        
                        if let substringRange = Range(matchRange, in: line) {
                            captures[name] = String(line[substringRange])
                        }
                    }
                    
                    let minute = Int(captures["minute"]!)!
                    let seconds = Float(captures["seconds"]!)!
                    var content = captures["content"]!
                    let timestamp = captures["timestamp"]!
                    
                    if UserDefaults.neteaseShowTranslation, plain.translation != nil, let translation = translationDict[timestamp] {
                        content = "\(content)\n\(translation)"
                    }
                    
                    // 解决网易云的没排序好的时间戳
                    var offset = Int32(minute * 60 * 1000 + Int(seconds * 1000))
                    if lastOffset >= offset {
                        offset = lastOffset + 1
                    }
                    lastOffset = offset
                    
                    return LyricsLine.with {
                        $0.offsetMs = offset
                        $0.content = content.lyricsNoteIfEmpty
                    }
                }

                break
            }

            lyricLines = lines.map { line in
                LyricsLine.with { $0.content = line }
            }
        }

        return LyricsData.with {
            $0.timeSynchronized = plain.timeSynced
            $0.restriction = .unrestricted
            $0.providedBy = "\(source) (EeveeSpotify)"
            $0.lines = lyricLines
        }
    }
}
