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
//import PassThroughNode

class AudioNodeFactory{
    class func mixerNode(name: String) -> UltraMixerNode{
        let mixerNode = UltraMixerNode()
        mixerNode.name = name
        return mixerNode
    }
    class func effect(description: AudioComponentDescription, context: @escaping AUHostMusicalContextBlock) -> AVAudioUnitEffect{
        let plugin = AVAudioUnitEffect(audioComponentDescription: description)
        plugin.auAudioUnit.musicalContextBlock = context
        let resultingContext = plugin.auAudioUnit.musicalContextBlock
        //d,d,i,d,i,d
        var d1 = 0.0
        var d2 = 0.0
        var d3 = 0.0
        var d4 = 0.0
        var i1 = 0
        var i2 = 0
        resultingContext!(&d1, &d2, &i1, &d3, &i2, &d4)
        return plugin
    }
    class func instrument(description: AudioComponentDescription, context: @escaping AUHostMusicalContextBlock) -> AVAudioUnitMIDIInstrument{
        let plugin = AVAudioUnitMIDIInstrument(audioComponentDescription: description)
        plugin.auAudioUnit.musicalContextBlock = context
        let resultingContext = plugin.auAudioUnit.musicalContextBlock
        return plugin
    }
    class func player() -> AVAudioNode{
        let node = AVAudioPlayerNode()
        return node
    }
}
