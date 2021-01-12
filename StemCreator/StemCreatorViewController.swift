//
//  StemCreatorViewController2.swift
//  AudioFramework
//
//  Created by Admin on 9/24/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Cocoa

public class StemCreatorViewController: NSViewController {
    public var delegate : StemViewDelegate!
    @IBOutlet weak var collectionView: NSCollectionView!
    private let rowTitleWidth : CGFloat = 100
    private let columnTitleHeight  : CGFloat = 100
    private let rowHeight : CGFloat = 30
    private let columnWidth: CGFloat = 30
    private weak var namePrefixField : NSTextField!
    private weak var stemCreatorModel : StemCreatorModel! = AudioController.shared.stemCreatorModel
    private let stemCreator = StemCreator()
    private weak var exportCancelButton : NSButton!

    public init(delegate: StemViewDelegate){
        self.delegate = delegate
        let bundle = Bundle(for: StemCreatorViewController.self)
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
    }
    func initialize(){
        self.title = "Export Stems"
        stemCreator.delegate = self
        let numStems = stemCreatorModel.numStems
        let numChannels = delegate.numChannels
        let totalWidth = rowTitleWidth + CGFloat(numChannels + 2) * columnWidth + 200
        let currentFrame = self.view.frame
        let newSize = CGSize(width: totalWidth, height: currentFrame.height)
        self.view.setFrameSize(newSize)
        let headerY = self.view.frame.size.height - columnTitleHeight
        let headerFrame = CGRect(x: 0, y: headerY, width: totalWidth, height: columnTitleHeight)
        let header = StemRowView(frame: headerFrame, rowTitleWidth: rowTitleWidth, rowHeight: columnTitleHeight, columnWidth: columnWidth, delegate: self, type: .header)
        self.view.addSubview(header)
        for i in 0..<numStems{
            let y = self.view.frame.size.height - columnTitleHeight - CGFloat(i+1) * rowHeight
            let rowFrame = CGRect(x: 0, y: y, width: totalWidth, height: rowHeight)
            let stemRowView = StemRowView(frame: rowFrame, rowTitleWidth: rowTitleWidth, rowHeight: rowHeight, columnWidth: columnWidth, delegate: self, type: .row, number: i)
            stemRowView.delegate = self
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
        namePrefixField.stringValue = stemCreatorModel.namePrefix//delegate.namePrefix
        namePrefixField.target = self
        namePrefixField.action = #selector(namePrefixChanged)
        self.view.addSubview(namePrefixField)
        
        let addFormatButtonFrame = CGRect(x: 540, y: yBuffer, width: 100, height: buttonHeight)
        let addFormatButton = NSButton(title: "Add Format", target: self, action: #selector(addFormat))
        addFormatButton.frame = addFormatButtonFrame
        self.view.addSubview(addFormatButton)

        let exportButtonFrame = CGRect(x: 650, y: yBuffer, width: 100, height: buttonHeight)
        let exportButton = NSButton(title: "Export", target: self, action: #selector(didClickExportCancelButton))
        exportButton.frame = exportButtonFrame
        self.view.addSubview(exportButton)
        self.exportCancelButton = exportButton
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setProgress),
            name: .StemProgress,
            object: nil)
    }
    @objc func addFormat(){
        let format = AudioFormatFactory.wav44_16
        stemCreatorModel.audioFormats.append(format)
        refresh()
    }
    @objc func setProgress(notification: NSNotification){
        guard let stemProgress = notification.object as? (Int, Double) else { return }
        DispatchQueue.main.async {
            let subviews = self.view.subviews
            let desiredSubviewIndex = stemProgress.0 + 1
            if subviews.count <= desiredSubviewIndex { return }
            if let rowView = subviews[desiredSubviewIndex] as? StemRowView {
                rowView.set(progress: stemProgress.1)
            }
        }
    }
    @objc func addStem(){
        stemCreatorModel.addStem()
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
    @objc private func namePrefixChanged(){
        let namePrefix = namePrefixField.stringValue
        stemCreatorModel.namePrefix = namePrefix
    }
    @objc func didClickExportCancelButton(_ sender: Any){ 
        let buttonTitle = exportCancelButton.title
        if buttonTitle == "Export" { export() }
        if buttonTitle == "Cancel" { cancel() }
    }  
    private func export(){
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.title = "Choose Destination Folder"
        guard let window = NSApp.keyWindow else { return }
        savePanel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                guard let url = savePanel.url else { return }
                self.exportStems(destinationFolder: url)
            } else {
                print("Problem exporting stems.")
            }
        }
    }
    private func cancel(){
        stemCreator.cancelStemExport()
        delegate.cancelStemExport()
    }
    func exportStems(destinationFolder: URL){ 
        exportCancelButton.title = "Cancel"
        delegate.prepareForStemExport(destinationFolder: destinationFolder)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            self.stemCreator.createStems(model: self.stemCreatorModel, folder: destinationFolder)
            self.delegate.stemExportComplete()
            DispatchQueue.main.async {
                self.view.window?.close()
            }
        }
    }
    @objc func stemExportComplete(notification: NSNotification){
        exportCancelButton.title = "Export"
        DispatchQueue.main.async {
            self.view.window?.close()
        }
    }
    public func isSelected(stemNumber: Int, id: String, type: ColumnType) -> Bool {
        let selected = stemCreatorModel.isSelected(stemNumber: stemNumber, id: id, type: type)
        return selected
    }
}

