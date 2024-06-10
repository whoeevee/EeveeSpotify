import UIKit

class URLSessionHelper {
    
    static let shared = URLSessionHelper()
    
    private var requestsMap: [URL:Data]
    
    private init() {
        self.requestsMap = [:]
    }
    
    func setOrAppend(_ data: Data, for url: URL) {
        var loadedData = requestsMap[url] ?? Data()
        loadedData.append(data)
        
        requestsMap[url] = loadedData
    }
    
    func obtainData(for url: URL) -> Data? {
        return requestsMap.removeValue(forKey: url)
    }
}
