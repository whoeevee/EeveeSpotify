import Foundation

class OfflineHelper {
    static private let applicationSupportPath = FileManager.default.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
    )
    .first!
    
    //
    
    static private let persistentCachePath = applicationSupportPath
        .appendingPathComponent("PersistentCache")
    
    static private let remoteConfigPath = applicationSupportPath
        .appendingPathComponent("remote-config")
    
    //
    
    static private func resetPersistentCache() throws {
        try FileManager.default.removeItem(at: self.persistentCachePath)
    }
    
    static private func resetRemoteConfig() throws {
        try FileManager.default.removeItem(at: self.remoteConfigPath)
    }
    
    //
    
    static func resetData() {
        try? resetPersistentCache()
        try? resetRemoteConfig()
    }
}
