//
//  MasterChannelController.swift
//  AudioFramework
//
//  Created by Admin on 9/12/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

class MasterChannelController : ChannelController{
    override init(delegate: ChannelControllerDelegate){
        super.init(delegate: delegate)
        type = .master
    }
    override var allAudioUnits : [AVAudioNode] {
        var audioUnits : [AVAudioNode] = []
        if inputNode != nil {
            audioUnits.append(inputNode!)
        }
        audioUnits.append(contentsOf: effects)
        if outputNode != nil {
            audioUnits.append(outputNode!)
        }
        return audioUnits
    }
    override func createIONodes() {
        let mixerInput = AudioNodeFactory.mixerNode()
        self.delegate.engine.attach(mixerInput)
        self.inputNode = mixerInput
        
        let mixerOutput = AudioNodeFactory.mixerNode()
        self.delegate.engine.attach(mixerOutput)
        self.outputNode = mixerOutput
        let format = mixerInput.outputFormat(forBus: 0)
        delegate.engine.connect(mixerInput, to: mixerOutput, format: format)
    }
}
