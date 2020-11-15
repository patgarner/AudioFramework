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
    var allCurrentBeats : [Double] = []
    func didPlayBeat(_ beat: Double, absoluteBeat: Double) {
        currentBeat = beat
        self.absoluteBeat = absoluteBeat
        allCurrentBeats.append(beat)
    }
    func reset(){
        currentBeat = 0
        absoluteBeat = 0
    }
    func numInstancesOf(beat: Double) -> Int{
        var total = 0
        for thisBeat in allCurrentBeats{
            if thisBeat == beat {
                total += 1
            }
        }
        return total
    }
}
