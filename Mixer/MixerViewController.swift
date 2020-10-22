//
//  MixerViewController.swift
//
/*
 Copyright 2020 David Mann Music LLC
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Cocoa
import AVFoundation
import CoreAudioKit

public class MixerViewController: NSViewController, KeyDelegate {
    @IBOutlet weak var channelCollectionView: NSCollectionView!
    private var instrumentWindowController: NSWindowController?    
    private var interfaceInstance : InterfaceInstance? = nil
    init(){
        let bundle = Bundle(for: MixerViewController.self)
        super.init(nibName: nil, bundle: bundle)
    }
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as? KeyView{
            view.delegate = self
        }
        AudioController.shared.pluginDisplayDelegate = self
        refresh()
    }
    public override func viewDidAppear() {
        refresh()
    }
    override public func updateViewConstraints() {
        super.updateViewConstraints()
    }
    public func refresh(){
        channelCollectionView.reloadData()
        channelCollectionView.needsLayout = true
        channelCollectionView.needsDisplay = true
    }
    @IBAction func addTrack(_ sender: Any) {
        guard let button = sender as? NSPopUpButton else { return }
        let index = button.indexOfSelectedItem
        if index == 0{
            add(channelType: .midiInstrument)
        } else if index == 1{
            add(channelType: .aux)
        }
    }
    private func add(channelType: ChannelType){
        AudioController.shared.add(channelType: channelType)
        channelCollectionView.reloadData()
        channelCollectionView.needsLayout = true
        channelCollectionView.needsDisplay = true
    }
    public func keyDown(_ number: Int) {
        if number == 51 { //Delete
            delete(self)
        } else if number == 48 { //Tab
            visualizeAudioGraph() 
        }
    }
    @IBAction func delete(_ sender: Any) {
        AudioController.shared.deleteSelectedChannels()
        channelCollectionView.reloadData()
    }
    func visualizeAudioGraph(){
        AudioController.shared.visualize()
    }
    
    @IBAction func reconnect(_ sender: Any) {
        AudioController.shared.reconnectSelectedChannels()
    }
}

extension MixerViewController : NSCollectionViewDataSource{
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 4
    }
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{ //Label
            return 1
        } else if section == 1{ //Instrument Channels
            return AudioController.shared.numTracks(channelType: .midiInstrument)
        } else if section == 2{ //Aux Channels
            return AudioController.shared.numTracks(channelType: .aux)
        } else if section == 3{ //Master Channel
            return AudioController.shared.numTracks(channelType: .master)
        }
        return 0
    }
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let bundle = Bundle(for: ChannelCollectionViewItem.self)
        let channelView = ChannelCollectionViewItem(nibName: nil, bundle: bundle)
        let channelNumber = indexPath[1]
        channelView.channelNumber = channelNumber
        if indexPath[0] == 0{
            channelView.type = .labels
        } else if indexPath[0] == 1{
            channelView.type = .midiInstrument
        } else if indexPath[0] == 2{
            channelView.type = .aux
        } else if indexPath[0] == 3{
            channelView.type = .master
        }
        if let channelController = AudioController.shared.getChannelController(type: channelView.type, channel: channelNumber){
            channelView.channelViewDelegate = channelController
            channelController.channelView = channelView
        }
        return channelView
    }
}

extension MixerViewController : PluginDisplayDelegate{
    public func display(viewController: AUViewController) {
        DispatchQueue.main.async {
            let view = viewController.view
            for subview in view.subviews{             //Needed for WAVES plugins
                if let openGLView = subview as? NSOpenGLView {
                    openGLView.wantsBestResolutionOpenGLSurface = false
                }
            }
            //
            let window = NSWindow(contentViewController: viewController)
            window.makeKeyAndOrderFront(nil)    
        }
    }
}

public class KeyView : NSView {
    public var delegate : KeyDelegate? = nil
    override public func keyDown(with event: NSEvent) {
        let keycode = Int(event.keyCode)
        delegate?.keyDown(keycode)
    }
}

public protocol KeyDelegate{
    func keyDown(_ number: Int)
}

public enum InterfaceInstance {
    case view(NSView)
    case viewController(NSViewController)
}
