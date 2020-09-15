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

public class MixerViewController: NSViewController, ChannelViewDelegate, NSCollectionViewDataSource {
    @IBOutlet weak var channelCollectionView: NSCollectionView!
    private var instrumentWindowController: NSWindowController?    
    public var delegate : ChannelViewDelegate?
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func updateViewConstraints() {
        super.updateViewConstraints()
    }
    public func refresh(){
        channelCollectionView.reloadData()
    }
    public func getChannelState(_ index: Int, type: ChannelType) -> ChannelState? {
        delegate?.getChannelState(index, type: type)
    }
    public func set(channelState: ChannelState, index: Int){
        delegate?.set(channelState: channelState, index: index)
    }
    public func set(volume: Int, channel: Int) {
        AudioService.shared.set(volume: UInt8(volume), channel: UInt8(channel))
    }
    func loadVC(){
        let contentRect = NSMakeRect(100, 100, 1000, 1000)
        let styles = NSWindow.StyleMask.resizable.rawValue | NSWindow.StyleMask.titled.rawValue | NSWindow.StyleMask.closable.rawValue
        let styleMask = NSWindow.StyleMask.init(rawValue: styles)
        let window = NSWindow(contentRect: contentRect, styleMask: styleMask, backing: NSWindow.BackingStoreType.buffered, defer: false)
        instrumentWindowController = NSWindowController(window: window)
        guard let interfaceInstance = PluginInterfaceModel.shared.pluginInterfaceInstance  else { return }
        switch(interfaceInstance) {            
        case .view(let view):
            guard let window = instrumentWindowController!.window else { break }
            let frame = window.frameRect(forContentRect: view.bounds)
            window.setFrame(frame, display: true)
            window.contentView = view
        case .viewController(let vc):
            instrumentWindowController!.contentViewController = vc
        }
        instrumentWindowController!.showWindow(self)
    }
    ///////////////////////////////////////////////////
    // CollectionViewDataSource
    ///////////////////////////////////////////////////
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 3
    }
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 1
        } else if section == 1{
            return 2
        } else if section == 2{
            return 1
        }
        return 0
    }
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let bundle = Bundle(for: ChannelCollectionViewItem.self)
        if indexPath[0] == 0{
            let channelView = ChannelCollectionViewItem(nibName: nil, bundle: bundle)
            channelView.type = .labels
            return channelView
        }
        let channelView = ChannelCollectionViewItem(nibName: nil, bundle: bundle)
        channelView.delegate = self
        let trackNumber = indexPath[1]
        channelView.trackNumber = trackNumber
        channelView.pluginSelectionDelegate = self
        if indexPath[0] == 2{
            channelView.type = .master
        }
        return channelView
    }
}

extension MixerViewController : PluginSelectionDelegate{ 
    func getListOfInstruments() -> [AVAudioUnitComponent] {
        let instruments = AudioService.shared.getListOfInstruments()
        return instruments
    }
    public func setMasterVolume(_ volume: Float) {
        AudioService.shared.engine.mainMixerNode.outputVolume = volume
    }
    func selectInstrument(_ inst: AVAudioUnitComponent, channel : Int = 0, type: ChannelType) { //TODO: This absolutely should NOT be here.
        AudioService.shared.loadInstrument(fromDescription: inst.audioComponentDescription, channel: channel) { [weak self] (successful) in
            self?.displayInstrumentInterface(channel: channel)
        }
    }
    func displayInstrumentInterface(channel: Int) {
        DispatchQueue.main.async {
            AudioService.shared.requestInstrumentInterface(channel: channel){ (maybeInterface) in
                guard let interface = maybeInterface else { return }
                PluginInterfaceModel.shared.pluginInterfaceInstance = interface
                DispatchQueue.main.async {                        
                    [weak self] in guard let _ = self else { return }
                    self?.loadVC()
                }
            }
        }
    }
    func select(effect: AVAudioUnitComponent, channel: Int, number: Int, type: ChannelType) { 
        AudioService.shared.loadEffect(fromDescription: effect.audioComponentDescription, channel: channel, number: number, type: type) { [weak self] (successful) in
            self?.displayEffectInterface(channel: channel, number: number, type: type)
        }
    }
    func getPluginSelection(channel: Int, channelType: ChannelType, pluginType: PluginType, pluginNumber: Int) -> PluginSelection? {
        let pluginSelection = AudioService.shared.getPluginSelection(channel: channel, channelType: channelType, pluginType: pluginType, pluginNumber: pluginNumber)
        return pluginSelection
    }
    func deselectEffect(channel: Int, number: Int, type: ChannelType) {
        AudioService.shared.deselectEffect(channel: channel, number: number, type: type)
    }
    func displayEffectInterface(channel: Int, number: Int, type: ChannelType){
        DispatchQueue.main.async {
            guard let audioEffect = AudioService.shared.getAudioEffect(channel: channel, number: number, type: type) else { return }
            let view = loadViewForAudioUnit(audioEffect.audioUnit, CGSize(width: 0, height: 0))
            let interfaceInstance = view.map(InterfaceInstance.view)
            PluginInterfaceModel.shared.pluginInterfaceInstance = interfaceInstance
            DispatchQueue.main.async {                        
                [weak self] in guard let _ = self else { return }
                self?.loadVC()
            }           
        }
    }
    
}
