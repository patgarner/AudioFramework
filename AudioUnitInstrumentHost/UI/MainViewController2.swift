//
//  MainViewController.swift
//  AudioUnitInstrumentHost
//
//  Created by acb on 07/12/2017.
//  Copyright © 2017 acb. All rights reserved.
//

import Cocoa
import AVFoundation
import CoreAudioKit

public class MainViewController2: NSViewController {
    @IBOutlet weak var instrumentNameLabel: NSTextField!
    @IBOutlet weak var instrumentsOutlineView: NSOutlineView!
    private var audioService = AudioService.shared 
    private let segueOpenInstrument = NSStoryboardSegue.Identifier("OpenInstrumentView")
    private var instrumentWindowController: NSWindowController?    
    public override func viewWillAppear() {
        print("Main View Controller 2 view will appear")
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Instruments"
        self.reloadInstruments()
        if SamplerModel.shared.instrumentInterfaceInstance != nil{
            loadVC()
        }
    }
    var instrumentsByManufacturer: [(String, [AVAudioUnitComponent])] = []
    var availableInstruments = [AVAudioUnitComponent]() {
        didSet {
            var d: [String:[AVAudioUnitComponent]] = [:]
            for inst in self.availableInstruments {
                var a = d[inst.manufacturerName] ?? []
                a.append(inst)
                d[inst.manufacturerName] = a
            }
            self.instrumentsByManufacturer = d.keys.sorted().map { ($0, d[$0]!)}
            DispatchQueue.main.async { [weak self] in
                self?.instrumentsOutlineView.reloadData()
            }
        }
    }
    private func reloadInstruments() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let s = self else { return }
            s.availableInstruments = s.audioService.getListOfInstruments()
        }
    }
    
    fileprivate func selectInstrument(_ inst: AVAudioUnitComponent) {
        self.audioService.loadInstrument(fromDescription: inst.audioComponentDescription) { [weak self] (successful) in
            
            DispatchQueue.main.async {
                self?.instrumentNameLabel?.stringValue = inst.name
                self?.instrumentWindowController?.close()
                self?.audioService.requestInstrumentInterface{ (maybeInterface) in
                    guard let interface = maybeInterface else { return }
                    SamplerModel.shared.instrumentInterfaceInstance = interface
                    DispatchQueue.main.async {                        
                        [weak self] in guard let this = self else { return }
                        self?.loadVC()
                    }
                }
            }
        }
    }
    
    func loadVCBak(){
        guard let interfaceInstance = SamplerModel.shared.instrumentInterfaceInstance  else { return }
        switch(interfaceInstance) {            
        case .view(let view):
            let bundle = Bundle.init(for: InstrumentViewController.self)
            let vc = InstrumentViewController(nibName: .init(stringLiteral: "InstrumentViewController"), bundle: bundle)
            self.presentAsModalWindow(vc)
            vc.view = view
        case .viewController(let vc):
            self.presentAsModalWindow(vc)
        }
    }

    func loadVC(){
        let contentRect = NSMakeRect(100, 100, 1000, 1000)
        let window = NSWindow(contentRect: contentRect, styleMask: NSWindow.StyleMask.resizable, backing: NSWindow.BackingStoreType.buffered, defer: false)
        window.styleMask.insert(.titled)
        window.styleMask.insert(.closable)

        instrumentWindowController = NSWindowController(window: window)
        guard let interfaceInstance = SamplerModel.shared.instrumentInterfaceInstance  else { return }
        switch(interfaceInstance) {            
        case .view(let view):
            guard let window = instrumentWindowController!.window else { break }
            let frame = window.frameRect(forContentRect: view.bounds)
            print("Frame: \(frame)")
            window.setFrame(frame, display: true)
            window.contentView = view
        case .viewController(let vc):
            instrumentWindowController!.contentViewController = vc
        }
        instrumentWindowController!.showWindow(self)
    }
    

    // Keyboard handling
    
    enum KeyAction {
        case note(offset: UInt8)
        case octaveDown
        case octaveUp
        case velocityDown
        case velocityUp
    }
    
    // macOS key code -> action to take
    let actionForKey: [UInt16:KeyAction] = {
        let noteKeyCodes: [UInt16] = [0,13,1,14,2,3,17,5,16,4,32,38,34,40,31,37] // AWSEDFTGYHUJKOL
        let noteKeys = noteKeyCodes.enumerated().map { (index,element) in (element, KeyAction.note(offset:UInt8(index)))}
        return Dictionary(uniqueKeysWithValues:noteKeys + [ (6, .octaveDown), (7, .octaveUp), (8, .velocityDown), (9, .velocityUp) ])
    }()
    
    
    var octaveOffset: UInt8 = 48
    var velocity: UInt8 = 96
    
    override public func keyDown(with event: NSEvent) {
        guard let action = self.actionForKey[event.keyCode] else { return }
        switch(action) {
        case .note(let offset):
            let note = self.octaveOffset+offset
            if note < 128 {
                self.audioService.noteOn(note, withVelocity: min(127,self.velocity), channel: 0)
            }
        case .octaveDown: self.octaveOffset = max(self.octaveOffset-12, 0)
        case .octaveUp:   self.octaveOffset = min(self.octaveOffset+12, 120)
        case .velocityDown: self.velocity = max(self.velocity-16, 0)
        case .velocityUp:   self.velocity = min(self.velocity-16, 128) // 128 maps to 127 when emitted
        }
    }
    
    override public func keyUp(with event: NSEvent) {
        guard let action = self.actionForKey[event.keyCode] else { return }
        if case .note(let offset) = action {
            let note = self.octaveOffset+offset
            if note < 128 {
                self.audioService.noteOff(note, channel: 0)
            }
        }
    }
    
}

extension MainViewController2: NSOutlineViewDataSource {
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let index = item as? Int {
            return self.instrumentsByManufacturer[index].1.count
        } else {
            return self.instrumentsByManufacturer.count
        }
    }
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let ii = item as? Int {
            return self.instrumentsByManufacturer[ii].1[index]
        } else {
            return index
        }
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item as? Int != nil
    }
}

extension MainViewController2: NSOutlineViewDelegate {
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        
        if let i = item as? Int {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ManufacturerCell"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = self.instrumentsByManufacturer[i].0
            }
        } else if let component = item as? AVAudioUnitComponent {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ComponentCell"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = component.name
            }
        }
        return view
    }
    
    public func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { return }
        if let inst = outlineView.item(atRow: outlineView.selectedRow) as? AVAudioUnitComponent {
            self.selectInstrument(inst)
        }
    }
}
