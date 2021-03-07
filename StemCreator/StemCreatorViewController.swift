//
//  StemCreatorViewController2.swift
//  AudioFramework
//
//  Created by Admin on 9/24/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Cocoa

public class StemCreatorViewController: NSViewController, NSTextFieldDelegate {
    public static var shared = StemCreatorViewController()
    public var delegate : StemViewDelegate? = nil
    @IBOutlet weak var collectionView: NSCollectionView!
    private let rowTitleWidth : CGFloat = 100
    private let columnTitleHeight  : CGFloat = 100
    private let rowHeight : CGFloat = 30
    private let columnWidth: CGFloat = 30
    private weak var namePrefixField : NSTextField!
    private weak var stemCreatorModel : StemCreatorModel! = AudioController.shared.stemCreatorModel
    private let stemCreator = StemCreator()
    private weak var exportCancelButton : NSButton!
    private weak var tailField : NSTextField!

    public init(){
        let bundle = Bundle(for: StemCreatorViewController.self)
        super.init(nibName: nil, bundle: bundle)
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
    public func presentAsModalWindowWithDelegate(_ delegate: StemViewDelegate) {
        self.delegate = delegate
        initialize()
        NSApp.mainWindow?.contentViewController?.presentAsModalWindow(self)
    }
    public func initialize(){
        guard let delegate = delegate else { 
            return
        }
        self.title = "Export Stems"
        stemCreator.delegate = self
        let numStems = stemCreatorModel.numStems
        let numChannels = delegate.numChannels
        let totalWidth = rowTitleWidth + CGFloat(numChannels + 2) * columnWidth + 300
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

        //Add Stem Buttons
        let y = view.frame.size.height - columnTitleHeight - CGFloat(numStems+1) * rowHeight
        let addStemButtonWidth : CGFloat = 100
        let addStemButtonFrame = CGRect(x: 25, y: y, width: addStemButtonWidth, height: buttonHeight)
        let addStemButton = NSButton(title: "Add Stem", target: self, action: #selector(addStem))
        addStemButton.frame = addStemButtonFrame
        self.view.addSubview(addStemButton)

        
        let yBuffer : CGFloat = 3
        let buttonSeparator : CGFloat = 10
        let font = NSFont(name: "Helvetica", size: 15)
        
        ////////////////////////////////////////////////////////////////////////
        //Prefix Label
        ////////////////////////////////////////////////////////////////////////
        let prefixLabelWidth : CGFloat = 100
        let prefixLabelFrame = CGRect(x: 0, y: 0, width: prefixLabelWidth, height: buttonHeight)
        let prefixLabel = NSTextField(frame: prefixLabelFrame)
        prefixLabel.stringValue = "Name Prefix"
        prefixLabel.isEditable = false
        prefixLabel.backgroundColor = NSColor.clear
        prefixLabel.isEditable = false
        prefixLabel.isBordered = false
        prefixLabel.alignment = NSTextAlignment.right
        prefixLabel.font = font
        
        //Prefix Field
        let prefixFieldWidth : CGFloat = 100
        let namePrefixFrame = CGRect(x: prefixLabelWidth + buttonSeparator, y: yBuffer, width: 100, height: buttonHeight)
        let namePrefixField = NSTextField(frame: namePrefixFrame)
        self.namePrefixField = namePrefixField
        namePrefixField.stringValue = stemCreatorModel.namePrefix
        namePrefixField.target = self
        namePrefixField.action = #selector(namePrefixChanged)
        namePrefixField.delegate = self
           
        //Name Prefix View
        let namePrefixViewFrame = CGRect(x: 0, y: 0, width: prefixLabelWidth + prefixFieldWidth + buttonSeparator, height: buttonHeight)
        let prefixView = NSView(frame: namePrefixViewFrame)
        prefixView.addSubview(prefixLabel)
        prefixView.addSubview(namePrefixField)
        self.view.addSubview(prefixView)
        
        //Tail Label
        let tailLabel = NSTextField(labelWithString: "Tail")
        let tailLabelWidth : CGFloat = 50
        let tailLabelFrame = CGRect(x: 0, y: 0, width: tailLabelWidth, height: buttonHeight)
        tailLabel.frame = tailLabelFrame
        tailLabel.isEditable = false
        tailLabel.backgroundColor = NSColor.clear
        tailLabel.isEditable = false
        tailLabel.isBordered = false
        tailLabel.alignment = NSTextAlignment.right
        tailLabel.font = font
        
        //Tail Field
        let tailField = NSTextField()
        tailField.doubleValue = stemCreatorModel.tailLength
        let tailFieldWidth : CGFloat = 50
        let tailFieldFrame = CGRect(x: tailLabelWidth + buttonSeparator, y: yBuffer, width: tailLabelWidth, height: buttonHeight)
        tailField.frame = tailFieldFrame
        self.tailField = tailField
        tailField.target = self
        tailField.action = #selector(tailLengthChanged)
        tailField.delegate = self
        let tailNumberFormatter = NumberFormatter()
        tailNumberFormatter.allowsFloats = true
        tailNumberFormatter.generatesDecimalNumbers = true
        tailNumberFormatter.maximumFractionDigits = 2
        tailNumberFormatter.minimumFractionDigits = 1
        tailField.formatter = tailNumberFormatter
        
        //Tail View
        let tailViewFrame = CGRect(x: 225, y: 0, width: tailLabelWidth + buttonSeparator + tailFieldWidth, height: buttonHeight)
        let tailView = NSView(frame: tailViewFrame)
        tailView.addSubview(tailLabel)
        tailView.addSubview(tailField)
        view.addSubview(tailView)
        
        //Export Button
        let exportButtonFrame = CGRect(x: 390, y: 0, width: 100, height: buttonHeight)
        let exportButton = NSButton(title: "Export", target: self, action: #selector(didClickExportCancelButton))
        exportButton.frame = exportButtonFrame
        self.exportCancelButton = exportButton
        view.addSubview(exportButton)
                
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setProgress),
            name: .StemProgress,
            object: nil)
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
    @objc private func tailLengthChanged(){
        let tailLength = tailField.doubleValue
        stemCreatorModel.tailLength = tailLength
    }
    @objc func didClickExportCancelButton(_ sender: Any){ 
        let buttonTitle = exportCancelButton.title
        if buttonTitle == "Export" { export() }
        if buttonTitle == "Cancel" { cancel() }
    }  
    private func export(){
        let savePanel = NSOpenPanel()
        savePanel.canCreateDirectories = true
        savePanel.canChooseFiles = false
        savePanel.canChooseDirectories = true
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
        delegate?.cancelStemExport()
    }
    func exportStems(destinationFolder: URL){ 
        exportCancelButton.title = "Cancel"
        createReadme(destinationFolder: destinationFolder)
        delegate?.prepareForStemExport(destinationFolder: destinationFolder)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            self.stemCreator.createStems(model: self.stemCreatorModel, folder: destinationFolder)
            self.delegate?.stemExportComplete()
            DispatchQueue.main.async {
                self.view.window?.close()
            }
        }
    }
    func createReadme(destinationFolder: URL){ 
        let fileURL = destinationFolder.appendingPathComponent("README.txt")
        let fileManager = FileManager()
        if let tempo = delegate?.getTempo() {
            let readmeString = "Tempo: \(tempo)"
            let data = readmeString.data(using: .utf8)
            if !fileManager.createFile(atPath: fileURL.path, contents: data, attributes: [:]) {
                MessageHandler.log("Failed to create README.txt", displayFormat: [.notification])
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
    public func controlTextDidChange(_ obj: Notification) {
        let object = obj.object
        guard let sender = object as? NSTextField else { return }
        if sender === namePrefixField{
            namePrefixChanged()
        } 
    }
}

extension StemCreatorViewController : StemRowViewDelegate{
    public func set(letter: String, stemNumber: Int) {
        stemCreatorModel.set(letter: letter, stemNumber: stemNumber)
    }
    public func getLetterFor(stemNumber: Int) -> String? {
        let letter = stemCreatorModel.getLetterFor(stem: stemNumber)
        return letter
    }
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
    @objc public func addFormat(){
        let format = AudioFormatFactory.wav44_16
        stemCreatorModel.audioFormats.append(format)
        refresh()
    }
    //Pass Through
    public var numChannels: Int {
        let channels = delegate?.numChannels ?? 0
        return channels
    }
    public func getNameFor(channelId: String) -> String? {
        let name = delegate?.getNameFor(channelId: channelId)
        return name
    }
    public func getIdFor(channel: Int) -> String? {
        let id = delegate?.getIdFor(channel: channel)
        return id
    }
    public func stemRowValueChanged(gestureRect: CGRect, buttonType: DraggableButtonType, newState: Bool/*NSControl.StateValue*/) {
        view.subviews.forEach { subview in
            guard let stemRowView = subview as? StemRowView else { return }
            stemRowView.didReceiveStemRowValueChange(gestureRect: gestureRect, buttonType: buttonType, newState: newState)
        }
    }
}


extension StemCreatorViewController : StemCreatorDelegate{
    public func muteAllExcept(channelIds: [String]) {
        delegate?.muteAllExcept(channelIds: channelIds)
    }
    public func exportStem(to url: URL, number: Int, formats: [AudioFormat], headLength: Double, tailLength: Double){
        delegate?.exportStem(to: url, number: number, formats: formats, headLength: headLength, tailLength: tailLength)
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

