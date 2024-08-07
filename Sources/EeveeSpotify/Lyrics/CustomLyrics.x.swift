import Orion
import SwiftUI

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
                        "\nFallback: \(description)",
                        typeStyle: typeStyle,
                        attributes: attributes
                    )
            )
        }
        
        if lastLyricsState.wasRomanized {
            text.append(
                Dynamic.SPTEncoreAttributedString.alloc(interface: SPTEncoreAttributedString.self)
                    .initWithString(
                        "\nRomanized",
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

func getCurrentTrackLyricsData(originalLyrics: Lyrics? = nil) throws -> Data {
    
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
                        message: "The tweak is unable to load lyrics from Musixmatch due to Unauthorized error. Please check or update your Musixmatch token. If you use an iPad, you should get the token from the Musixmatch app for iPad.",
                        buttonText: "OK"
                    )
                    
                    hasShownUnauthorizedPopUp.toggle()
                }
            
            case .MusixmatchRestricted:
                
                if !hasShownRestrictedPopUp {
                    
                    PopUpHelper.showPopUp(
                        delayed: false,
                        message: "The tweak is unable to load lyrics from Musixmatch because they are restricted. It's likely a copyright issue due to the US IP address, so you should change it if you're in the US or use a VPN.",
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
    
    let lyrics = Lyrics.with {
        $0.colors = getLyricsColors()
        $0.data = lyricsDto.toLyricsData(source: source.description)
    }

    return try lyrics.serializedData()
    
    func getLyricsColors() -> LyricsColors {
        let lyricsColorsSettings = UserDefaults.lyricsColors
        
        if lyricsColorsSettings.displayOriginalColors, let originalLyrics = originalLyrics {
            return originalLyrics.colors
        }
        
        return LyricsColors.with {
            $0.backgroundColor = lyricsColorsSettings.useStaticColor
                ? Color(hex: lyricsColorsSettings.staticColor).uInt32
                : Color(hex: track.extractedColorHex())
                    .normalized(lyricsColorsSettings.normalizationFactor)
                    .uInt32
            $0.lineColor = Color.black.uInt32
            $0.activeLineColor = Color.white.uInt32
        }
    }
}
