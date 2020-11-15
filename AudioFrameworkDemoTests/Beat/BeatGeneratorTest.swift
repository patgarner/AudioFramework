//
//  BeatGeneratorTest.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 10/23/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import XCTest
import AudioFramework

class BeatGeneratorTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testPlayingOffline() {
        let beatGenerator = BeatGenerator(tempo: 60.0)
        let del = FakeBeatDelegate()
        beatGenerator.addListener(del)
        beatGenerator.playOffline(until: 1.5)
        XCTAssert(del.currentBeat == 1.5)
    }
    func testPlayingAt60BPM(){
        let beatGenerator = BeatGenerator(tempo: 60.0)
        let del = FakeBeatDelegate()
        beatGenerator.addListener(del)
        let expectation = XCTestExpectation(description: "Finished playing")
        beatGenerator.start()
        Timer.scheduledTimer(withTimeInterval: 4.03, repeats: false) { (timer) in
            XCTAssert(del.currentBeat == 4.0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4.5)
    }
    func testPlayingAt120BPM(){
        let beatGenerator = BeatGenerator(tempo: 120.0)
        let del = FakeBeatDelegate()
        beatGenerator.addListener(del)
        let expectation = XCTestExpectation(description: "Finished playing")
        beatGenerator.start()
        Timer.scheduledTimer(withTimeInterval: 4.03, repeats: false) { (timer) in
            XCTAssert(del.currentBeat == 8.0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4.5)
    }
    func testSettingTo120BPMAfterTheFact(){
        //When setting tempo after the fact, should play at new tempo
        let beatGenerator = BeatGenerator(tempo: 60.0)
        let del = FakeBeatDelegate()
        beatGenerator.addListener(del)
        let expectation = XCTestExpectation(description: "Finished playing")
        beatGenerator.set(tempo: 120.0)
        beatGenerator.start()
        Timer.scheduledTimer(withTimeInterval: 4.03, repeats: false) { (timer) in
            XCTAssert(del.currentBeat == 8.0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4.5)
    }

    func testIfJumpingToBeatWhilePlayingShouldPlayBeat(){
        //If playing and playhead jumps to a particular beat, it should play that beat and not skip it.
        //Fails intermittently.
        let beatGenerator = BeatGenerator(tempo: 60.0)
        let del = FakeBeatDelegate()
        beatGenerator.addListener(del)
        beatGenerator.start()
        let expectation = XCTestExpectation(description: "Finished playing beats")
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            //We wait 1 second, then jump back to beat zero
            beatGenerator.goto(beat: 0)
        }
        let timer2 = Timer.scheduledTimer(withTimeInterval: 1.25, repeats: false) { (timer) in
            beatGenerator.stop()
            let beatZeroCount = del.numInstancesOf(beat: 0)
            XCTAssert(beatZeroCount == 2)
            print("Beat zero count = \(beatZeroCount)")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.5)
    }
    func testStopAndStartShouldNotMakeTempoIncrease(){
        let beatGenerator = BeatGenerator(tempo: 60.0)
        let del = FakeBeatDelegate()
        beatGenerator.addListener(del)
        beatGenerator.start()
        beatGenerator.stop()
        beatGenerator.start()
        beatGenerator.stop()
        beatGenerator.start()
        beatGenerator.stop()
        del.currentBeat = -1
        del.absoluteBeat = -1
        del.allCurrentBeats.removeAll()
        let expectation = XCTestExpectation(description: "Finished playing beats")
        beatGenerator.start()
        Timer.scheduledTimer(withTimeInterval: 1.05, repeats: false) { (timer) in
            beatGenerator.stop()
            XCTAssert(del.currentBeat == 1.0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.25)
    }
    func testIfNotPlayingDontGenBeat(){
        //If it is not playing, it should not generate a beat.
        let beatGenerator = BeatGenerator(tempo: 60.0)
        let del = FakeBeatDelegate()
        beatGenerator.addListener(del)
        beatGenerator.isPlaying = false
        beatGenerator.triggerPulse()
        XCTAssert(del.allCurrentBeats.count == 0)
    }
}
