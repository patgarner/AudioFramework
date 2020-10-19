//
//  BeatTools.swift
//  Ultra Jam Session
//
//  Created by Admin on 11/29/16.
//  Copyright © 2016 UltraMusician. All rights reserved.
//

import Foundation

public class BeatTools{
    func getBarForBeat(_ beat : Float) -> Int{
        let barLength : Float = 4.0
        //Assuming 4 beats per bar
        //Beat 0 = bar 0
        //Beat 1.0 = bar 0
        //Beat 4.0 = bar 1
        //Beat
        let bar = Int(beat / barLength)
        return bar
    }
}
