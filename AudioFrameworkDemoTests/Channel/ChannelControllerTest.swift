//
//  ChannelControllerTest.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 10/16/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import XCTest
import AVFoundation
import AudioFramework

class ChannelControllerTest: XCTestCase {
    var context = MusicalContext()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInit(){
        let delegate = FakeChannelControllerDelegate()
        let controller = InstrumentChannelController(delegate: delegate)
    }
    func testSerialization(){
        let delegate = FakeChannelControllerDelegate()
        let controller = InstrumentChannelController(delegate: delegate)
        controller.solo = true
        controller.mute = true
        controller.volume = 0.75
        controller.pan = 0.1
        let model = controller.getChannelPluginData()
        XCTAssert(model.mute == true)
        XCTAssert(model.solo == true)
        XCTAssert(model.volume == 0.75)
        XCTAssert(model.pan == 0.1)
        
        let controller2 = InstrumentChannelController(delegate: delegate)
        controller2.set(channelPluginData: model)
        XCTAssert(controller2.mute == true)
        XCTAssert(controller2.solo == true)
        XCTAssert(controller2.volume == 0.75)
        XCTAssert(controller2.pan == 0.1)
    }
}
