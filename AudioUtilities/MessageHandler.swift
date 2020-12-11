//
//  MessageHandler.swift
//  AudioFramework
//
//  Created by Admin on 10/28/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation

class MessageHandler{
    class func log(_ message : String, displayFormat: [MessageDisplayFormat]){
        if displayFormat.contains(.file) {
            writeToFile(message: message)
        }
        if displayFormat.contains(.print){
            print(message)
        }
        if displayFormat.contains(.notification){
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .AudioControllerMessage, object: message)
            }
        }
    }
    private class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    private class func writeToFile(message: String){
        let fileManager = FileManager.default
        let url = getDocumentsDirectory().appendingPathComponent("AudioControllerLog.txt")
        let data = message.data(using: .utf8)
        if fileManager.fileExists(atPath: url.relativePath){
            do {
                let fileHandle = try FileHandle.init(forWritingTo: url)
                fileHandle.seekToEndOfFile()
                if let data = data {
                    fileHandle.write("\n".data(using: .utf8)!)
                    fileHandle.write(data)
                }
            } catch {}
        } else {
            fileManager.createFile(atPath: url.relativePath, contents: data, attributes: [:])
        }
    }
}

enum MessageDisplayFormat {
    case notification
    case print
    case file
}
