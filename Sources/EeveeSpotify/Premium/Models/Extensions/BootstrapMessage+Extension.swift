//
//  File.swift
//  
//
//  Created by eevee on 28/05/2024.
//

import Foundation

extension BootstrapMessage {
    
    var attributes: [String: AccountAttribute] {
        get {
            self.wrapper.oneMoreWrapper.message.response.attributes.accountAttributes
        }
        set(attributes) {
            self.wrapper.oneMoreWrapper.message.response.attributes.accountAttributes = attributes
        }
    }
}
