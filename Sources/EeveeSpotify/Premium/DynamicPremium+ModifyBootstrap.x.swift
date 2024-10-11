import Orion

private func showHavePremiumPopUp() {
    PopUpHelper.showPopUp(
        delayed: true,
        message: "have_premium_popup".localized,
        buttonText: "OK".uiKitLocalized
    )
}

class SpotifySessionDelegateBootstrapHook: ClassHook<NSObject>, SpotifySessionDelegate {
    static var targetName: String {
        EeveeSpotify.isOldSpotifyVersion
            ? "SPTCoreURLSessionDataDelegate"
            : "SPTDataLoaderService"
    }
    
    func URLSession(
        _ session: URLSession,
        dataTask task: URLSessionDataTask,
        didReceiveResponse response: HTTPURLResponse,
        completionHandler handler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        orig.URLSession(session, dataTask: task, didReceiveResponse: response, completionHandler: handler)
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
        
        if url.isBootstrap {
            URLSessionHelper.shared.setOrAppend(data, for: url)
            return
        }

        orig.URLSession(session, dataTask: task, didReceiveData: data)
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
        
        if error == nil && url.isBootstrap {
            let buffer = URLSessionHelper.shared.obtainData(for: url)!
            
            do {
                var bootstrapMessage = try BootstrapMessage(serializedBytes: buffer)
                
                if UserDefaults.patchType == .notSet {
                    if bootstrapMessage.attributes["type"]?.stringValue == "premium" {
                        UserDefaults.patchType = .disabled
                        showHavePremiumPopUp()
                    }
                    else {
                        UserDefaults.patchType = .requests
                        PremiumPatchingGroup().activate()
                    }
                    
                    NSLog("[EeveeSpotify] Fetched bootstrap, \(UserDefaults.patchType) was set")
                }
                
                if UserDefaults.patchType == .requests {
                    modifyRemoteConfiguration(&bootstrapMessage.ucsResponse)
                    
                    orig.URLSession(
                        session,
                        dataTask: task,
                        didReceiveData: try bootstrapMessage.serializedBytes()
                    )
                    
                    NSLog("[EeveeSpotify] Modified bootstrap data")
                }
                else {
                    orig.URLSession(session, dataTask: task, didReceiveData: buffer)
                }
                
                orig.URLSession(session, task: task, didCompleteWithError: nil)
                return
            }
            catch {
                NSLog("[EeveeSpotify] Unable to modify bootstrap data: \(error)")
            }
        }
        
        orig.URLSession(session, task: task, didCompleteWithError: error)
    }
}
