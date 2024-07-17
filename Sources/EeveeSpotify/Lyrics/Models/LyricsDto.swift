import Foundation

struct LyricsDto {
    var lines: [LyricsLineDto]
    var timeSynced: Bool
    var romanized: Bool = false
    var translation: LyricsTranslationDto?
    
    func toLyricsData(source: String) -> LyricsData {
        var lyricsData = LyricsData.with {
            $0.timeSynchronized = timeSynced
            $0.restriction = .unrestricted
            $0.providedBy = "\(source) (EeveeSpotify)"
        }
        
        lyricsData.lines = lines.isEmpty 
            ? [
                LyricsLine.with {
                    $0.content = "This song is instrumental."
                },
                LyricsLine.with {
                    $0.content = "Let the music play..."
                },
                LyricsLine.with {
                    $0.content = ""
                }
            ]
            : lines.map { line in
                LyricsLine.with {
                    $0.content = line.content
                    $0.offsetMs = Int32(line.offsetMs ?? 0)
                }
            }
        
        if let translation = translation {
            lyricsData.translation = LyricsTranslation.with {
                $0.languageCode = translation.languageCode
                $0.lines = translation.lines
            }
        }
        
        return lyricsData
    }
}
