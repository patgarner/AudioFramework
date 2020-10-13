//
//  UltraMixerNode.swift
//  AudioFramework
//
//  Created by Admin on 10/5/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Cocoa
import AVFoundation

class UltraMixerNode: AVAudioMixerNode {
    var name = ""
    override var debugDescription: String{
        let s = name + " : UltraMixerNode"
        return s
    }
    override var description: String{
        return debugDescription
    }
}
