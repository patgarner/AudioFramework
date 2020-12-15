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
        stemCreatorModel1.name = "Bob"
        XCTAssert(stemCreatorModel1 != stemCreatorModel2)

//        stemCreatorModel.addStem()
//        stemCreatorModel.selectionChangedTo(selected: true, stemNumber: 0, channelId: "DAVE")
//        let audioFormat = WavFormat()
//        stemCreatorModel.audioFormats.append(audioFormat)
    }
    func testSelectingChannelId() {
        let stemCreatorModel = StemCreatorModel()
        stemCreatorModel.addStem()
        let audioFormats = stemCreatorModel.audioFormats
        let format0 = audioFormats[0]
        stemCreatorModel.selectionChangedTo(selected: true, stemNumber: 0, channelId: format0.id)
        let stemModel = stemCreatorModel.stems[0]
        XCTAssert(stemModel.isSelected(channelId: format0.id))
    }
}
