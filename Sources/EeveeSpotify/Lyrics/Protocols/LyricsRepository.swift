import Foundation

protocol LyricsRepository {
    func getLyrics(_ query: LyricsSearchQuery) throws -> LyricsDto
}
