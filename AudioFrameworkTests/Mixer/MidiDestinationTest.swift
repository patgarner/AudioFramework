//
//  MidiDestinationTest.swift
//  AudioFrameworkTests
//
//  Created by Admin on 2/16/21.
//  Copyright © 2021 UltraMusician. All rights reserved.
//

import XCTest

class MidiDestinationTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEquality() throws {
        let midiDestination1 = MidiDestination(trackId: "", trackNumber: 0)
        let midiDestination2 = MidiDestination(trackId: "", trackNumber: 0)
        XCTAssert(midiDestination1 == midiDestination2)
        midiDestination1.trackId = "A"
        XCTAssert(midiDestination1 != midiDestination2)
        midiDestination2.trackId = "A"
        XCTAssert(midiDestination1 == midiDestination2)
        
        midiDestination1.trackNumber = 99
        XCTAssert(midiDestination1 != midiDestination2)
        midiDestination2.trackNumber = 99
        XCTAssert(midiDestination1 == midiDestination2)
        
        midiDestination1.channel = 2
        XCTAssert(midiDestination1 != midiDestination2)
        midiDestination2.channel = 2
        XCTAssert(midiDestination1 == midiDestination2)
    }
    func testSerialization() throws {
        let midiDestination1 = MidiDestination(trackId: "bob", trackNumber: 7)
        midiDestination1.channel = 9
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        do{
            let data = try encoder.encode(midiDestination1)
            let midiDestination2 = try decoder.decode(MidiDestination.self, from: data)
            XCTAssert(midiDestination1 == midiDestination2)
        } catch {
            XCTFail()
            return
        }
    }
    func testUpdateValues() throws {
        let midiDestination1 = MidiDestination(trackId: "apple", trackNumber: 1)
        midiDestination1.channel = 9
        let midiDestination2 = MidiDestination(trackId: "bob", trackNumber: 7)
        midiDestination2.updateValuesWith(midiDestination: midiDestination1)
        XCTAssert(midiDestination1 == midiDestination2)
        //Make sure deep copy
        midiDestination1.trackId = "asdf"
        XCTAssert(midiDestination1 != midiDestination2)
        midiDestination1.trackId = "apple"
        XCTAssert(midiDestination1 == midiDestination2)
    }
}
