import Orion

class SPTFreeTierArtistHubRemoteURLResolverHook: ClassHook<NSObject> {
    
    static let targetName = "SPTFreeTierArtistHubRemoteURLResolver"
    
    func initWithViewURI(
        _ uri: NSURL,
        onDemandSet: Any,
        onDemandTrialService: Any,
        trackRowsEnabled: Bool,
        productState: SPTCoreProductState
    ) -> Target {
        
        return orig.initWithViewURI(
            uri,
            onDemandSet: onDemandSet,
            onDemandTrialService: onDemandTrialService,
            trackRowsEnabled: UserDefaults.patchType.isPatching
                ? true
                : trackRowsEnabled,
            productState: productState
        )
    }
}
