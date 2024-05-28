import Foundation

class OfflineHelper {

    static let persistentCachePath = FileManager.default.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
    )
    .first!
    .appendingPathComponent("PersistentCache")

    //

    static var offlineBnkPath: URL {
        persistentCachePath.appendingPathComponent("offline.bnk")
    }

    static var eeveeBnkPath: URL {
        persistentCachePath.appendingPathComponent("eevee.bnk")
    }

    static var offlineBnkData: Data {
        get throws { try Data(contentsOf: offlineBnkPath) }
    }

    static var eeveeBnkData: Data {
        get throws { try Data(contentsOf: eeveeBnkPath) }
    }

    //
    
    static var dataBuffer = Data()
    
    static func appendDataAndReturnIfFull(_ data: Data, response: URLResponse) -> Data? {
        
        dataBuffer.append(data)
        
        if dataBuffer.count == response.expectedContentLength {
            return dataBuffer
        }
        
        return nil
    }
    
    //

    private static func writeOfflineBnkData(_ data: Data) throws {
        try data.write(to: offlineBnkPath)
    }

    private static func writeEeveeBnkData(_ data: Data) throws {
        try data.write(to: eeveeBnkPath)
    }

    //

    static func restoreFromEeveeBnk() throws {
        try writeOfflineBnkData(try eeveeBnkData)
    }

    static func backupToEeveeBnk() throws {
        try writeEeveeBnkData(try offlineBnkData)
    }

    static func patchOfflineBnk() throws {

        let fileData = try offlineBnkData

        let usernameLength = Int(fileData[8])
        let username = Data(fileData[9..<9 + usernameLength])

        var blankData = try BundleHelper.shared.premiumBlankData()

        blankData.insert(UInt8(usernameLength), at: 8)
        blankData.insert(contentsOf: username, at: 9)

        try writeOfflineBnkData(blankData)
    }
    
    //
    
    static func resetPersistentCache() throws {
        try FileManager.default.removeItem(at: self.persistentCachePath)
    }
    
    static func resetOfflineBnk() throws {
        try FileManager.default.removeItem(at: self.offlineBnkPath)
    }
}
