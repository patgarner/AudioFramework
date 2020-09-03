//
//  SamplerData.swift
//  Composer Bot Desktop
//
//  Created by Admin on 2/15/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

public class SamplerData : Codable {
    //for now one instrument and one user data object are ok
    var audioComponentDescription : AudioComponentDescription?
    var state : [String : Any]?
    public init(){
        
    }
    public init(state: [String: Any]?, audioComponentDescription: AudioComponentDescription?){
        self.state = state
        self.audioComponentDescription = audioComponentDescription
    }
    private enum CodingKeys: String, CodingKey {
        case audioComponentDescription
        case rawState
    }
    required public init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let rawState = try container.decode(Data.self, forKey: .rawState)
            if let stateDictionary = NSKeyedUnarchiver.unarchiveObject(with: rawState)! as? [String : Any] {
                self.state = stateDictionary
            }
        } catch {
            print("SamplerData.init(fromDecoder) failed to load State.")
        }
        audioComponentDescription = try container.decode(AudioComponentDescription.self, forKey: .audioComponentDescription)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let rawState = NSKeyedArchiver.archivedData(withRootObject: state)
        try container.encode(rawState, forKey: .rawState)
        if audioComponentDescription != nil {
            try container.encode(audioComponentDescription!, forKey: .audioComponentDescription)
        }
    }
    
}
