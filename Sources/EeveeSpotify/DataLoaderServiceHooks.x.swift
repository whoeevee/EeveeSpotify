import Foundation
import Orion

class SPTDataLoaderServiceHook: ClassHook<NSObject>, SpotifySessionDelegate {
    static let targetName = "SPTDataLoaderService"
    
    // orion:new
    func shouldModify(_ url: URL) -> Bool {
        let isModifyingCustomizeResponse = PremiumPatchingGroup.isActive
        let isModifyingLyrics = LyricsGroup.isActive
        
        return (url.isLyrics && isModifyingLyrics)
            || (url.isCustomize && isModifyingCustomizeResponse)
    }
    
    func URLSession(
        _ session: URLSession,
        task: URLSessionDataTask,
        didCompleteWithError error: Error?
    ) {
        guard
            let request = task.currentRequest,
            let url = request.url
        else {
            return
        }
        
        if error == nil, 
            shouldModify(url),
            let buffer = URLSessionHelper.shared.obtainData(for: url) 
        {
            if url.isLyrics {
                do {
                    orig.URLSession(
                        session,
                        dataTask: task,
                        didReceiveData: try getLyricsForCurrentTrack(
                            originalLyrics: try? Lyrics(serializedBytes: buffer)
                        )
                    )
                    
                    orig.URLSession(session, task: task, didCompleteWithError: nil)
                }
                catch {
                    orig.URLSession(session, task: task, didCompleteWithError: error)
                }
                
                return
            }
            
            do {
                var customizeMessage = try CustomizeMessage(serializedBytes: buffer)
                modifyRemoteConfiguration(&customizeMessage.response)
                
                orig.URLSession(
                    session,
                    dataTask: task,
                    didReceiveData: try customizeMessage.serializedBytes()
                )
                
                orig.URLSession(session, task: task, didCompleteWithError: nil)

                NSLog("[EeveeSpotify] Modified customize data")
                return
            }
            catch {
                NSLog("[EeveeSpotify] Unable to modify customize data: \(error)")
            }
        }
        
        orig.URLSession(session, task: task, didCompleteWithError: error)
        
    }

    func URLSession(
        _ session: URLSession,
        dataTask task: URLSessionDataTask,
        didReceiveResponse response: HTTPURLResponse,
        completionHandler handler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        guard
            let request = task.currentRequest,
            let url = request.url
        else {
            return
        }
        
        if shouldModify(url), url.isLyrics, response.statusCode != 200 {
            let okResponse = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "2.0",
                headerFields: [:]
            )!
            
            do {
                let lyricsData = try getLyricsForCurrentTrack()
                
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
            let url = request.url
        else {
            return
        }

        if shouldModify(url) {
            URLSessionHelper.shared.setOrAppend(data, for: url)
            return
        }

        orig.URLSession(session, dataTask: task, didReceiveData: data)
    }
}
