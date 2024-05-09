import Foundation

// it's NSURL actually, just with Spotify extensions
@objc protocol SPTURL {
    func spt_trackIdentifier() -> String
}
