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
        return plugin
    }
    class func instrument(description: AudioComponentDescription, context: @escaping AUHostMusicalContextBlock) -> AVAudioUnitMIDIInstrument{
        let plugin = AVAudioUnitMIDIInstrument(audioComponentDescription: description)
        plugin.auAudioUnit.musicalContextBlock = context
        return plugin
    }
    class func player() -> AVAudioNode{
        let node = AVAudioPlayerNode()
        return node
    }
//    class func passThrough() -> AUAudioUnit?{
//        let audioComponentDescription = AudioComponentDescription()
//        do{
//            let effect = try PassThroughNodeAudioUnit(componentDescription: audioComponentDescription)
//            return effect
//        } catch {
//            return nil
//        }
//    }
}
