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
    }
    override func allAudioUnits(includeSends: Bool) -> [AVAudioNode] {
        var audioUnits : [AVAudioNode] = []
        if inputNode != nil {
            audioUnits.append(inputNode!)
        }
        audioUnits.append(contentsOf: effects)
        if sendSplitterNode != nil {
            audioUnits.append(sendSplitterNode!)
        }
        if includeSends{
            audioUnits.append(contentsOf: sendOutputs)
        }
        if outputNode != nil {
            audioUnits.append(outputNode!)
        }
        return audioUnits
    }
    override func createIONodes() {
        super.createIONodes()
        self.inputNode = AudioNodeFactory.mixerNode(name: "MasterInput")
        self.delegate.engine.attach(inputNode!)
        let format = inputNode!.outputFormat(forBus: 0)
        self.delegate.engine.connect(inputNode!, to: outputNode!, format: format)
    }
}
