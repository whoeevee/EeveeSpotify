import Foundation

protocol LyricsRepository {
    func getLyrics(_ query: LyricsSearchQuery, options: LyricsOptions) throws -> LyricsDto
}
