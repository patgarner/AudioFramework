//
//  AuxChannelController.swift
//  AudioFramework
//
//  Created by Admin on 9/15/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

public class AuxChannelController : ChannelController{
    override public func getChannelPluginData() -> ChannelModel {
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
    override public func set(channelPluginData: ChannelModel) {
        super.set(channelPluginData: channelPluginData)
        guard let inputNode = inputNode else { return }
        delegate.connect(busNumber:channelPluginData.busInput, destinationNode: inputNode)
    }
}
