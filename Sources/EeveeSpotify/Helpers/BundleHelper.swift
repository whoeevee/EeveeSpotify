import Foundation
import libroot

class BundleHelper {

    private let bundleName = "EeveeSpotify"

    private let bundle: Bundle
    static let shared = BundleHelper()

    private init() { 
        self.bundle = Bundle(
            path: Bundle.main.path(
                forResource: bundleName, 
                ofType: "bundle"
            ) 
            ?? jbRootPath("/Library/Application Support/\(bundleName).bundle")
        )!
    }

    func premiumBlankData() throws -> Data {
        return try Data(
            contentsOf: self.bundle.url(
                forResource: "premiumblank", 
                withExtension: "bnk"
            )!
        )
    }
}
