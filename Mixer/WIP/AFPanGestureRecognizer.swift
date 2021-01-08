//
//  AFPanGestureRecognizer.swift
//  AudioFramework
//
//  Created by Pat Garner on 12/31/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import AppKit

class AFPanGestureRecognizer: NSPanGestureRecognizer {
    override func mouseDown(with event: NSEvent) {
        (view as? DraggableButton)?.toggle()
        super.mouseDown(with: event)
    }
}
