//
//  StemModelTest.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 12/15/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import XCTest

class StemModelTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEquality() {
        let stemModel1 = StemModel()
        let stemModel2 = StemModel()
        XCTAssert(stemModel1 == stemModel2)
       
        stemModel1.stemShortName = "Bob"
        XCTAssert(stemModel1 != stemModel2)
        stemModel2.stemShortName = "Bob"
        XCTAssert(stemModel1 == stemModel2)
        
        stemModel1.selectionChanged(selected: true, id: "Apple", type: .channel)
        XCTAssert(stemModel1 != stemModel2)
        stemModel2.selectionChanged(selected: true, id: "Apple", type: .channel)
        XCTAssert(stemModel1 == stemModel2)
        
        stemModel1.selectionChanged(selected: false, id: "Apple", type: .channel)
        XCTAssert(stemModel1 != stemModel2)
        stemModel2.selectionChanged(selected: false, id: "Apple", type: .channel)
        XCTAssert(stemModel1 == stemModel2)
        
        stemModel1.include = false
        XCTAssert(stemModel1 != stemModel2)
        stemModel2.include = false
        XCTAssert(stemModel1 == stemModel2)
        
        stemModel1.audioFormatIds.append("WAV")
        XCTAssert(stemModel1 != stemModel2)
        stemModel2.audioFormatIds.append("WAV")
        XCTAssert(stemModel1 == stemModel2)
        
        stemModel1.audioFormatIds.append("MP3")
        XCTAssert(stemModel1 != stemModel2)
        stemModel2.audioFormatIds.append("AIF")
        XCTAssert(stemModel1 != stemModel2)
        stemModel2.audioFormatIds[1] = "MP3"
        XCTAssert(stemModel1 == stemModel2)
        
        stemModel1.letter = "X"
        XCTAssert(stemModel1 != stemModel2)
        stemModel2.letter = "X"
        XCTAssert(stemModel1 == stemModel2)
    }


}
