//
//  StemRow.swift
//  AudioFramework
//
//  Created by Admin on 9/26/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Cocoa

public class StemRowView: NSView {
    var delegate : StemViewDelegate!
    weak var rowTitle : NSTextField!
    var number = -1
    var stemRowViewDelegate : StemRowViewDelegate?
    init(frame frameRect: NSRect, rowTitleWidth: CGFloat, rowHeight: CGFloat, columnWidth: CGFloat, delegate: StemViewDelegate, type: RowType, number: Int = -1) {
        super.init(frame: frameRect)
        self.delegate = delegate
        if type == .row {
            let rowTitleFrame = CGRect(x: 0, y: 0, width: rowTitleWidth, height: rowHeight)
            let rowTitle = NSTextField(frame: rowTitleFrame)
            self.rowTitle = rowTitle
            self.addSubview(rowTitle)
            if let stemName = delegate.getNameFor(stem: number) {
                rowTitle.stringValue = stemName
            }
            self.number = number
            rowTitle.target = self
            rowTitle.action = #selector(rowTitleChanged)
        }
        let numChannels = delegate.numChannels
        var x : CGFloat = rowTitleWidth
        for i in 0..<numChannels{
            let checkboxFrame = CGRect(x: x, y: 0, width: columnWidth, height: rowHeight)
            guard let id = delegate.getIdFor(channel: i) else { continue }
            let checkboxText = StemCell(frame: checkboxFrame, type: type, delegate: self, channelId: id)
            self.addSubview(checkboxText)
            x += columnWidth
        }
        if type == .row{
            let deleteButton = NSButton(title: "X", target: self, action: #selector(deleteStem))
            let deleteFrame = CGRect(x: x, y: 0, width: 40, height: rowHeight) 
            deleteButton.frame = deleteFrame
            addSubview(deleteButton)
        }
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    @objc func rowTitleChanged(sender: Any){
        let newTitle = rowTitle.stringValue
        delegate.setName(stemNumber: number, name: newTitle)
    }
    var isSelected : Bool {
        if let rowTitle = rowTitle{
            let result = rowTitle.isHighlighted
            
            return result
        } else {
            return false
        }
    }
    @objc func deleteStem(){
        delegate.delete(stemNumber: number)
        stemRowViewDelegate?.refresh()
    }
}

extension StemRowView : StemCheckboxDelegate{  
    public func getNameFor(channelId : String) -> String?{
        let name = delegate.getNameFor(channelId: channelId)
        return name
    }
    public func checkboxChangedTo(selected: Bool, channelId: String) {
        delegate.selectionChangedTo(selected: selected, stemNumber: number, channelId: channelId)
    }
    public func isSelected(channelId: String) -> Bool{
        let selected = delegate.isSelected(stemNumber: number, channelId: channelId)
        return selected
    }
    public func changeMultiple(to selected: Bool, location: NSPoint) {
        for subview in subviews{
            guard let cell = subview as? StemCell else { continue }
            let cellStart = cell.frame.origin.x
            let cellEnd = cell.frame.origin.x + cell.frame.size.width
            if location.x >= cellStart, location.x < cellEnd{
                cell.changeSelection(to: selected)
            }
        }
    }
    
}

enum RowType {
    case header
    case row
}
