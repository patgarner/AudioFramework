//
//  ChannelPluginData.swift
//  AudioFramework
//
//  Created by Admin on 9/8/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public class ChannelPluginData : Codable{
    public var instrumentPlugin : [PluginData] = []
    public var effectPlugins : [PluginData] = []
    enum CodingKeys: CodingKey{
        case instrumentPlugin
        case effectPlugins
    }
}
