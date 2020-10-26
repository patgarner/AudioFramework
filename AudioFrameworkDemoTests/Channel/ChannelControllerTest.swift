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
}
