//
//  MasterChannelController.swift
//  AudioFramework
//
//  Created by Admin on 9/12/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation
import AVFoundation

class MasterChannelController : ChannelController{
    override init(delegate: ChannelControllerDelegate){
        super.init(delegate: delegate)
    }
//    override func allAudioUnits(includeSends: Bool) -> [AVAudioNode] {
//        var audioUnits : [AVAudioNode] = []
//        if inputNode != nil {
//            audioUnits.append(inputNode!)
//        }
//        audioUnits.append(contentsOf: effects)
//        if muteNode != nil {
//            audioUnits.append(muteNode!)
//        }
//        if soloNode != nil {
//            audioUnits.append(soloNode!)
//        }
//        if sendSplitterNode != nil {
//            audioUnits.append(sendSplitterNode!)
//        }
//        if includeSends{
//            audioUnits.append(contentsOf: sendOutputs)
//        }
//        if outputNode != nil {
//            audioUnits.append(outputNode!)
//        }
//        return audioUnits
//    }
//    override func createIONodes() {
//        super.createIONodes()
//        self.inputNode = AudioNodeFactory.mixerNode(name: "MasterInput")
//        self.delegate.engine.attach(inputNode!)
//        delegate.connect(sourceNode: inputNode!, destinationNode: outputNode!)
//    }
    override func setSoloVolume(on: Bool) {
        //Do nothing
    }
}
