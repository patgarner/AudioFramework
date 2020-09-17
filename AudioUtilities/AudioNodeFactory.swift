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
    class func mixerNode() -> AVAudioMixerNode{
        let mixerNode = AVAudioMixerNode()
        return mixerNode
    }
    class func splitter(channelSettable: ChannelSettable) {
        var desc = AudioComponentDescription()
        desc.componentType = 0
        desc.componentSubType = kAudioUnitSubType_MultiSplitter
        desc.componentManufacturer = 0
        desc.componentFlags = 0
        desc.componentFlagsMask = 0
        let components =  AVAudioUnitComponentManager.shared().components(matching: desc)
        if components.count < 1 { return }
        let component = components[0]
        print(component.manufacturerName)
        print(component.name)
        AVAudioUnit.instantiate(with: component.audioComponentDescription, options: []) { (avAudioUnit, error) in
            if let audioUnit = avAudioUnit {
                DispatchQueue.main.async {
                    channelSettable.setPreOutput(node: audioUnit)
                }
            }
        }
        
    }
}
