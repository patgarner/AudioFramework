//
//  BeatGeneratorTest.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 10/23/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
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
        let desiredBeats = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1, 1.125, 1.25, 1.375, 1.5]
        XCTAssert(del.allCurrentBeats == desiredBeats)
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
    func testExactBeat(){
        let tempo = 60.0
        let beatGenerator = BeatGenerator(tempo: tempo)
        let expectation = XCTestExpectation(description: "Test complete")
        beatGenerator.start()
        let beatLengthSeconds = 60.0 / tempo
        let numBeats = 1.0625
        let time = beatLengthSeconds * numBeats
        Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (timer) in
            let exactBeat = beatGenerator.exactBeat
            let diff = abs(exactBeat - numBeats)
            XCTAssert(diff < 0.01)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.25)
    }
    func testExactBeatWithTempoChange(){
        let tempo = 70.0
        let beatGenerator = BeatGenerator(tempo: tempo)
        beatGenerator.set(tempo: 70)
        let expectation = XCTestExpectation(description: "Test complete")
        beatGenerator.start()
        let beatLengthSeconds = 60.0 / tempo
        let numBeats = 1.0625
        let time = beatLengthSeconds * numBeats
        Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (timer) in
            let exactBeat = beatGenerator.exactBeat
            let diff = abs(exactBeat - numBeats)
            XCTAssert(diff < 0.01)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.25)
    }
    func testLoopDisabled(){
        //Should keep playing past loop end
        let del = FakeBeatDelegate()
        let beatGenerator = BeatGenerator(tempo: 60)
        beatGenerator.setLoop(start: 2.0, stop: 3.0)
        beatGenerator.goto(beat: 2.0)
        beatGenerator.addListener(del)
        beatGenerator.loop = .disabled
        let expectation = XCTestExpectation(description: "Test complete")
        beatGenerator.start()
        let expectedBeats = [2.0, 2.125, 2.25, 2.375, 2.5, 2.625, 2.75, 2.875, 3.0, 3.125, 3.25, 3.375, 3.5]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
            for i in 0..<expectedBeats.count{
                XCTAssert(expectedBeats[i] == del.allCurrentBeats[i])
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
    func testLoopStartStopNonRepeating(){
        //It should play the last beat and stop
        let del = FakeBeatDelegate()
        let beatGenerator = BeatGenerator(tempo: 60)
        beatGenerator.setLoop(start: 2.0, stop: 3.0)
        beatGenerator.goto(beat: 2.0)
        beatGenerator.addListener(del)
        beatGenerator.loop = .stop
        let expectation = XCTestExpectation(description: "Test complete")
        beatGenerator.start()
        let expectedBeats = [2.0, 2.125, 2.25, 2.375, 2.5, 2.625, 2.75, 2.875, 3]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.01) {
            if del.allCurrentBeats.count != expectedBeats.count{
                XCTFail()
                return
            }
            for i in 0..<expectedBeats.count{
                XCTAssert(expectedBeats[i] == del.allCurrentBeats[i])
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.25)
    }
    func testLoopStartStopRepeating(){
        //It should play the last beat and stop
        let del = FakeBeatDelegate()
        let beatGenerator = BeatGenerator(tempo: 60)
        beatGenerator.setLoop(start: 2.0, stop: 3.0)
        beatGenerator.goto(beat: 2.0)
        beatGenerator.addListener(del)
        beatGenerator.loop = .enabled
        let expectation = XCTestExpectation(description: "Test complete")
        beatGenerator.start()
        let expectedBeats = [2.0, 2.125, 2.25, 2.375, 2.5, 2.625, 2.75, 2.875, 2.0, 2.125, 2.25, 2.375, 2.5, 2.625, 2.75, 2.875]
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            for i in 0..<expectedBeats.count{
                XCTAssert(expectedBeats[i] == del.allCurrentBeats[i])
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.25)
    }
}
