//
//  BeatGeneratable.swift
//  Composer Bot Desktop
//
//  Created by Admin on 7/31/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public protocol BeatGeneratable {
   // func set(tempo: Double)
    var tempo : Double { get set }
    func start()
    func stop()
    func playOffline(numBars: Int, barLength: Double)
    func addListener(_ listener : BeatDelegate)
    func removeListeners()
    func playOffline(until end: Double)
    func back()
    func forward()
    var isPlaying : Bool { get }
    var currentBeat : Double { get set }
    var exactBeat : Double { get }
}
