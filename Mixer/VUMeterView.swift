//
//  VUMeterView.swift
//  AudioFramework
//
//  Created by Admin on 10/1/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import Cocoa

class VUMeterView : NSView {
    var level : Float = 0
    let color = NSColor.green
    override func draw(_ dirtyRect: NSRect) {
        let height = CGFloat(level) * self.frame.size.height
        let rect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: height)
        color.setFill()
        rect.fill()
    }
}
