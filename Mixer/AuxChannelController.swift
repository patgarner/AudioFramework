//
//  AuxChannelController.swift
//  AudioFramework
//
//  Created by Admin on 9/15/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

class AuxChannelController : ChannelController{
    override func createIONodes() {
        super.createIONodes()
      
        let mixerIntput = AudioNodeFactory.mixerNode()
        self.delegate.engine.attach(mixerIntput)
        self.inputNode = mixerIntput
    }
    override var allAudioUnits : [AVAudioNode] {
        var audioUnits : [AVAudioNode] = []
        if inputNode != nil {
            audioUnits.append(inputNode!)
        }
        audioUnits.append(contentsOf: effects)
        if let preOutput = preOutputNode{
            audioUnits.append(preOutput)
        }
        if outputNode != nil {
            audioUnits.append(outputNode!)
        }
        return audioUnits
    }
}
