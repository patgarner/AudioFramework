//
//  MusicalContextBlock.swift
//  AudioFramework
//
//  Created by Admin on 10/6/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation

public class MusicalContext{
    public var currentTempo = 0.0
    public var timeSignatureNumerator = 0.0
    public var timeSignatureDenominator = 0
    public var currentBeatPosition = 0.0
    public var sampleOffsetToNextBeat = 0
    public var currentMeasureDownbeatPosition = 0.0
    public init(){
        
    }
    public var debugDescription : String {
        var string = "currentTempo: \(currentTempo)\n"
        string += "timeSignature: \(timeSignatureNumerator)/\(timeSignatureDenominator)\n"
        string += "currentBeatPosition: \(currentBeatPosition)\n"
        string += "sampleOffsetToNextBeat: \(sampleOffsetToNextBeat)\n"
        string += "currentMeasureDownbeatPosition: \(currentMeasureDownbeatPosition)\n"
        return string
    }
}
