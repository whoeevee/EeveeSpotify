import Orion

func showHavePremiumPopUp() {
    PopUpHelper.showPopUp(
        delayed: true,
        message: "It looks like you have an active Premium subscription, so the tweak won't patch the data or restrict the use of Premium server-sided features. You can manage this in the EeveeSpotify settings.",
        buttonText: "OK"
    )
}

func showOfflineBnkMethodSetPopUp() {
    PopUpHelper.showPopUp(
        delayed: true,
        message: "App restart is needed to get Premium. You can manage the Premium patching method in the EeveeSpotify settings.",
        buttonText: "Restart Now",
        secondButtonText: "Restart Later",
        onPrimaryClick: {
            exitApplication()
        }
    )
}

func modifyAttributes(_ attributes: inout [String: AccountAttribute]) {
    
    attributes["type"] = AccountAttribute.with {
        $0.stringValue = "premium"
    }
    attributes["player-license"] = AccountAttribute.with {
        $0.stringValue = "premium"
    }
    attributes["financial-product"] = AccountAttribute.with {
        $0.stringValue = "pr:premium,tc:0"
    }
    attributes["name"] = AccountAttribute.with {
        $0.stringValue = "Spotify Premium"
    }
    
    //
    
    attributes["unrestricted"] = AccountAttribute.with {
        $0.boolValue = true
    }
    attributes["catalogue"] = AccountAttribute.with {
        $0.stringValue = "premium"
    }
    attributes["streaming-rules"] = AccountAttribute.with {
        $0.stringValue = ""
    }
    attributes["pause-after"] = AccountAttribute.with {
        $0.longValue = 0
    }
    
    //
    
    attributes["ads"] = AccountAttribute.with {
        $0.boolValue = false
    }
    
    attributes.removeValue(forKey: "ad-use-adlogic")
    attributes.removeValue(forKey: "ad-catalogues")
    
    //
    
    attributes["shuffle-eligible"] = AccountAttribute.with {
        $0.boolValue = true
    }
    attributes["high-bitrate"] = AccountAttribute.with {
        $0.boolValue = true
    }
    attributes["offline"] = AccountAttribute.with {
        $0.boolValue = true
    }
    attributes["nft-disabled"] = AccountAttribute.with {
        $0.stringValue = "1"
    }
    attributes["can_use_superbird"] = AccountAttribute.with {
        $0.boolValue = true
    }
    
    //
    
    attributes["com.spotify.madprops.use.ucs.product.state"] = AccountAttribute.with {
        $0.boolValue = true
    }
}

class SPTCoreURLSessionDataDelegateHook: ClassHook<NSObject> {
    
    static let targetName = "SPTCoreURLSessionDataDelegate"
    
    func URLSession(
        _ session: URLSession,
        task: URLSessionDataTask,
        didCompleteWithError error: Error?
    ) {
        if let url = task.currentRequest?.url, UserDefaults.patchType == .requests && url.isBootstrap {
            return
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
            let response = task.response,
            let url = request.url
        else {
            return
        }

        if url.isBootstrap {

            do {
                guard let buffer = OfflineHelper.appendDataAndReturnIfFull(
                    data,
                    response: response
                ) else {
                    return
                }
                
                OfflineHelper.dataBuffer = Data()
                
                var bootstrapMessage = try BootstrapMessage(serializedData: buffer)
                
                if UserDefaults.patchType == .requests {
                    
                    modifyAttributes(&bootstrapMessage.attributes)
                    
                    orig.URLSession(
                        session,
                        dataTask: task,
                        didReceiveData: try bootstrapMessage.serializedData()
                    )
                    
                    NSLog("[EeveeSpotify] Modified bootstrap data")
                }
                else {
                    
                    if UserDefaults.patchType == .notSet {
                        
                        if bootstrapMessage.attributes["type"]?.stringValue == "premium" {
                            UserDefaults.patchType = .disabled
                            showHavePremiumPopUp()
                        }
                        else {
                            UserDefaults.patchType = .offlineBnk
                            showOfflineBnkMethodSetPopUp()
                        }
                        
                        NSLog("[EeveeSpotify] Fetched bootstrap, \(UserDefaults.patchType) was set")
                    }
                    
                    orig.URLSession(session, dataTask: task, didReceiveData: buffer)
                }
                
                orig.URLSession(session, task: task, didCompleteWithError: nil)
                return
            }
            catch {
                NSLog("[EeveeSpotify] Unable to modify bootstrap data: \(error)")
            }
        }

        orig.URLSession(session, dataTask: task, didReceiveData: data)
    }
}
