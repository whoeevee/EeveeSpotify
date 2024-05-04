import Orion
import SwiftUI

class SPTPlayerTrackHook: ClassHook<NSObject> {

    static let targetName = "SPTPlayerTrack"

    func setMetadata(_ metadata: [String:String]) {
        var meta = metadata

        meta["has_lyrics"] = "true"
        orig.setMetadata(meta)
    }
}

class EncoreButtonHook: ClassHook<UIButton> {

    static let targetName = "_TtC12EncoreMobileP33_6EF3A3C098E69FB1E331877B69ACBF8512EncoreButton"

    func intrinsicContentSize() -> CGSize {

        if target.accessibilityIdentifier == "Components.UI.LyricsHeader.ReportButton" {
            target.isEnabled = false
        }

        return orig.intrinsicContentSize()
    }
}

func getCurrentTrackLyricsData() throws -> Data {

    let track = HookedInstances.currentTrack!

    let title = track.trackTitle()
        .removeMatches("\\(.*\\)")
        .prefix(30)

    let artist = track.artistTitle()

    let geniusHits = try GeniusApi.search("\(title) \(artist)")

    guard let geniusSong = (
        geniusHits.first(
            where: { $0.result.title.containsInsensitive(title) }
        ) ?? geniusHits.first
    )?.result else {
        throw GeniusLyricsError.NoSuchSong
    }
    
    let geniusSongInfo = try GeniusApi.getSongInfo(geniusSong.id)

    var geniusLyrics = geniusSongInfo.lyrics.plain
        .components(separatedBy: "\n")
        .map { $0.trimmingCharacters(in: .whitespaces) }
    
    geniusLyrics.removeAll { $0.matches("\\[.*\\]") }

    geniusLyrics = Array(
        geniusLyrics
            .drop(while: { $0.isEmpty })
            .dropLast(while: { $0.isEmpty })
    )

    let lyrics = Lyrics.with {
        $0.colors = LyricsColors.with {
            $0.backgroundColor = Color(hex: track.extractedColorHex()).uInt32
            $0.lineColor = Color.black.uInt32
            $0.activeLineColor = Color.white.uInt32
        }
        $0.data = LyricsData.with {
            $0.timeSynchronized = false
            $0.restriction = .unrestricted
            $0.providedBy = "Genius (EeveeSpotify)"
            $0.lines = geniusLyrics.map { line in
                LyricsLine.with { $0.content = line }
            }
        }
    }

    return try lyrics.serializedData()
}

class SPTDataLoaderServiceHook: ClassHook<NSObject> {
    
    static let targetName = "SPTDataLoaderService"

    func URLSession(
        _ session: URLSession, 
        dataTask task: URLSessionDataTask, 
        didReceiveResponse response: HTTPURLResponse, 
        completionHandler handler: Any
    ) {
        let url = response.url!

        if url.isLyrics, response.statusCode != 200 {

            let okResponse = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "2.0",
                headerFields: [:]
            )!

            do {
                
                let lyricsData = try getCurrentTrackLyricsData()

                orig.URLSession(
                    session,
                    dataTask: task,
                    didReceiveResponse: okResponse,
                    completionHandler: handler
                )

                orig.URLSession(
                    session, 
                    dataTask: task, 
                    didReceiveData: lyricsData
                )

                return
            }
            catch {
                NSLog("[EeveeSpotify] Unable to load lyrics: \(error)")
            }
        }

        orig.URLSession(
            session,
            dataTask: task,
            didReceiveResponse: response,
            completionHandler: handler
        )
    }

    func URLSession(
        _ session: URLSession, 
        dataTask task: URLSessionDataTask, 
        didReceiveData data: Data
    ) {
        let request = task.currentRequest!
        let url = request.url!

        if url.isLyrics {

            do {
                orig.URLSession(
                    session, 
                    dataTask: task, 
                    didReceiveData: try getCurrentTrackLyricsData()
                )
                
                return
            }
            catch {
                NSLog("[EeveeSpotify] Unable to load lyrics: \(error)")
            }
        }

        orig.URLSession(session, dataTask: task, didReceiveData: data)
    }
}
