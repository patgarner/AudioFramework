//
//  AudioNodeFactory.swift
//  AudioFramework
//
//  Created by Admin on 9/12/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
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
    class func effect(description: AudioComponentDescription, context: AUHostMusicalContextBlock?) -> AVAudioUnitEffect{
        let plugin = AVAudioUnitEffect(audioComponentDescription: description)
        plugin.auAudioUnit.musicalContextBlock = context
        return plugin
        //An audio unit accessing this property should cache it in realtime-safe storage before beginning to render.
    }
    class func loadEffectAsynchronously(description: AudioComponentDescription, context: AUHostMusicalContextBlock?, number: Int, showInterface: Bool, delegate: AudioNodeFactoryDelegate) {
        AVAudioUnitEffect.instantiate(with: description, options: []) { (audioUnit, error) in
            if let e = error { 
                print (e) 
            }
            if let effect = audioUnit as? AVAudioUnitEffect {
                effect.auAudioUnit.musicalContextBlock = context
                delegate.effectFinishedLoading(audioUnitEffect: effect, number: number, showInterface: showInterface)
            }
        }
    }
    class func instrument(description: AudioComponentDescription, context: AUHostMusicalContextBlock?) -> AVAudioUnitMIDIInstrument{
        let plugin = AVAudioUnitMIDIInstrument(audioComponentDescription: description)
        plugin.auAudioUnit.musicalContextBlock = context     
        return plugin
    }
    class func player() -> AVAudioNode{
        let node = AVAudioPlayerNode()
        return node
    }
}

protocol AudioNodeFactoryDelegate {
    func effectFinishedLoading(audioUnitEffect: AVAudioUnitEffect, number: Int, showInterface: Bool)
}
