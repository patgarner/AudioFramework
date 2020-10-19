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
    public init(tempo: Double){
          setTempo(tempo: tempo)
    }
    public func setTempo(tempo: Double) {
        let divisionsPerMeasure = 32.0
        let subdivisionDurationSeconds =  240.0 / tempo / divisionsPerMeasure
        subdivisionDurationMicroseconds = UInt32(subdivisionDurationSeconds * 1000000.0)
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
                self.incrementBeat()
            }
        })
        thread!.start()
    }
    
    public func stop() {
        if thread != nil{
            thread!.cancel()
            thread = nil
        }
    }
    
    public func playOffline(numBars: Int, barLength: Double) {
        let totalBeats = Double(numBars) * barLength
        while(currentBeat < totalBeats){
            playBeat()
            incrementBeat()
        }
    }
    
    public func playOffline(until end: Double) {
        currentBeat = 0
        while(currentBeat <= end){
            playBeat()
            incrementBeat()
        }
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
    public func back(){ //TODO : Don't hardcode section
        let section = Int(currentBeat) / 16
        var newBeat = Double(section - 1) * 16.0
        if newBeat < 0 {
            newBeat = 0
        }
        currentBeat = newBeat
    }
    public func forward(){
        let section = Int(currentBeat) / 16
        let newBeat = Double(section + 1) * 16.0
        currentBeat = newBeat
    }
    func goto(beat: Double){
        self.currentBeat = beat
    }
    
    public var isPlaying: Bool {
        if thread == nil {
            return false
        } else {
            return true
        }
    }

}
