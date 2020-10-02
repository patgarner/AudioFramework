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
    func changeSelection(to selected: Bool){
        if type == .header { return }
        if self.selected == selected { return }
        self.selected = selected
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
    public override func mouseDragged(with event: NSEvent) {
        let location = event.locationInWindow
        stemCheckboxDelegate.changeMultiple(to: selected, location: location)
    }

    override public func mouseUp(with event: NSEvent) {
//        let x = min(startPoint.x, endPoint.x)
//        let y = min(startPoint.y, endPoint.y)
//        let w = abs(endPoint.x - startPoint.x)
//        let h = abs(endPoint.y - startPoint.y)
//        let rect = CGRect(x: x, y: y, width: w, height: h)
//        var descriptionIds : [String] = []
//        for lineView in lineViews{
//            if lineView.frame.intersects(rect) {
//                descriptionIds.append(lineView.descriptionId)
//            }
//        }
//        if descriptionIds.count > 0 { 
//            delegate?.didSelect(descriptionIds: descriptionIds)
//        }
//        
//        for lineView in lineViews{ //UGLY but only way to circumvent the dehighlighting that occurs when we call delegate
//            if lineView.frame.intersects(rect) {
//                lineView.selected = true
//                lineView.needsDisplay = true
//            }
//        }
//        startPoint = NSPoint()
//        endPoint = NSPoint()
//        self.needsDisplay = true
    }
}
