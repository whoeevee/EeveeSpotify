import Foundation

struct LyricsRepository {
    
    private static let geniusDataSource = GeniusLyricsDataSource()
    private static let lrclibDataSource = LrcLibLyricsDataSource()
    private static let musixmatchDataSource = MusixmatchLyricsDataSource()
    private static let neteaseDataSource = NeteaseDataSource()
    private static let qqMusicDataSource = QQMusicDataSource()

    static func getLyrics(
        title: String, 
        artist: String, 
        spotifyTrackId: String, 
        duration: Int,
        source: LyricsSource
    ) throws -> PlainLyrics {

        let strippedTitle = title.strippedTrackTitle
        let query = "\(strippedTitle) \(artist)"
        switch source {
        
        case .genius:

            let hits = try geniusDataSource.search(query)

            guard let song = (
                hits.first(
                    where: { $0.result.title.containsInsensitive(strippedTitle) }
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
                    where: { $0.name.containsInsensitive(strippedTitle) }
                ) ?? hits.first
            ) else {
                throw LyricsError.NoSuchSong
            }

            return PlainLyrics(
                content: song.syncedLyrics ?? song.plainLyrics ?? "",
                timeSynced: song.syncedLyrics != nil
            )
        
        case .musixmatch:
            return try musixmatchDataSource.getLyrics(spotifyTrackId)
        case .netease:
            // 先用曲名+作者精确搜索,找不到再只用曲名搜索
            let song = try neteaseDataSource.getSong(title: strippedTitle, artistsString: artist, duration: duration)
            
            let lyric = try neteaseDataSource.getLyric(song)
            
            return PlainLyrics(
                content: lyric.lrc.lyric,
                translation: lyric.tlyric?.lyric,
                timeSynced: true
            )
        case .qqmusic:
            let song = try qqMusicDataSource.getSong(title: strippedTitle, artistsString: artist, duration: duration)
            
            let lyric = try qqMusicDataSource.getLyric(song)
            
            return PlainLyrics(
                content: lyric.lyric,
                translation: lyric.trans,
                timeSynced: true
            )
            
        }
    }
}
