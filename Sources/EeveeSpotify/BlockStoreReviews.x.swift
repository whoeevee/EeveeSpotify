import Orion
import UIKit
import StoreKit

// uncomment if you're building for jailbreak, cause ipa crashes:
// Fatal error: Error in tweak EeveeSpotify: Failed to hook method -[SKStoreReviewController requestReview:] (Could not hook method)
// Fatal error: Error in tweak EeveeSpotify: Failed to hook method -[SKStoreReviewController requestReviewInScene:] (Could not hook method)

// class SKStoreReviewControllerHook: ClassHook<SKStoreReviewController> {
//     func requestReview() { }
//     func requestReviewInScene(_ scene: UIWindowScene) { }
// }
