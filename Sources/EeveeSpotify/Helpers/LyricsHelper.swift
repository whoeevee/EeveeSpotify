import UIKit
import Foundation

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
                        "\\[(?<minute>\\d{2}):(?<seconds>\\d{2}\\.\\d{2})\\] ?(?<content>.*)"
                    )!

                    var captures: [String: String] = [:]

                    for name in ["minute", "seconds", "content"] {

                        let matchRange = match.range(withName: name)

                        if let substringRange = Range(matchRange, in: line) {
                            let capture = String(line[substringRange])
                            captures[name] = capture
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
        }

        return LyricsData.with {
            $0.timeSynchronized = plain.timeSynced
            $0.restriction = .unrestricted
            $0.providedBy = "\(source) (EeveeSpotify)"
            $0.lines = lyricLines
        }
    }
}
