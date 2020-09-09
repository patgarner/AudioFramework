//
//  AllAudioUnitData.swift
//  AudioFramework
//
//  Created by Admin on 9/7/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public class AllPluginData : Codable{
    public var channels : [ChannelPluginData] = []
    enum CodingKeys : CodingKey{
        case channels
    }
    public init(){
        
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            channels = try container.decode([ChannelPluginData].self, forKey: .channels)
        } catch {
            print("AllPluginData: failed to load channel plugins: Error: \(error)")
        }
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(channels, forKey: .channels)
    }
}
