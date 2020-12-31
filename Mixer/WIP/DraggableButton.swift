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
//    override func mouseDragged(with event: NSEvent) {
//        print("mouse dragged")
//        let location = event.locationInWindow
//        let buttonState = (state == .on)
//        delegate?.changeMultiple(to: buttonState, location: location, buttonType: type)
//    }
//    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
//        print("drag started")
//        return NSDragOperation()
//    }
//    override func mouseDown(with event: NSEvent) {
//        super.mouseDown(with: event)
//    }
    
    static var buttons = Set<DraggableButton>()
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        Self.buttons.insert(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Self.buttons.insert(self)
    }
    
    deinit {
        Self.buttons.remove(self)
    }
}

protocol DraggableButtonDelegate {
    func changeMultiple(to selected: Bool, location: NSPoint, buttonType: DraggableButtonType)
}

enum DraggableButtonType {
    case mute
    case solo
    case none
}
