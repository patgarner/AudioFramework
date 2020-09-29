//
//  StemCreatorViewController2.swift
//  AudioFramework
//
//  Created by Admin on 9/24/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Cocoa

public class StemCreatorViewController2: NSViewController, StemRowViewDelegate {
    public var delegate : StemViewDelegate!
    @IBOutlet weak var collectionView: NSCollectionView!
    let rowTitleWidth : CGFloat = 100
    let columnTitleHeight  : CGFloat = 100
    let rowHeight : CGFloat = 30
    let columnWidth: CGFloat = 30
    weak var namePrefixField : NSTextField!
    public init(delegate: StemViewDelegate){
        self.delegate = delegate
        let bundle = Bundle(for: StemCreatorViewController2.self)
        super.init(nibName: nil, bundle: bundle)
        initialize()
    }
    public override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override public func viewWillLayout() {
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    func initialize(){
        let numStems = delegate.numStems
        let numChannels = delegate.numChannels
        let totalWidth = rowTitleWidth + CGFloat(numChannels + 2) * columnWidth
        let headerY = self.view.frame.size.height - columnTitleHeight
        let headerFrame = CGRect(x: 0, y: headerY, width: totalWidth, height: columnTitleHeight)
        let header = StemRowView(frame: headerFrame, rowTitleWidth: rowTitleWidth, rowHeight: columnTitleHeight, columnWidth: columnWidth, delegate: delegate, type: .header)
        self.view.addSubview(header)
        for i in 0..<numStems{
            let y = self.view.frame.size.height - columnTitleHeight - CGFloat(i+1) * rowHeight
            let rowFrame = CGRect(x: 0, y: y, width: totalWidth, height: rowHeight)
            let stemRowView = StemRowView(frame: rowFrame, rowTitleWidth: rowTitleWidth, rowHeight: rowHeight, columnWidth: columnWidth, delegate: delegate, type: .row, number: i)
            stemRowView.stemRowViewDelegate = self
            self.view.addSubview(stemRowView)
        }
        let buttonHeight : CGFloat = 25
        let yBuffer : CGFloat = 3
        let addStemButtonFrame = CGRect(x: 0, y: yBuffer, width: 100, height: buttonHeight)
        let addStemButton = NSButton(title: "Add Stem", target: self, action: #selector(addStem))
        addStemButton.frame = addStemButtonFrame
        self.view.addSubview(addStemButton)
        
        let prefixLabelFrame = CGRect(x: 110, y: 0, width: 100, height: buttonHeight)
        let prefixLabel = NSTextField(frame: prefixLabelFrame)
        prefixLabel.stringValue = "Name Prefix"
        prefixLabel.isEditable = false
        prefixLabel.backgroundColor = NSColor.clear
        prefixLabel.isEditable = false
        prefixLabel.isBordered = false
        prefixLabel.alignment = NSTextAlignment.right
        prefixLabel.font = NSFont(name: "Helvetica", size: 16)
        self.view.addSubview(prefixLabel)
        
        let namePrefixFrame = CGRect(x: 220, y: yBuffer, width: 200, height: buttonHeight)
        let namePrefixField = NSTextField(frame: namePrefixFrame)
        self.namePrefixField = namePrefixField
        namePrefixField.stringValue = delegate.namePrefix
        namePrefixField.target = self
        namePrefixField.action = #selector(namePrefixChanged)
        self.view.addSubview(namePrefixField)
        
        let exportButtonFrame = CGRect(x: 500, y: yBuffer, width: 100, height: buttonHeight)
        let exportButton = NSButton(title: "Export", target: self, action: #selector(export))
        exportButton.frame = exportButtonFrame
        self.view.addSubview(exportButton)
    }
    @objc func addStem(){
        delegate.addStem()
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        initialize()
    }
    public func refresh() {
        for subview in view.subviews{
            subview.removeFromSuperview()
        }
        initialize()
    }
    @objc private func export(){
        delegate.export()
    }
    @objc private func namePrefixChanged(){
        let namePrefix = namePrefixField.stringValue
        delegate.namePrefix = namePrefix
    }
}
