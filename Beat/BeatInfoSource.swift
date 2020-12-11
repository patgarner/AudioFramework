//
//  BeatInfoSource.swift
//  AudioFramework
//
//  Created by Admin on 10/20/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation

public protocol BeatInfoSource{
    var isPlaying : Bool { get }
    func start()
    func stop()
    func add(beatListener: BeatDelegate)
    func removeBeatListeners()
    var exactBeat : Double { get }
    func playOffline(numBars: Int, barLength: Double)
    var currentBeat : Double { get set }
    func set(tempo: Double)
    func playOffline(until: Double)
}
