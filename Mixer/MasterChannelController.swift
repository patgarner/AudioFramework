//
//  MasterChannelController.swift
//  AudioFramework
//
//  Created by Admin on 9/12/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

class MasterChannelController : ChannelController{
    override var inputNode: AVAudioNode?{
        if effects.count > 0 {
            return effects[0]
        } else {
            return engine.mainMixerNode
        }
    }
}
