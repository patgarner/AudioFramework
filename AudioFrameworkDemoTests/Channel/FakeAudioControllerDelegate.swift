//
//  FakeAudioControllerDelegate.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 10/16/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AudioFramework
import Cocoa
import AVFoundation

class FakeAudioControllerDelegate : AudioControllerDelegate{
    public var currentTempo = 0.0
    public var timeSignatureNumerator = 0.0
    public var timeSignatureDenominator = 0
    public var currentBeatPosition = 0.0
    public var sampleOffsetToNextBeat = 0
    public var currentMeasureDownbeatPosition = 0.0
    public init(){
        
    }
    func load(viewController: NSViewController) {
        
    }
    
    func log(_ message: String) {
        
    }
    
    func displayInterface(audioUnit: AudioUnit) {
        
    }
    
    func exportMidi(to url: URL) {
        
    }
    
    var musicalContext: MusicalContext{
        let context = MusicalContext()
        context.currentTempo = currentTempo
        context.timeSignatureNumerator = timeSignatureNumerator
        context.timeSignatureDenominator = timeSignatureDenominator
        context.currentBeatPosition = currentBeatPosition
        context.sampleOffsetToNextBeat = sampleOffsetToNextBeat
        context.currentMeasureDownbeatPosition = currentMeasureDownbeatPosition
        return context
    }
    
    
}
