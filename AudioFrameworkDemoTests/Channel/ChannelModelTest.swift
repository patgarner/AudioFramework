//
//  ChannelModelTest.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 10/9/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import XCTest
import AudioFramework

class ChannelModelTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testEquality(){
        let channelModel1 = ChannelModel()
        let channelModel2 = ChannelModel()
        XCTAssert(channelModel1 == channelModel2)
        
        channelModel1.busInput = 9
        XCTAssert(channelModel1 != channelModel2)
        channelModel2.busInput = 9
        XCTAssert(channelModel1 == channelModel2)
        
        channelModel1.id = "orange"
        XCTAssert(channelModel1 != channelModel2)
        channelModel2.id = "orange"
        XCTAssert(channelModel1 == channelModel2)
        
        channelModel1.trackName = "volcano"
        XCTAssert(channelModel1 != channelModel2)
        channelModel2.trackName = "volcano"
        XCTAssert(channelModel1 == channelModel2)
        
        channelModel1.pan = 0.77
        XCTAssert(channelModel1 != channelModel2)
        channelModel2.pan = 0.77
        XCTAssert(channelModel1 == channelModel2)
        
        channelModel1.volume = 0.91
        XCTAssert(channelModel1 != channelModel2)
        channelModel2.volume = 0.91
        XCTAssert(channelModel1 == channelModel2)
        
        channelModel1.solo = true
        XCTAssert(channelModel1 != channelModel2)
        channelModel2.solo = true
        XCTAssert(channelModel1 == channelModel2)
        
        channelModel1.mute = true
        XCTAssert(channelModel1 != channelModel2)
        channelModel2.mute = true
        XCTAssert(channelModel1 == channelModel2)
    }

    func testSerialization() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let channelModel = ChannelModel()
        channelModel.busInput = 9
        channelModel.id = "orange"
        channelModel.mute = true
        channelModel.solo = true
        channelModel.volume = 0.75
        do {
            let data = try encoder.encode(channelModel)
            let channelModel2 = try decoder.decode(ChannelModel.self, from: data)
            XCTAssert(channelModel == channelModel2)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
