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
        let channelModel1 = ChannelPluginData()
        let channelModel2 = ChannelPluginData()
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
        
        
    

//        public var instrumentPlugin = PluginData()
//        public var effectPlugins : [PluginData] = []
//        public var sends : [SendData] = []
//        public var output = BusData(number: -1, type: .none)
    }

    func testSerialization() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let channelModel = ChannelPluginData()
        channelModel.busInput = 9
        channelModel.id = "orange"
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
