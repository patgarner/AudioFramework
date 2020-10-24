//
//  FakeBeatDelegate.swift
//  Ultra Jam Session
//
//  Created by Admin on 11/30/16.
//  Copyright © 2016 UltraMusician. All rights reserved.
//

import Foundation
import AudioFramework

class FakeBeatDelegate : BeatDelegate{
    var currentBeat : Double = 0.0
    var absoluteBeat : Double = 0.0
    func didPlayBeat(_ beat: Double, absoluteBeat: Double) {
        currentBeat = beat
        self.absoluteBeat = absoluteBeat
    }
}