extension StemCreatorViewController : StemRowViewDelegate{
    public func getNameFor(stemNumber: Int) -> String? {
        let name = stemCreatorModel.getNameFor(stem: stemNumber)
        return name
    }
    public func setName(stemNumber: Int, name: String){
        stemCreatorModel.setName(stemNumber: stemNumber, name: name)
    }
    public var numStems: Int {
        let stems = stemCreatorModel.numStems
        return stems
    }
    public func getNameFor(stem: Int) -> String?{
        let name = stemCreatorModel.getNameFor(stem: stem)
        return name
    }
    public func selectionChangedTo(selected: Bool, stemNumber: Int, id: String, type: ColumnType) {
        stemCreatorModel.selectionChangedTo(selected: selected, stemNumber: stemNumber, id: id, type: type)
    }
    public func delete(stemNumber: Int){
        stemCreatorModel.delete(stemNumber: stemNumber)
    }
    public func stemIncludedDidChangeTo(include: Bool, stemNumber: Int) {
        stemCreatorModel.stemIncludedDidChangeTo(include: include, stemNumber: stemNumber) 
    }
    public func isIncluded(stemNumber: Int) -> Bool {
        let include = stemCreatorModel.isIncluded(stemNumber: stemNumber)
        return include
    }
    public var audioFormats: [AudioFormat] {
        get {
            return stemCreatorModel.audioFormats
        }
    }
    public func didSelect(audioFormatId: String) {
        guard let audioFormat = stemCreatorModel.getFormatWith(id: audioFormatId) else { return }
        let audioFormatVC = AudioFormatViewController(nibName: nil, bundle: nil)
        presentAsModalWindow(audioFormatVC)
        audioFormatVC.set(audioFormat: audioFormat)
        audioFormatVC.delegate = self
    }
    //Pass Through
    public var numChannels: Int {
        let channels = delegate.numChannels
        return channels
    }
    public func getNameFor(channelId: String) -> String? {
        let name = delegate.getNameFor(channelId: channelId)
        return name
    }
    public func getIdFor(channel: Int) -> String? {
        let id = delegate.getIdFor(channel: channel)
        return id
    } 
}


extension StemCreatorViewController : StemCreatorDelegate{
    public func muteAllExcept(channelIds: [String]) {
        delegate.muteAllExcept(channelIds: channelIds)
    }
    public func exportStem(to url: URL, includeMP3: Bool, number: Int, sampleRate: Int) {
        delegate.exportStem(to: url, includeMP3: includeMP3, number: number, sampleRate: sampleRate)
    }
    public func exportStem(to url: URL, number: Int, formats: [AudioFormat]){
        delegate.exportStem(to: url, number: number, formats: formats)
    }
}

extension StemCreatorViewController : AudioFormatViewControllerDelegate{
    func deleteAudioFormatWith(id: String) {
        stemCreatorModel.deleteAudioFormatWith(id: id)
        refresh()
    }
    
    func updateValuesFor(audioFormatId: String, newAudioFormat: AudioFormat) {
        stemCreatorModel.updateValuesFor(audioFormatId: audioFormatId, newAudioFormat: newAudioFormat)
        refresh()
    }
}

