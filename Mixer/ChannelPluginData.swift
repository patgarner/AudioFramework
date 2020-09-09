//
//  ChannelPluginData.swift
//  AudioFramework
//
//  Created by Admin on 9/8/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//
// Stores the raw settings data for channel plugins

import Foundation

public class ChannelPluginData : Codable{
    public var instrumentPlugin = PluginData()
    public var effectPlugins : [PluginData] = []
    enum CodingKeys: CodingKey{
        case instrumentPlugin
        case effectPlugins
    }
    public init(){
        
    }
    required public init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            instrumentPlugin = try container.decode(PluginData.self, forKey: .instrumentPlugin)
        } catch {}
        do {
            effectPlugins = try container.decode([PluginData].self, forKey: .effectPlugins)
        } catch {}
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instrumentPlugin, forKey: .instrumentPlugin)
        try container.encode(effectPlugins, forKey: .effectPlugins)
    }
}
