//
//  BeatToolsTest.swift
//  Ultra Jam Session
//
//  Created by Admin on 11/29/16.
//  Copyright © 2016 UltraMusician. All rights reserved.
//

import XCTest

class BeatToolsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetBar() {
        let bt = BeatTools()
        var bar = bt.getBarForBeat(1.0)
        XCTAssert(bar == 0);
        bar = bt.getBarForBeat(4.0)
        XCTAssert(bar == 1);
        bar = bt.getBarForBeat(17.0)
        XCTAssert(bar == 4);
    }
}
