//
//  StemCheckbox.swift
//  AudioFramework
//
//  Created by Admin on 9/26/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Cocoa

public class StemCell: NSTextField {
    var selected = false
    var stemCheckboxDelegate : StemCheckboxDelegate!
    var id = ""
    var rowType : RowType = .row
    var columnType : ColumnType = .channel
    init(frame frameRect: NSRect, rowType: RowType, columnType: ColumnType, delegate: StemCheckboxDelegate, id: String) {
        super.init(frame: frameRect)
        stemCheckboxDelegate = delegate
        self.id = id
        self.rowType = rowType
        self.columnType = columnType
        self.isSelectable = false
        if rowType == .row {
            let font = NSFont(name: "Helvetica", size: 20)
            self.font = font
            self.alignment = NSTextAlignment.center
            selected = delegate.isSelected(id: id)
        } else if rowType == .header{
            self.rotate(byDegrees: 270)
            if let title = delegate.getNameFor(channelId: id){
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
        if rowType == .header {
            if columnType == .fileType {
                stemCheckboxDelegate.didSelect(audioFormatId: id)
            } else {
                return
            }
        }
        selected = !selected
        refresh()
        stemCheckboxDelegate.selectionChangedTo(selected: selected, id: id, type: columnType)
    }
    func changeSelection(to selected: Bool){
        if rowType == .header { return }
        if self.selected == selected { return }
        self.selected = selected
        refresh()
//        stemCheckboxDelegate.channelSelectionChangedTo(selected: selected, channelId: id)
        stemCheckboxDelegate.selectionChangedTo(selected: selected, id: id, type: columnType)
    }
    private func refresh(){
        if rowType == .header { return }
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

    override public func mouseUp(with event: NSEvent) { } //TODO: Is this needed?
}
