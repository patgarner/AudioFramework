//
//  WavFormatTest.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 12/12/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import XCTest
import AudioFramework

class WavFormatTest: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEquality() {
        let format1 = WavFormat()
        let format2 = WavFormat()
        format1.id = "Tomato"
        format2.id = "Tomato"
        XCTAssert(format1 == format2)
        
        format1.name = "G"
        XCTAssert(format1 != format2)
        format2.name = "G"
        XCTAssert(format1 == format2)
        
        format1.bitRate = 33
        XCTAssert(format1 != format2)
        format2.bitRate = 33
        XCTAssert(format1 == format2)
        
        format1.sampleRate = 111
        XCTAssert(format1 != format2)
        format2.sampleRate = 111
        XCTAssert(format1 == format2)
    }
    
    func testSerialization(){
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let format1 = WavFormat()
        format1.id = "Apple"
        format1.name = "Orange"
        format1.type = .wav
        format1.sampleRate = 1000
        format1.bitRate = 32
        do {
            let data = try encoder.encode(format1)
            let format2 = try decoder.decode(WavFormat.self, from: data)
            XCTAssert(format1 == format2)
        } catch {
            XCTFail()
            print(error)
        }
    }
}
