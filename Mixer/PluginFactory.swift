//
//  PluginFactory.swift
//  AudioFramework
//
//  Created by Admin on 10/8/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

class PluginFactory{
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
}
