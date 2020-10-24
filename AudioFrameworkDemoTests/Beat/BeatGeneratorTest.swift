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



}
