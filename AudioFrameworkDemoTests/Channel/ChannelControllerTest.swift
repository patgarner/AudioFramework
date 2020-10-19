//
//  ChannelControllerTest.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 10/16/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import XCTest
import AVFoundation
import AudioFramework

class ChannelControllerTest: XCTestCase {
    var context = MusicalContext()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let context : AUHostMusicalContextBlock = getMusicalContext
        var desc = AudioComponentDescription()
        desc.componentType = kAudioUnitType_MusicDevice
        let components = AVAudioUnitComponentManager.shared().components(matching: desc)
        var selectedComponent : AVAudioUnitComponent!
        for component in components{
            let man = component.manufacturerName
            let name = component.name
            if man == "Native Instruments", name == "Kontakt" {
                selectedComponent = component
            }
        }
        let audioComponentDescription = selectedComponent.audioComponentDescription
        let engine = AVAudioEngine()
        let instrumentNode = AudioNodeFactory.instrument(description: audioComponentDescription, context: context)
        engine.attach(instrumentNode)
        let format = instrumentNode.outputFormat(forBus: 0)
        engine.connect(instrumentNode, to: engine.mainMixerNode, format: format)
        do {
            try engine.start()
        } catch {
            XCTFail("Couldn't start engine.")
        }
        let expectation = XCTestExpectation(description: "getMusicalContext finished")
        wait(for: [expectation], timeout: 10.0)
    }
    func getMusicalContext(currentTempo : UnsafeMutablePointer<Double>?,
                           timeSignatureNumerator : UnsafeMutablePointer<Double>?,
                           timeSignatureDenominator : UnsafeMutablePointer<Int>?,
                           currentBeatPosition: UnsafeMutablePointer<Double>?,
                           sampleOffsetToNextBeat : UnsafeMutablePointer<Int>?,
                           currentMeasureDownbeatPosition: UnsafeMutablePointer<Double>?) -> Bool {
        print("Fart.")
        currentTempo?.pointee = context.currentTempo
        print("tempo = \(context.currentTempo)")
        timeSignatureNumerator?.pointee = context.timeSignatureNumerator
        timeSignatureDenominator?.pointee = context.timeSignatureDenominator
        currentBeatPosition?.pointee = context.currentBeatPosition
        sampleOffsetToNextBeat?.pointee = context.sampleOffsetToNextBeat
        currentMeasureDownbeatPosition?.pointee = context.currentMeasureDownbeatPosition
        return true
    }
    func testInit(){
        let delegate = FakeChannelControllerDelegate()
        let controller = InstrumentChannelController(delegate: delegate)
    }
}
