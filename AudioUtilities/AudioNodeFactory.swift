//
//  AudioNodeFactory.swift
//  AudioFramework
//
//  Created by Admin on 9/12/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

class AudioNodeFactory{
    class func mixerNode() -> AVAudioMixerNode{
        let mixerNode = AVAudioMixerNode()
        return mixerNode
    }
}
