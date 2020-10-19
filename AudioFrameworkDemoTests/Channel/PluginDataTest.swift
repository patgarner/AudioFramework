//
//  PluginDataTest.swift
//  AudioFrameworkTests
//
//  Created by Admin on 10/19/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import XCTest
import AVFoundation
import AudioFramework

class PluginDataTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    func testSerialization() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        var state : [String: Any] = [:]
        state["name"] = "Dave"
        state["age"] = 45
        var desc = AudioComponentDescription()
        desc.componentType = kAudioUnitType_MusicDevice
        desc.componentSubType = kAudioUnitSubType_Delay
        desc.componentManufacturer = kAudioUnitManufacturer_Apple
        desc.componentFlags = 0
        desc.componentFlagsMask = 0
        let pluginData = PluginData(state: state, audioComponentDescription: desc)
        do {
            let data = try encoder.encode(pluginData)
            let samplerData2 = try decoder.decode(PluginData.self, from: data)
            if let state2 = samplerData2.state {
                let name = state2["name"] as? String
                let age = state2["age"] as? Int
                XCTAssert(name == "Dave")
                XCTAssert(age == 45)
            } else {
                XCTFail("SamplerDataTest.serialization failed")
            }
            if let desc2 = samplerData2.audioComponentDescription{
                XCTAssert(desc2.componentType == desc.componentType)
                XCTAssert(desc2.componentSubType == desc.componentSubType)
                XCTAssert(desc2.componentManufacturer == desc.componentManufacturer)
            } else {
                XCTFail("SamplerDataTest.serialization failed for audioComponentDescription")
            }
        } catch {
            XCTFail("SamplerDataTest.serialization failed")
        }
    }

}
