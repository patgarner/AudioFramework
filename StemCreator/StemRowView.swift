//
//  StemRow.swift
//  AudioFramework
//
//  Created by Admin on 9/26/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Cocoa

public class StemRowView: NSView {
    private weak var rowTitle : NSTextField!
    var number = -1
    var delegate : StemRowViewDelegate!
    private weak var progressBar : NSProgressIndicator!
    private weak var includeCheckbox : NSButton!
    //Dimensions
    private let includeCheckboxWidth : CGFloat = 25
    private var rowTitleWidth : CGFloat = 100
    private var columnWidth : CGFloat = 25
    private let deleteButtonWidth : CGFloat = 40
    private let progressBarWidth : CGFloat = 100
    init(frame frameRect: NSRect, rowTitleWidth: CGFloat, rowHeight: CGFloat, columnWidth: CGFloat, delegate: StemRowViewDelegate, type: RowType, number: Int = -1) {
        super.init(frame: frameRect)
        self.rowTitleWidth = rowTitleWidth
        self.columnWidth = columnWidth
        self.delegate = delegate
        var x : CGFloat = 0
        if type == .row {
            //Include Checkbox
            let includeCheckboxFrame = CGRect(x: 0, y: 0, width: includeCheckboxWidth, height: rowHeight)
            let includeCheckbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(includeDidChange))
            includeCheckbox.frame = includeCheckboxFrame
            self.addSubview(includeCheckbox)
            self.includeCheckbox = includeCheckbox
            if delegate.isIncluded(stemNumber: number){
                includeCheckbox.state = .on
            }
            //Row Title
            let rowTitleFrame = CGRect(x: includeCheckboxWidth, y: 0, width: rowTitleWidth, height: rowHeight)
            let rowTitle = NSTextField(frame: rowTitleFrame)
            self.rowTitle = rowTitle
            self.addSubview(rowTitle)
            if let stemName = delegate.getNameFor(stemNumber: number) {
                rowTitle.stringValue = stemName
            }
            self.number = number
            rowTitle.target = self
            rowTitle.action = #selector(rowTitleChanged)
        }
        //Channels
        x = rowTitleWidth + includeCheckboxWidth
        let numChannels = delegate.numChannels
        for i in 0..<numChannels{
            let checkboxFrame = CGRect(x: x, y: 0, width: columnWidth, height: rowHeight)
            guard let id = delegate.getIdFor(channel: i) else { continue }
            let checkboxCell = StemCell(frame: checkboxFrame, rowType: type, columnType: .channel, delegate: self, id: id)
            self.addSubview(checkboxCell)
            x += columnWidth
        }
        //File Types
        let fileFormats = delegate.audioFormats
        for i in 0..<fileFormats.count{
            let fileFormat = fileFormats[i]
            let formatName = fileFormat.name
            let frame = CGRect(x: x, y: 0, width: columnWidth, height: rowHeight)
            let filetypeCell = StemCell(frame: frame, rowType: type, columnType: .fileType, delegate: self, id: fileFormat.id)
            filetypeCell.backgroundColor = NSColor.lightGray
            if type == .header {
                filetypeCell.stringValue = formatName
            }
            self.addSubview(filetypeCell)
            x += columnWidth
        }
        if type == .row{
            //Delete Button
            let deleteButton = NSButton(title: "X", target: self, action: #selector(deleteStem))
            let deleteFrame = CGRect(x: x, y: 0, width: deleteButtonWidth, height: rowHeight) 
            deleteButton.frame = deleteFrame
            addSubview(deleteButton)
            //Progress Bar
            x += deleteButtonWidth
            let progressFrame = CGRect(x: x, y: 0, width: progressBarWidth, height: rowHeight) 
            let progressBar = NSProgressIndicator(frame: progressFrame)
            progressBar.minValue = 0
            progressBar.maxValue = 1.0
            progressBar.doubleValue = 0
            progressBar.isIndeterminate = false
            progressBar.isHidden = true
            self.addSubview(progressBar)
            self.progressBar = progressBar
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
        delegate?.refresh()
    }
    public func set(progress: Double){
        progressBar.isHidden = false
        progressBar.doubleValue = progress
        progressBar.needsDisplay = true
    }
    @objc func includeDidChange(){
        let state = includeCheckbox.state
        let selected = (state == .on)
        delegate.stemIncludedDidChangeTo(include: selected, stemNumber: number)
    }
}

extension StemRowView : StemCheckboxDelegate{
    public func getNameFor(channelId : String) -> String?{
        let name = delegate.getNameFor(channelId: channelId)
        return name
    }
    public func selectionChangedTo(selected: Bool, id: String, type: ColumnType) {
        delegate.selectionChangedTo(selected: selected, stemNumber: number, id: id, type: type)
    }
    public func isSelected(id: String, type: ColumnType) -> Bool{
        let selected = delegate.isSelected(stemNumber: number, id: id, type: type)
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
    public func didSelect(audioFormatId: String) {
        delegate.didSelect(audioFormatId: audioFormatId)
    }
}

enum RowType {
    case header
    case row
}

public enum ColumnType {
    case title
    case channel
    case fileType
}
