//
//  PulseGenerator.swift
//  AudioFramework
//
//  Created by Admin on 11/14/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

class PulseGenerator{
    private var thread : Thread? = nil
    var delegate : PulseDelegate? = nil
    var subdivisionDurationNano : UInt64 = 0
    init(){
        
    }
    init(subdivisionDurationNano: UInt64, delegate: PulseDelegate){
        self.subdivisionDurationNano = subdivisionDurationNano
        self.delegate = delegate
    }
    func start(){
        if thread != nil { return }
        let thread = Thread(block: { 
            let startTimeNanoSeconds = mach_absolute_time()
            var desiredWakeTimeNanoseconds = startTimeNanoSeconds
            while (self.thread != nil){
                let actualWakeTimeNanoseconds = mach_absolute_time()
                let oversleepTimeNano = actualWakeTimeNanoseconds - desiredWakeTimeNanoseconds
                self.delegate?.triggerPulse()
                desiredWakeTimeNanoseconds += self.subdivisionDurationNano
                var recommendedSleepTimeNano : UInt64 = self.subdivisionDurationNano
                if oversleepTimeNano < recommendedSleepTimeNano {
                    recommendedSleepTimeNano -= oversleepTimeNano
                }
                let recommendedSleepTimeMicro : UInt32 = UInt32(recommendedSleepTimeNano & 0xFFFFFFFF) / 1000
                usleep(recommendedSleepTimeMicro)
                if self.thread == nil { return }
            }
        })
        self.thread = thread
        thread.qualityOfService = .userInteractive
        thread.start()
    }
    func stop(){
        if let thread = thread {
            thread.cancel()
            self.thread = nil
        } else { 
            return
        }
    }

}

protocol PulseDelegate{
    func triggerPulse()
}
