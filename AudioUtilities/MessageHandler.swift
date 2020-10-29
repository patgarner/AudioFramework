//
//  MessageHandler.swift
//  AudioFramework
//
//  Created by Admin on 10/28/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

class MessageHandler{
    class func log(_ message : String){
        DispatchQueue.main.async {
            print(message)
            NotificationCenter.default.post(name: .AudioControllerMessage, object: message)
        }
    }
}
