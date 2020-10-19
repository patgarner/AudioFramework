//
//  FakeMusicalContext.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 10/16/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation
import AudioFramework

class FakeMusicalContext{
    var context = MusicalContext()
    func getMusicalContext(currentTempo : UnsafeMutablePointer<Double>?,
                           timeSignatureNumerator : UnsafeMutablePointer<Double>?,
                           timeSignatureDenominator : UnsafeMutablePointer<Int>?,
                           currentBeatPosition: UnsafeMutablePointer<Double>?,
                           sampleOffsetToNextBeat : UnsafeMutablePointer<Int>?,
                           currentMeasureDownbeatPosition: UnsafeMutablePointer<Double>?) -> Bool {
        currentTempo?.pointee = context.currentTempo
        timeSignatureNumerator?.pointee = context.timeSignatureNumerator
        timeSignatureDenominator?.pointee = context.timeSignatureDenominator
        currentBeatPosition?.pointee = context.currentBeatPosition
        sampleOffsetToNextBeat?.pointee = context.sampleOffsetToNextBeat
        currentMeasureDownbeatPosition?.pointee = context.currentMeasureDownbeatPosition
        return true
    }
}
