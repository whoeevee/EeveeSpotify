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

        if target.accessibilityIdentifier == "Components.UI.LyricsHeader.ReportButton", 
            UserDefaults.lyricsSource != .musixmatch {
            target.isEnabled = false
        }

        return orig.intrinsicContentSize()
    }
}


class ProfileSettingsSectionHook: ClassHook<NSObject> {

    static let targetName = "ProfileSettingsSection"

    func numberOfRows() -> Int { 
        return 2
    }

    func didSelectRow(_ row: Int) {

        if row == 1 {

            let rootSettingsController = WindowHelper.shared.findFirstViewController(
                "RootSettingsViewController"
            )!

            let eeveeSettingsController = EeveeSettingsViewController()
            eeveeSettingsController.title = "EeveeSpotify"
            
            rootSettingsController.navigationController!.pushViewController(
                eeveeSettingsController, 
                animated: true
            )

            return
        }

        orig.didSelectRow(row)
    }

    func cellForRow(_ row: Int) -> UITableViewCell {
        
        if row == 1 {

            let settingsTableCell = Dynamic.SPTSettingsTableViewCell
                .alloc(interface: SPTSettingsTableViewCell.self)
                .initWithStyle(3, reuseIdentifier: "EeveeSpotify")
            
            let tableViewCell = Dynamic.convert(settingsTableCell, to: UITableViewCell.self)

            tableViewCell.accessoryView = type(
                of: Dynamic.SPTDisclosureAccessoryView
                    .alloc(interface: SPTDisclosureAccessoryView.self)
            )
            .disclosureAccessoryView()
            
            tableViewCell.textLabel?.text = "EeveeSpotify"
            return tableViewCell
        }

        return orig.cellForRow(row)
    }
}

func getCurrentTrackLyricsData() throws -> Data {

    guard let track = HookedInstances.currentTrack else {
        throw LyricsError.NoCurrentTrack
    }

    var source = UserDefaults.lyricsSource

    let plainLyrics: PlainLyrics?

    do {
        plainLyrics = try LyricsRepository.getLyrics(
            title: track.trackTitle(), 
            artist: track.artistTitle(), 
            spotifyTrackId: track.URI().spt_trackIdentifier(),
            source: source
        )
    }

    catch {

        if source != .genius && UserDefaults.geniusFallback {
            
            NSLog("[EeveeSpotify] Unable to load lyrics from \(source), trying Genius as fallback")
            source = .genius

            plainLyrics = try LyricsRepository.getLyrics(
                title: track.trackTitle(), 
                artist: track.artistTitle(), 
                spotifyTrackId: track.URI().spt_trackIdentifier(),
                source: source
            )
        }
        else {
            throw error
        }
    }

    let lyrics = try Lyrics.with {
        $0.colors = LyricsColors.with {
            $0.backgroundColor = Color(hex: track.extractedColorHex()).normalized.uInt32
            $0.lineColor = Color.black.uInt32
            $0.activeLineColor = Color.white.uInt32
        }
        $0.data = try LyricsHelper.composeLyricsData(plainLyrics!, source: source)
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
