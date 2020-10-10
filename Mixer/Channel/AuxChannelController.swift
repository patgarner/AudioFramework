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
        let inputNode = AudioNodeFactory.mixerNode(name: "AuxInput")
        self.delegate.engine.attach(inputNode)
        self.inputNode = inputNode
    }
    override func allAudioUnits(includeSends: Bool) -> [AVAudioNode] {
        var audioUnits : [AVAudioNode] = []
        if inputNode != nil {
            audioUnits.append(inputNode!)
        }
        audioUnits.append(contentsOf: effects)
        if muteNode != nil{
            audioUnits.append(muteNode!)
        }
        if soloNode != nil {
            audioUnits.append(soloNode!)
        }
        if sendSplitterNode != nil{
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
    override func set(channelPluginData: ChannelPluginData, contextBlock: @escaping AUHostMusicalContextBlock) {
        super.set(channelPluginData: channelPluginData, contextBlock: contextBlock)
        guard let inputNode = inputNode else { return }
        delegate.connect(busNumber:channelPluginData.busInput, to: inputNode)
    }
}
