//
//  DraggableButton.swift
//  AudioFramework
//
//  Created by Admin on 10/2/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Cocoa

class DraggableButton: NSButton {
    var delegate : DraggableButtonDelegate?
    var type : DraggableButtonType = .none
    // Disable default mouseEvent handling in order
    // provide custom functionality via gesture
    // recognizer
    override func mouseDown(with event: NSEvent) {}
    override func mouseUp(with event: NSEvent) {}
    func toggle() {
        setNewState(newState: state == .on ? .off : .on)
    }
    func setNewState(newState: NSControl.StateValue) {
        state = newState
        isHighlighted = (newState == .on)
        _ = target?.perform(action)
    }
    func setNewState(newState: NSControl.StateValue, for testRect: CGRect, buttonType: DraggableButtonType) {
        guard let superview = superview else { return }
        guard type == buttonType else { return }
        guard state != newState else { return }
        
        var testFrame = frame
        testFrame.origin.x = 30
        testFrame.size.width = 30
        testFrame = superview.convert(testFrame, to: nil)
        
        guard testFrame.intersects(testRect) else { return }
        
        setNewState(newState: newState)
    }
}

protocol DraggableButtonDelegate {
    func changeMultiple(to selected: Bool, location: NSPoint, buttonType: DraggableButtonType)
}

public enum DraggableButtonType: Int {
    case mute = 101
    case solo
    case none
}
