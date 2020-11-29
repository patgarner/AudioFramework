//
//  BeatGenerator.swift
//  Composer Bot Desktop
//
//  Created by Admin on 7/31/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import CoreServices

public class BeatGenerator : BeatGeneratable, PulseDelegate{
    private var currentBeatTimesStamp : UInt64 = 0
    private var subdivisionLengthInBeats = 0.125
    private var subdivisionDurationNano : UInt64 = 0
    private var subdivisionDurationSeconds = 0.0
    private var beatListeners : [BeatDelegate] = []
    private var offlineMode = false
    private var currentBeat = 0.0
    private var nextBeat = 0.0
    private let pulseGenerator = PulseGenerator()
    public var isPlaying = false
    public func getCurrentBeat() -> Double {
        return currentBeat
    }
    private var tempo : Double = 100.0
    public func set(tempo: Double) {
        self.tempo = tempo
        calculateValues()
    }
    public func getTempo() -> Double {
        return tempo
    }
    public init(tempo: Double){
        self.tempo = tempo
        calculateValues()
        pulseGenerator.delegate = self
    }
    private func calculateValues(){
        let divisionsPerMeasure = 32.0
        subdivisionDurationSeconds =  240.0 / tempo / divisionsPerMeasure
        subdivisionDurationNano = UInt64(subdivisionDurationSeconds * 1000000000.0)
        pulseGenerator.subdivisionDurationNano = subdivisionDurationNano //TODO: Storing in 2 places. BAD.
    }
    public func start() {
        isPlaying = true
        pulseGenerator.start()
    }
    public func triggerPulse() {
        if !isPlaying { return }
        playBeatCycle()
    }
    func playBeatCycle(){
        currentBeat = nextBeat
        currentBeatTimesStamp = mach_absolute_time()
        nextBeat = currentBeat + subdivisionLengthInBeats
        playBeat()
    }
    private func incrementBeat(){
        currentBeat = nextBeat
        nextBeat = currentBeat + subdivisionLengthInBeats
        currentBeatTimesStamp = mach_absolute_time()
    }
    public func stop() {
        isPlaying = false
    }
    public func playOffline(numBars: Int, barLength: Double) {
        offlineMode = true
        let totalBeats = Double(numBars) * barLength
        while(currentBeat < totalBeats){
            playBeat()
            incrementBeat()
        }
        offlineMode = false
    }
    public func playOffline(until end: Double) {
        offlineMode = true
        currentBeat = 0
        while(currentBeat <= end){
            playBeat()
            currentBeat += subdivisionLengthInBeats
        }
        offlineMode = false
    }
    private func playBeat(){
        for i in 0..<self.beatListeners.count{
            let beatListener = self.beatListeners[i]
            beatListener.didPlayBeat(currentBeat, absoluteBeat: currentBeat)
        }
    }
    public var exactBeat: Double{
        let now = mach_absolute_time()
        let beatTimesStamp = currentBeatTimesStamp
        if subdivisionDurationNano == 0 {
            MessageHandler.log("Error: BeatGenerator.exactBeat subdivisionDurationNanoseconds = 0. Divide by zero imminent.", displayFormat: [.file])
            return currentBeat
        }
        if beatTimesStamp > now {
            MessageHandler.log("Error: BeatGenerator.exactBeat currentBeatTimestamp > now", displayFormat: [.print])
            print("Error: BeatGenerator.exactBeat currentBeatTimestamp > now")
            return 0
        }
        let diffNano = now - beatTimesStamp
        let diffSeconds = Double(diffNano & 0xFFFFFFFF) / 1000000000.0
        let numSubdivisionsElapsed = Double(diffSeconds / subdivisionDurationSeconds)
        let beatsElapsed = numSubdivisionsElapsed * subdivisionLengthInBeats
        let beat = currentBeat + beatsElapsed
        return beat
    }
    public func addListener(_ listener: BeatDelegate) {
        beatListeners.append(listener)
    }
    public func removeListeners() {
        beatListeners.removeAll()
    }
    public func goto(beat: Double){
        nextBeat = beat
    }
}
