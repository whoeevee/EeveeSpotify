import Foundation

struct LyricsDto {
    var lines: [LyricsLineDto]
    var timeSynced: Bool
    
    func toLyricsData(source: String) -> LyricsData {
        return LyricsData.with {
            $0.timeSynchronized = timeSynced
            $0.restriction = .unrestricted
            $0.providedBy = "\(source) (EeveeSpotify)"
            $0.lines = lines.map { line in
                LyricsLine.with {
                    $0.content = line.content
                    $0.offsetMs = Int32(line.offsetMs ?? 0)
                }
            }
        }
    }
}
