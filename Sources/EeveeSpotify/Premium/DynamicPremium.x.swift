import Orion

private func showHavePremiumPopUp() {
    PopUpHelper.showPopUp(
        delayed: true,
        message: "It looks like you have an active Premium subscription, so the tweak won't patch the data or restrict the use of Premium server-sided features. You can manage this in the EeveeSpotify settings.",
        buttonText: "OK"
    )
}

class SPTCoreURLSessionDataDelegateHook: ClassHook<NSObject> {
    
    static let targetName = "SPTCoreURLSessionDataDelegate"
    
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
                var bootstrapMessage = try BootstrapMessage(serializedData: buffer)
                
                if UserDefaults.patchType == .notSet {
                    
                    if bootstrapMessage.attributes["type"]?.stringValue == "premium" {
                        UserDefaults.patchType = .disabled
                        showHavePremiumPopUp()
                    }
                    else {
                        UserDefaults.patchType = .requests
                        ServerSidedReminder().activate()
                    }
                    
                    NSLog("[EeveeSpotify] Fetched bootstrap, \(UserDefaults.patchType) was set")
                }
                
                if UserDefaults.patchType == .requests {
                    
                    modifyRemoteConfiguration(&bootstrapMessage.ucsResponse)
                    
                    orig.URLSession(
                        session,
                        dataTask: task,
                        didReceiveData: try bootstrapMessage.serializedData()
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
}
