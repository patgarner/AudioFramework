//
//  AllAudioUnitData.swift
//  AudioFramework
//
//  Created by Admin on 9/7/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public class AllPluginData : Codable{
    public var plugins : [PluginData] = []
    enum CodingKeys : CodingKey{
        case plugins
    }
    public init(){
        
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            plugins = try container.decode([PluginData].self, forKey: .plugins)
        } catch {
            print("AllPluginData: failed to load plugins: Error: \(error)")
        }
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(plugins, forKey: .plugins)
    }
}
