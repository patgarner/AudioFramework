//
//  Mp3FormatTest.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 12/12/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import XCTest
import AudioFramework

class Mp3FormatTest: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testEquality() {
        let format1 = Mp3Format()
        let format2 = Mp3Format()
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
        
        format1.constantBitRate = true
        XCTAssert(format1 != format2)
        format2.constantBitRate = true
        XCTAssert(format1 == format2)
    }
    
    func testSerialization(){
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let format1 = Mp3Format()
        format1.id = "Apple"
        format1.name = "Orange"
        format1.type = .mp3
        format1.constantBitRate = true
        format1.bitRate = 32
        do {
            let data = try encoder.encode(format1)
            let format2 = try decoder.decode(Mp3Format.self, from: data)
            XCTAssert(format1 == format2)
        } catch {
            XCTFail()
            print(error)
        }
    }
}
