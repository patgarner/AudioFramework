//
//  AFPanGestureRecognizer.swift
//  AudioFramework
//
//  Created by Pat Garner on 12/31/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import AppKit

class AFPanGestureRecognizer: NSPanGestureRecognizer {
    var mouseDownEvent: (() -> Void)? = nil
    var mouseDraggedEvent: (() -> Void)? = nil
    
    var capturedViews = [NSView]()
    
    override func mouseDown(with event: NSEvent) {
        capturedViews.removeAll()
        mouseDraggedEvent = mouseDownEvent
        super.mouseDown(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        mouseDraggedEvent?()
        mouseDraggedEvent = nil
        super.mouseDragged(with: event)
    }
}
