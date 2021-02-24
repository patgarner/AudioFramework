//
//  StemRow.swift
//  AudioFramework
//
//  Created by Admin on 9/26/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Cocoa

public class StemRowView: NSView, NSTextFieldDelegate {
    private weak var rowTitle : NSTextField!
    var number = -1
    var delegate : StemRowViewDelegate!
    private weak var progressBar : NSProgressIndicator!
    private weak var includeCheckbox : DraggableButton!
    private weak var addFormatButton : NSButton!
    private weak var letterField : NSTextField!
    //Dimensions
    private let includeCheckboxWidth : CGFloat = 25
    private var rowTitleWidth : CGFloat = 75
    private let letterFieldWidth : CGFloat = 25
    private var columnWidth : CGFloat = 25
    private let buttonWidth : CGFloat = 40
    private let progressBarWidth : CGFloat = 100
    init(frame frameRect: NSRect, rowTitleWidth: CGFloat, rowHeight: CGFloat, columnWidth: CGFloat, delegate: StemRowViewDelegate, type: RowType, number: Int = -1) {
        super.init(frame: frameRect)
        let font = NSFont(name: "Helvetica", size: 16)
        self.rowTitleWidth = rowTitleWidth
        self.columnWidth = columnWidth
        self.delegate = delegate
        var x : CGFloat = 0
        if type == .row {
            //Include Checkbox
            let includeCheckboxFrame = CGRect(x: 0, y: 0, width: includeCheckboxWidth, height: rowHeight)
            let includeCheckbox = DraggableButton(checkboxWithTitle: "", target: self, action: #selector(includeDidChange))
            let gestureRecognizer = AFPanGestureRecognizer(target: self, action: #selector(panGestureReceived(sender:)))
            includeCheckbox.addGestureRecognizer(gestureRecognizer)
            includeCheckbox.type = .include
            includeCheckbox.frame = includeCheckboxFrame
            self.addSubview(includeCheckbox)
            self.includeCheckbox = includeCheckbox
            if delegate.isIncluded(stemNumber: number){
                includeCheckbox.state = .on
            }
            x += includeCheckboxWidth
            //Letter Field
            let letterFrame = CGRect(x: x, y: 0, width: letterFieldWidth, height: rowHeight)
            let letterField = NSTextField(frame: letterFrame)
            self.letterField = letterField
            letterField.font = font
            letterField.target = self
            letterField.action = #selector(letterChanged)
            letterField.delegate = self
            addSubview(letterField)
            if let letter = delegate.getLetterFor(stemNumber: number){
                letterField.stringValue = letter
            }
            x += letterFieldWidth
            //Row Title
            let rowTitleFrame = CGRect(x: x, y: 0, width: rowTitleWidth, height: rowHeight)
            let rowTitle = NSTextField(frame: rowTitleFrame)
            rowTitle.font = font
            self.rowTitle = rowTitle
            addSubview(rowTitle)
            if let stemName = delegate.getNameFor(stemNumber: number) {
                rowTitle.stringValue = stemName
            }
            self.number = number
            rowTitle.target = self
            rowTitle.action = #selector(rowTitleChanged)
            rowTitle.delegate = self
            x += rowTitleWidth
            //Tab functionality
            letterField.nextKeyView = rowTitle
        }
        //Channels
        x = includeCheckboxWidth + rowTitleWidth + letterFieldWidth
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
        //Add Format Button
        if type == .header {
            let addFormatHeight : CGFloat = 30
            let addFormatY : CGFloat = (frame.size.height - addFormatHeight) // 2.0
            let addFormatFrame = CGRect(x: x, y: addFormatY, width: buttonWidth, height: addFormatHeight)
            let addFormatButton = NSButton(title: "+", target: self, action: #selector(addFormat))
            addFormatButton.frame = addFormatFrame
            addFormatButton.refusesFirstResponder = true
            self.addSubview(addFormatButton) 
        }
        if type == .row{
            //Delete Button
            let deleteButton = NSButton(title: "X", target: self, action: #selector(deleteStem))
            let deleteFrame = CGRect(x: x, y: 0, width: buttonWidth, height: rowHeight) 
            deleteButton.frame = deleteFrame
            addSubview(deleteButton)
            //Progress Bar
            x += buttonWidth
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
    @objc func letterChanged(){
        let letter = letterField.stringValue
        delegate.set(letter: letter, stemNumber: number)
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
    @objc func addFormat(){
        print("Add format")
        delegate?.addFormat()
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
    public func controlTextDidChange(_ obj: Notification) {
        let object = obj.object
        guard let sender = object as? NSTextField else { return }
        if sender === rowTitle{
            rowTitleChanged(sender: self)
        } else if sender === letterField{
            letterChanged()
        }
    }
}

extension StemRowView { // drag to select
    @objc func panGestureReceived(sender: AFPanGestureRecognizer){
        guard let mainButton = sender.view as? DraggableButton else { return }
        guard let view = mainButton.superview else { return }
        guard let window = mainButton.window else { return }

        let translation = sender.translation(in: view)
        let locationInWin = window.convertPoint(fromScreen: NSEvent.mouseLocation)
        let locationInView = view.convert(locationInWin, from: nil)
        let startingPointX = locationInView.x - translation.x
        let startingPointY = locationInView.y - translation.y

        let startX = min(startingPointX, startingPointX + translation.x)
        let startY = min(startingPointY, startingPointY + translation.y)
        let endX = max(startingPointX, startingPointX + translation.x)
        let endY = max(startingPointY, startingPointY + translation.y)
        var gestureRect = CGRect(x: startX, y: startY, width: endX - startX, height: endY - startY)
        gestureRect = view.convert(gestureRect, to: nil)

        //let state = mainButton.state
        var state = false
        if mainButton.state == .on { state = true }
        
        delegate.stemRowValueChanged(gestureRect: gestureRect, buttonType: mainButton.type, newState: state)
    }
    func didReceiveStemRowValueChange(gestureRect: CGRect, buttonType: DraggableButtonType, newState: Bool/*NSControl.StateValue*/) {
        switch buttonType {
        case .mute:
            break
        case .solo:
            break
        case .include:
            includeCheckbox?.setNewState(newState: newState, for: gestureRect, buttonType: buttonType)
            break
        case .none:
            break
        }
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
