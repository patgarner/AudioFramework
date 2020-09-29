//
//  StemCheckbox.swift
//  AudioFramework
//
//  Created by Admin on 9/26/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Cocoa

public class StemCell: NSTextField {
    var selected = false
    var stemCheckboxDelegate : StemCheckboxDelegate!
    var channelId = ""
    var type : RowType = .row
    init(frame frameRect: NSRect, type: RowType, delegate: StemCheckboxDelegate, channelId: String) {
        super.init(frame: frameRect)
        stemCheckboxDelegate = delegate
        self.channelId = channelId
        self.type = type
        self.isSelectable = false
        if type == .row {
            let font = NSFont(name: "Helvetica", size: 20)
            self.font = font
            self.alignment = NSTextAlignment.center
            selected = delegate.isSelected(channelId: channelId)
        } else if type == .header{
            self.rotate(byDegrees: 270)
            if let title = delegate.getNameFor(channelId: channelId){
                self.stringValue = title
            }
        }
        refresh()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    override public func mouseDown(with event: NSEvent) {
        if type == .header { return }
        selected = !selected
        refresh()
        stemCheckboxDelegate.checkboxChangedTo(selected: selected, channelId: channelId)
    }
    private func refresh(){
        if type == .header { return }
        if selected {
            self.stringValue = "X"
        } else {
            self.stringValue = ""
        }
    }
}