//
//  AudioComponentDescriptionExtension.swift
//  Composer Bot Desktop
//
//  Created by Admin on 2/17/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

extension AudioComponentDescription : Codable{
    enum CodingKeys: CodingKey{
        case componentType
        case componentSubType
        case componentManufacturer
    }
    public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        componentType = try container.decode(OSType.self, forKey: .componentType)  
        componentSubType = try container.decode(OSType.self, forKey: .componentSubType) 
        componentManufacturer = try container.decode(OSType.self, forKey: .componentManufacturer)  


    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(componentType, forKey: .componentType)
        try container.encode(componentSubType, forKey: .componentSubType)
        try container.encode(componentManufacturer, forKey: .componentManufacturer)
    }
}
