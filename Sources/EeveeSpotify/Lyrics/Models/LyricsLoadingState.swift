import Foundation

struct LyricsLoadingState {
    var wasRomanized = false
    var areEmpty = false
    var fallbackError: LyricsError? = nil
    var loadedSuccessfully = false
}
