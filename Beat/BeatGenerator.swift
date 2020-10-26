//
//  BeatGenerator2.swift
//  Composer Bot Desktop
//
//  Created by Admin on 7/31/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public class BeatGenerator : BeatGeneratable{
    public var currentBeat = 0.0 
    private var currentBeatTimesStamp : UInt64 = 0
    private var subdivisionLengthInBeats = 0.125
    private var subdivisionDurationMicroseconds : UInt32 = 0
    private var thread : Thread? = nil
    private var beatListeners : [BeatDelegate] = []
    private var running = false
    private var offlineMode = false
    public var tempo : Double = 100.0 {
        didSet{
            let divisionsPerMeasure = 32.0
            let subdivisionDurationSeconds =  240.0 / tempo / divisionsPerMeasure
            subdivisionDurationMicroseconds = UInt32(subdivisionDurationSeconds * 1000000.0)
        }
    }
    public init(tempo: Double){
        self.tempo = tempo
    }
    public func start() {
        if thread != nil {
            return
        }
        currentBeatTimesStamp = mach_absolute_time()
        self.thread = Thread(block: { 
            var offset : UInt32 = 0
            while (self.thread != nil){
                self.playBeat()
                let preSleepTime = mach_absolute_time()
                var recommendedSleepTime : UInt32 = 0
                if offset < self.subdivisionDurationMicroseconds {
                    recommendedSleepTime = self.subdivisionDurationMicroseconds - offset
                }
                usleep(recommendedSleepTime)
                let postSleepTime = mach_absolute_time()
                let diffNanoSeconds = Double(postSleepTime - preSleepTime)
                let diffMicroSeconds = UInt32(round(diffNanoSeconds / 1000.0))
                offset = diffMicroSeconds - recommendedSleepTime
                if self.thread != nil {
                    self.incrementBeat()
                }
            }
        })
        thread!.qualityOfService = .userInteractive
        thread!.start()
    }
    public func stop() {
        if thread == nil { return }
        self.thread!.cancel()
        self.thread = nil
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
            incrementBeat()
        }
        offlineMode = false
    }
    private func playBeat(){
        for i in 0..<self.beatListeners.count{
            let beatListener = self.beatListeners[i]
            beatListener.didPlayBeat(currentBeat, absoluteBeat: currentBeat)
        }
    }
    private func incrementBeat(){
        currentBeat += self.subdivisionLengthInBeats
        currentBeatTimesStamp = mach_absolute_time()
    }
    public var exactBeat: Double{
        let now = mach_absolute_time()
        let diffNano = now - currentBeatTimesStamp
        let numSubdivisionsElapsed = Double(diffNano / UInt64(subdivisionDurationMicroseconds)) / 1000.0
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
    func goto(beat: Double){
        self.currentBeat = beat
    }
    
    public var isPlaying: Bool {
        if thread != nil {
            return true
        } else if offlineMode {
            return true
        } else {
            return false
        }
    }
}
