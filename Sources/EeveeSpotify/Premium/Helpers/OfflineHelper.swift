import Foundation

class OfflineHelper {
    static private let applicationSupportDirectory = FileManager.default.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
    )
    .first!
    
    static private let cachesDirectory = FileManager.default.urls(
        for: .cachesDirectory, in: .userDomainMask
    ).first!
    
    //
    
    static private let persistentCachePath = applicationSupportDirectory
        .appendingPathComponent("PersistentCache")
    
    static private let remoteConfigPath = applicationSupportDirectory
        .appendingPathComponent("remote-config")
    
    //
    
    static private func resetPersistentCache() throws {
        try FileManager.default.removeItem(at: self.persistentCachePath)
    }
    
    static private func resetRemoteConfig() throws {
        try FileManager.default.removeItem(at: self.remoteConfigPath)
    }
    
    static private func resetCaches() throws {
        try FileManager.default.removeItem(at: self.cachesDirectory)
    }
    
    //
    
    static func resetData(clearCaches: Bool = false) {
        try? resetPersistentCache()
        try? resetRemoteConfig()
        
        if clearCaches {
            try? resetCaches()
        }
    }
}
