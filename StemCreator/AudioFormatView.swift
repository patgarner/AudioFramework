//
//  AudioFormatPanel.swift
//  AudioFramework
//
//  Created by Admin on 12/16/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Cocoa

class AudioFormatView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        let stackView = NSStackView(frame: self.bounds)
        let width = self.frame.size.width
        let rowHeight : CGFloat = 20
        let rowFrame = CGRect(x: 0, y: 0, width: width, height: rowHeight)
        let rowView = NSView(frame: rowFrame)
        let label = NSTextField()
        label.stringValue = "PCM"
        rowView.addSubview(label)
        stackView.addArrangedSubview(rowView)
        addSubview(stackView)
        self.needsDisplay = true
        self.addSubview(label)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    override func draw(_ dirtyRect: NSRect) {
//        NSColor.red.setFill()
//        NSBezierPath.fill(self.bounds)
//    }
}
