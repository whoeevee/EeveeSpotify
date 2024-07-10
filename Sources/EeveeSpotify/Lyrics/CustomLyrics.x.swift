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

class LyricsFullscreenViewControllerHook: ClassHook<UIViewController> {

    static var targetName: String {
        if #available(iOS 15.0, *) {
            "Lyrics_FullscreenPageImpl.FullscreenViewController"
        } else {
            "Lyrics_CoreImpl.FullscreenViewController"
        }
    }

    func viewDidLoad() {
        orig.viewDidLoad()
        
        if UserDefaults.lyricsSource == .musixmatch {
            return
        }
        
        let headerView = Ivars<UIView>(target.view).headerView
        
        if let reportButton = headerView.subviews(matching: "EncoreButton")[1] as? UIButton {
            reportButton.isEnabled = false
        }
    }
}

//

private var lastLyricsLanguageLabel: String? = nil
private var lastLyricsError: LyricsError? = nil

private var hasShownRestrictedPopUp = false
private var hasShownUnauthorizedPopUp = false

//

class LyricsOnlyViewControllerHook: ClassHook<UIViewController> {
    
    static var targetName: String {
        if #available(iOS 15.0, *) {
            "Lyrics_NPVCommunicatorImpl.LyricsOnlyViewController"
        } else {
            "Lyrics_CoreImpl.LyricsOnlyViewController"
        }
    }

    func viewDidLoad() {
        
        orig.viewDidLoad()
        
        guard
            let lyricsHeaderViewController = target.parent?.children.first
        else {
            return
        }
        
        //
        
        let lyricsLabel: UIView?
        
        if #available(iOS 15.0, *) {
            lyricsLabel = lyricsHeaderViewController.view.subviews.first
        } else {
            lyricsLabel = lyricsHeaderViewController.view.subviews.first?.subviews.first
        }
        
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
        
        if UserDefaults.fallbackReasons, let description = lastLyricsError?.description {
            text.append(
                Dynamic.SPTEncoreAttributedString.alloc(interface: SPTEncoreAttributedString.self)
                    .initWithString(
                        "\nFallback: \(description)",
                        typeStyle: typeStyle,
                        attributes: attributes
                    )
            )
        }
        
        if let languageLabel = lastLyricsLanguageLabel {
            text.append(
                Dynamic.SPTEncoreAttributedString.alloc(interface: SPTEncoreAttributedString.self)
                    .initWithString(
                        "\n\(languageLabel)",
                        typeStyle: typeStyle,
                        attributes: attributes
                    )
            )
        }
        
        if #unavailable(iOS 15.0) {
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
    }
    
    let lyricsDto: LyricsDto
    
    //
    
    do {
        lyricsDto = try repository.getLyrics(searchQuery, options: options)
        lastLyricsError = nil
    }
    
    catch let error as LyricsError {
        
        lastLyricsError = error
        
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
        
        if source == .genius || !UserDefaults.geniusFallback {
            throw error
        }
        
        NSLog("[EeveeSpotify] Unable to load lyrics from \(source): \(error), trying Genius as fallback")
        
        source = .genius
        repository = GeniusLyricsRepository()
        
        lyricsDto = try repository.getLyrics(searchQuery, options: options)
    }
    
    lastLyricsLanguageLabel = lyricsDto.romanized
        ? "Romanized"
        : Locale.current.localizedString(forLanguageCode: lyricsDto.translatedTo ?? "")

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
