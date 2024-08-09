import Orion
import SwiftUI

class SPTPlayerTrackHook: ClassHook<NSObject> {
    static let targetName = "SPTPlayerTrack"

    func metadata() -> [String:String] {
        var meta = orig.metadata()

        meta["has_lyrics"] = "true"
        return meta
    }
}

class LyricsScrollProviderHook: ClassHook<NSObject> {
    
    static var targetName: String {
        return EeveeSpotify.isOldSpotifyVersion
            ? "Lyrics_CoreImpl.ScrollProvider"
            : "Lyrics_NPVCommunicatorImpl.ScrollProvider"
    }
    
    func isEnabledForTrack(_ track: SPTPlayerTrack) -> Bool {
        return true
    }
}

class LyricsFullscreenViewControllerHook: ClassHook<UIViewController> {

    static var targetName: String {
        return EeveeSpotify.isOldSpotifyVersion
            ? "Lyrics_CoreImpl.FullscreenViewController"
            : "Lyrics_FullscreenPageImpl.FullscreenViewController"
    }

    func viewDidLoad() {
        orig.viewDidLoad()
        
        if UserDefaults.lyricsSource == .musixmatch 
            && lastLyricsState.fallbackError == nil
            && !lastLyricsState.wasRomanized
            && !lastLyricsState.areEmpty {
            return
        }
        
        let headerView = Ivars<UIView>(target.view).headerView
        
        if let reportButton = headerView.subviews(matching: "EncoreButton")[1] as? UIButton {
            reportButton.isEnabled = false
        }
    }
}

//

private var preloadedLyrics: Lyrics? = nil
private var lastLyricsState = LyricsLoadingState()

private var hasShownRestrictedPopUp = false
private var hasShownUnauthorizedPopUp = false

//

class LyricsOnlyViewControllerHook: ClassHook<UIViewController> {
    
    static var targetName: String {
        return EeveeSpotify.isOldSpotifyVersion
            ? "Lyrics_CoreImpl.LyricsOnlyViewController"
            : "Lyrics_NPVCommunicatorImpl.LyricsOnlyViewController"
    }

    func viewDidLoad() {
        
        orig.viewDidLoad()
        
        guard
            let lyricsHeaderViewController = target.parent?.children.first
        else {
            return
        }
        
        //
        
        let lyricsLabel = EeveeSpotify.isOldSpotifyVersion 
            ? lyricsHeaderViewController.view.subviews.first?.subviews.first
            : lyricsHeaderViewController.view.subviews.first

        guard let lyricsLabel = lyricsLabel else {
            return
        }
        
        //

        let encoreLabel = Dynamic.convert(lyricsLabel, to: SPTEncoreLabel.self)
        
        var text = [
            encoreLabel.text().firstObject
        ]
        
        let attributes = Dynamic.SPTEncoreAttributes
            .alloc(interface: SPTEncoreAttributes.self)
            .`init`({ attributes in
                attributes.setForegroundColor(.white.withAlphaComponent(0.5))
            })
        
        let typeStyle = type(
            of: Dynamic.SPTEncoreTypeStyle.alloc(interface: SPTEncoreTypeStyle.self)
        ).bodyMediumBold()
        
        //
        
        if UserDefaults.fallbackReasons, let description = lastLyricsState.fallbackError?.description {
            text.append(
                Dynamic.SPTEncoreAttributedString.alloc(interface: SPTEncoreAttributedString.self)
                    .initWithString(
                        "\n\("fallback_attribute".localized): \(description)",
                        typeStyle: typeStyle,
                        attributes: attributes
                    )
            )
        }
        
        if lastLyricsState.wasRomanized {
            text.append(
                Dynamic.SPTEncoreAttributedString.alloc(interface: SPTEncoreAttributedString.self)
                    .initWithString(
                        "\n\("romanized_attribute".localized)",
                        typeStyle: typeStyle,
                        attributes: attributes
                    )
            )
        }
        
        if EeveeSpotify.isOldSpotifyVersion {
            encoreLabel.setNumberOfLines(text.count)
        }

        encoreLabel.setText(text as NSArray)
    }
}

