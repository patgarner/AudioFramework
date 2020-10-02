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
        if sendSplitterNode != nil{
            audioUnits.append(sendSplitterNode!)
        }
        if soloNode != nil {
            audioUnits.append(soloNode!)
        }
        if outputNode != nil {
            audioUnits.append(outputNode!)
        }
        return audioUnits
    }
    override func getChannelPluginData() -> ChannelPluginData {
        let pluginData = super.getChannelPluginData()
        guard let input = inputNode else {
            return pluginData
        }
        if let busInputNumber = delegate.getBusInput(for: input){
            pluginData.busInput = busInputNumber
        } else {
            pluginData.busInput = -1
        }
        return pluginData
    }
    override func set(channelPluginData: ChannelPluginData) {
        super.set(channelPluginData: channelPluginData)
        guard let inputNode = inputNode else { return }
        delegate.connectBusInput(to: inputNode, busNumber: channelPluginData.busInput)
    }
}
