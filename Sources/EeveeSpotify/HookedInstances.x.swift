import Orion

class HookedInstances {
    static var productState: SPTCoreProductState?
}

class SPTCoreProductStateInstanceHook: ClassHook<NSObject> {

    static let targetName = "SPTCoreProductState"

    func stringForKey(_ key: String) -> String {

        HookedInstances.productState = Dynamic.convert(
            target,
            to: SPTCoreProductState.self
        )
        return orig.stringForKey(key)
    }
}
