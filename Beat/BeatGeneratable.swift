//
//  BeatGeneratable.swift
//  Composer Bot Desktop
//
//  Created by Admin on 7/31/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public protocol BeatGeneratable {
    func set(tempo: Double)
    func getTempo() -> Double
    func start()
    func stop()
    func playOffline(numBars: Int, barLength: Double)
    func addListener(_ listener : BeatDelegate)
    func removeListeners()
    func playOffline(until end: Double)
    var isPlaying : Bool { get }
    func goto(beat: Double)
    var exactBeat : Double { get }
    func getCurrentBeat() -> Double
}
