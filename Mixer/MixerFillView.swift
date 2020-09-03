//
//  MixerFillView.swift
//  AudioFramework
//
//  Created by Admin on 9/2/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import Cocoa

class MixerFillView: NSView {
    var color = NSColor.init(calibratedRed: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        color.setStroke()
        color.setFill()
        NSBezierPath.fill(self.bounds)
    }
}
