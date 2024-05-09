import Foundation

struct LyricsRepository {
    
    private static let geniusDataSource = GeniusLyricsDataSource()
    private static let lrclibDataSource = LrcLibLyricsDataSource()
    private static let musixmatchDataSource = MusixmatchLyricsDataSource()

    static func getLyrics(
        title: String, 
        artist: String, 
        spotifyTrackId: String, 
        source: LyricsSource
    ) throws -> PlainLyrics {

        let query = "\(title.strippedTrackTitle) \(artist)"

        switch source {
        
        case .genius:

            let hits = try geniusDataSource.search(query)

            guard let song = (
                hits.first(
                    where: { $0.result.title.containsInsensitive(title) }
                ) ?? hits.first
            )?.result else {
                throw LyricsError.NoSuchSong
            }
            
            let songInfo = try geniusDataSource.getSongInfo(song.id)
            return PlainLyrics(content: songInfo.lyrics.plain, timeSynced: false)

        case .lrclib:

            let hits = try lrclibDataSource.search(query)

            guard let song = (
                hits.first(
                    where: { $0.name.containsInsensitive(title) }
                ) ?? hits.first
            ) else {
                throw LyricsError.NoSuchSong
            }

            return PlainLyrics(
                content: song.syncedLyrics ?? song.plainLyrics,
                timeSynced: song.syncedLyrics != nil
            )
        
        case .musixmatch:
            return try musixmatchDataSource.getLyrics(spotifyTrackId)
        }
    }
}
