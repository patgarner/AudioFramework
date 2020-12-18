//
//  StemCreatorModelTest.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 12/12/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import XCTest
import AudioFramework

class StemCreatorModelTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testEquality(){
        let stemCreatorModel1 = StemCreatorModel()
        let stemCreatorModel2 = StemCreatorModel()
        XCTAssert(stemCreatorModel1 == stemCreatorModel2)
        stemCreatorModel1.namePrefix = "Bob"
        XCTAssert(stemCreatorModel1 != stemCreatorModel2)
        stemCreatorModel2.namePrefix = "Bob"
        XCTAssert(stemCreatorModel1 == stemCreatorModel2)

        stemCreatorModel1.addStem()
        XCTAssert(stemCreatorModel1 != stemCreatorModel2)
        stemCreatorModel2.addStem()
        XCTAssert(stemCreatorModel1 == stemCreatorModel2)
        
        stemCreatorModel1.selectionChangedTo(selected: true, stemNumber: 0, id: "DAVE", type: .channel)
        XCTAssert(stemCreatorModel1 != stemCreatorModel2)
        stemCreatorModel2.selectionChangedTo(selected: true, stemNumber: 0, id: "DAVE", type: .channel)
        XCTAssert(stemCreatorModel1 == stemCreatorModel2)

        let audioFormat = AudioFormat()
        stemCreatorModel1.audioFormats.append(audioFormat)
        XCTAssert(stemCreatorModel1 != stemCreatorModel2)
        stemCreatorModel2.audioFormats.append(audioFormat)
        XCTAssert(stemCreatorModel1 == stemCreatorModel2)
    }
    func testSerialization(){
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let stemCreatorModel1 = StemCreatorModel()
        stemCreatorModel1.namePrefix = "Bob"
        stemCreatorModel1.addStem()
        stemCreatorModel1.selectionChangedTo(selected: true, stemNumber: 0, id: "DAVE", type: .channel)
        stemCreatorModel1.audioFormats.removeAll()
        //TODO: Add Audio Formats
        do {
            let data = try encoder.encode(stemCreatorModel1)
            let stemCreatorModel2 = try decoder.decode(StemCreatorModel.self, from: data)
            XCTAssert(stemCreatorModel1 == stemCreatorModel2)
        } catch {
            XCTFail("\(error)")
        }
        
    }
    func testDeleteAudioFormats(){
        
    }
}
