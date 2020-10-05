//
//  AudioNodeFactory.swift
//  AudioFramework
//
//  Created by Admin on 9/12/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox
import CoreAudioKit

class AudioNodeFactory{
    class func mixerNode(name: String) -> UltraMixerNode{
        let mixerNode = UltraMixerNode()
        mixerNode.name = name
        return mixerNode
    }
}
