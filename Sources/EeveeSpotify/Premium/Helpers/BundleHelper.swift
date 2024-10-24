import Foundation
import SwiftUI
import libroot

class BundleHelper {
    private let bundleName = "EeveeSpotify"
    
    private let bundle: Bundle
    private let enBundle: Bundle
    
    static let shared = BundleHelper()
    
    private init() {
        self.bundle = Bundle(
            path: Bundle.main.path(
                forResource: bundleName,
                ofType: "bundle"
            )
            ?? jbRootPath("/Library/Application Support/\(bundleName).bundle")
        )!
        
        enBundle = Bundle(path: bundle.path(forResource: "en", ofType: "lproj")!)!
    }
    
    func uiImage(_ name: String) -> UIImage {
        return UIImage(
            contentsOfFile: self.bundle.path(
                forResource: name,
                ofType: "png"
            )!
        )!
    }
    
    func localizedString(_ key: String) -> String {
        let value = bundle.localizedString(forKey: key, value: "No translation", table: nil)
        
        if value != "No translation" {
            return value
        }
        
        return enBundle.localizedString(forKey: key, value: nil, table: nil)
    }
    
    func resolveConfiguration() throws -> ResolveConfiguration {
        return try ResolveConfiguration(
            serializedBytes: try Data(
                contentsOf: self.bundle.url(
                    forResource: "resolveconfiguration",
                    withExtension: "bnk"
                )!
            )
        )
    }
}
