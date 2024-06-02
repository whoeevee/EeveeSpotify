import Foundation
import Orion

class SPTDataLoaderServiceHook: ClassHook<NSObject> {
    
    static let targetName = "SPTDataLoaderService"
    
    func URLSession(
        _ session: URLSession,
        task: URLSessionDataTask,
        didCompleteWithError error: Error?
    ) {
        if let url = task.currentRequest?.url {
            if url.isLyrics || (UserDefaults.patchType == .requests && url.isCustomize) {
                return
            }
        }
        orig.URLSession(session, task: task, didCompleteWithError: error)
    }

    func URLSession(
        _ session: URLSession,
        dataTask task: URLSessionDataTask,
        didReceiveResponse response: HTTPURLResponse,
        completionHandler handler: Any
    ) {
        let url = response.url!

        if url.isLyrics, response.statusCode != 200 {

            let okResponse = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "2.0",
                headerFields: [:]
            )!

            do {
                let lyricsData = try getCurrentTrackLyricsData()

                orig.URLSession(
                    session,
                    dataTask: task,
                    didReceiveResponse: okResponse,
                    completionHandler: handler
                )

                orig.URLSession(session, dataTask: task, didReceiveData: lyricsData)
                orig.URLSession(session, task: task, didCompleteWithError: nil)

                return
            }
            catch {
                NSLog("[EeveeSpotify] Unable to load lyrics: \(error)")
                orig.URLSession(session, task: task, didCompleteWithError: error)
                
                return
            }
        }

        orig.URLSession(
            session,
            dataTask: task,
            didReceiveResponse: response,
            completionHandler: handler
        )
    }

    func URLSession(
        _ session: URLSession,
        dataTask task: URLSessionDataTask,
        didReceiveData data: Data
    ) {
        guard
            let request = task.currentRequest,
            let response = task.response,
            let url = request.url
        else {
            return
        }

        if url.isLyrics {

            do {
                orig.URLSession(
                    session,
                    dataTask: task,
                    didReceiveData: try getCurrentTrackLyricsData(
                        originalLyrics: try? Lyrics(serializedData: data)
                    )
                )
                
                orig.URLSession(session, task: task, didCompleteWithError: nil)
                return
            }
            catch {
                NSLog("[EeveeSpotify] Unable to load lyrics: \(error)")
                orig.URLSession(session, task: task, didCompleteWithError: error)
                
                return
            }
        }
        
        if url.isCustomize && UserDefaults.patchType == .requests {
            
            do {
                guard let buffer = OfflineHelper.appendDataAndReturnIfFull(
                    data,
                    response: response
                ) else {
                    return
                }

                OfflineHelper.dataBuffer = Data()
                
                var customizeMessage = try CustomizeMessage(serializedData: buffer)
                modifyRemoteConfiguration(&customizeMessage.response)
                
                orig.URLSession(
                    session,
                    dataTask: task,
                    didReceiveData: try customizeMessage.serializedData()
                )
                
                orig.URLSession(session, task: task, didCompleteWithError: nil)

                NSLog("[EeveeSpotify] Modified customize data")
                return
            }
            catch {
                NSLog("[EeveeSpotify] Unable to modify customize data: \(error)")
            }
        }

        orig.URLSession(session, dataTask: task, didReceiveData: data)
    }
}
