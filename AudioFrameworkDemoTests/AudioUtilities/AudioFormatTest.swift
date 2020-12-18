//
//  AudioFormatTest.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 12/12/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import XCTest
import AudioFramework

class AudioFormatTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEquals() {
        let format1 = AudioFormat()
        let format2 = AudioFormat()
        format1.id = "A"
        XCTAssert(format1 != format2)
        format2.id = "A"
        XCTAssert(format1 == format2)
        
        format1.name = "A"
        XCTAssert(format1 != format2)
        format2.name = "A"
        XCTAssert(format1 == format2)
        
        format1.type = .mp3
        XCTAssert(format1 != format2)
        format2.type = .mp3
        XCTAssert(format1 == format2)
        
        format1.bitRate = 56
        XCTAssert(format1 != format2)
        format2.bitRate = 56
        XCTAssert(format1 == format2)
        
        format1.constantBitRate = false
        XCTAssert(format1 != format2)
        format2.constantBitRate = false
        XCTAssert(format1 == format2)
        
        format1.mp3BitRate = 500
        XCTAssert(format1 != format2)
        format2.mp3BitRate = 500
        XCTAssert(format1 == format2)
    }
    func testSerialization(){
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let format1 = AudioFormat()
        format1.id = "Apple"
        format1.name = "Orange"
        format1.type = .wav
        format1.bitRate = 50
        format1.mp3BitRate = 444
        format1.constantBitRate = false
        do {
            let data = try encoder.encode(format1)
            let format2 = try decoder.decode(AudioFormat.self, from: data)
            XCTAssert(format1 == format2)
        } catch {
            XCTFail()
            print(error)
        }
    }
}
