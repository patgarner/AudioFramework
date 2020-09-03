//
//  ChannelStripNode.swift
//  Composer Bot Desktop
//
//  Created by Admin on 7/13/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

class ChannelStripNode : AVAudioNode{
     private var instrumentAU: AVAudioUnitMIDIInstrument? = nil
    //(Audio FX)
    //Bus Send
    //Bus Volume
    //Pan
    //Volume
    var pan = 0
    var volume : Float = 0.0
    func initialize(){
       // AudioService.shared.audioEngine.
        
        
    }
    override init(){
        super.init()
    }
}
