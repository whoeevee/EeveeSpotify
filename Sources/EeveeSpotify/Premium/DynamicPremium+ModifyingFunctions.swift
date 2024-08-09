import Foundation

func modifyRemoteConfiguration(_ configuration: inout UcsResponse) {
    if UserDefaults.overwriteConfiguration {
        configuration.resolve.configuration = try! BundleHelper.shared.resolveConfiguration()
    }
    
    modifyAttributes(&configuration.attributes.accountAttributes)
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
    attributes["payments-initial-campaign"] = AccountAttribute.with {
        $0.stringValue = "default"
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
    attributes["on-demand"] = AccountAttribute.with {
        $0.boolValue = true
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
    attributes["social-session"] = AccountAttribute.with {
        $0.boolValue = true
    }
    attributes["social-session-free-tier"] = AccountAttribute.with {
        $0.boolValue = false
    }
    
    //
    
    attributes["com.spotify.madprops.delivered.by.ucs"] = AccountAttribute.with {
        $0.boolValue = true
    }
    attributes["com.spotify.madprops.use.ucs.product.state"] = AccountAttribute.with {
        $0.boolValue = true
    }
}