//

private func loadLyricsForCurrentTrack() throws {
    guard let track = HookedInstances.currentTrack else {
        throw LyricsError.NoCurrentTrack
    }
    
    //
    
    let searchQuery = LyricsSearchQuery(
        title: track.trackTitle(),
        primaryArtist: track.artistTitle(),
        spotifyTrackId: track.URI().spt_trackIdentifier()
    )
    
    let options = UserDefaults.lyricsOptions
    var source = UserDefaults.lyricsSource
    
    var repository: LyricsRepository = switch source {
        case .genius: GeniusLyricsRepository()
        case .lrclib: LrcLibLyricsRepository()
        case .musixmatch: MusixmatchLyricsRepository.shared
        case .petit: PetitLyricsRepository()
    }
    
    let lyricsDto: LyricsDto
    
    //
    
    lastLyricsState = LyricsLoadingState()
    
    do {
        lyricsDto = try repository.getLyrics(searchQuery, options: options)
    }
    catch let error {
        if let error = error as? LyricsError {
            lastLyricsState.fallbackError = error
            
            switch error {
                
            case .InvalidMusixmatchToken:
                
                if !hasShownUnauthorizedPopUp {
                    PopUpHelper.showPopUp(
                        delayed: false,
                        message: "musixmatch_unauthorized_popup".localized,
                        buttonText: "OK"
                    )
                    
                    hasShownUnauthorizedPopUp.toggle()
                }
            
            case .MusixmatchRestricted:
                
                if !hasShownRestrictedPopUp {
                    PopUpHelper.showPopUp(
                        delayed: false,
                        message: "musixmatch_restricted_popup".localized,
                        buttonText: "OK"
                    )
                    
                    hasShownRestrictedPopUp.toggle()
                }
                
            default:
                break
            }
        }
        else {
            lastLyricsState.fallbackError = .UnknownError
        }
        
        if source == .genius || !UserDefaults.geniusFallback {
            throw error
        }
        
        NSLog("[EeveeSpotify] Unable to load lyrics from \(source): \(error), trying Genius as fallback")
        
        source = .genius
        repository = GeniusLyricsRepository()
        
        lyricsDto = try repository.getLyrics(searchQuery, options: options)
    }
    
    lastLyricsState.areEmpty = lyricsDto.lines.isEmpty
    
    lastLyricsState.wasRomanized = lyricsDto.romanization == .romanized
    || (lyricsDto.romanization == .canBeRomanized && UserDefaults.lyricsOptions.romanization)
    
    lastLyricsState.loadedSuccessfully = true

    let lyrics = Lyrics.with {
        $0.data = lyricsDto.toLyricsData(source: source.description)
    }
    
    preloadedLyrics = lyrics
}

func getLyricsForCurrentTrack(originalLyrics: Lyrics? = nil) throws -> Data {
    guard let track = HookedInstances.currentTrack else {
        throw LyricsError.NoCurrentTrack
    }
    
    var lyrics = preloadedLyrics
    
    if lyrics == nil {
        try loadLyricsForCurrentTrack()
        lyrics = preloadedLyrics
    }
    
    guard var lyrics = lyrics else {
        throw LyricsError.UnknownError
    }
    
    let lyricsColorsSettings = UserDefaults.lyricsColors
    
    if lyricsColorsSettings.displayOriginalColors, let originalLyrics = originalLyrics {
        lyrics.colors = originalLyrics.colors
    }
    
    lyrics.colors = LyricsColors.with {
        $0.backgroundColor = lyricsColorsSettings.useStaticColor
            ? Color(hex: lyricsColorsSettings.staticColor).uInt32
            : Color(hex: track.extractedColorHex())
                .normalized(lyricsColorsSettings.normalizationFactor)
                .uInt32
        $0.lineColor = Color.black.uInt32
        $0.activeLineColor = Color.white.uInt32
    }
    
    preloadedLyrics = nil
    return try lyrics.serializedData()
}
