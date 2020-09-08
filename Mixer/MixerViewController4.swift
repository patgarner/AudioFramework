//
//  MixerViewController4.swift
//  Composer Bot Desktop
//
//  Created by Admin on 6/19/19.
//  Copyright © 2019 UltraMusician. All rights reserved.
//
// The MixerViewController is primarily a view controller -- it should not do a lot of heavy lifting, but rather should be relaying messages from the sliders up the chain,
// or, from the mainViewController down the chain, such as setting the state.

import Cocoa
import AVFoundation

public class MixerViewController4: NSViewController, ChannelViewDelegate, NSCollectionViewDataSource {
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
    public func getChannelState(_ index: Int) -> ChannelState? {
        delegate?.getChannelState(index)
    }
    public func set(channelState: ChannelState, index: Int){
        delegate?.set(channelState: channelState, index: index)
    }
    public func set(volume: Int, channel: Int) {
        AudioService.shared.set(volume: UInt8(volume), channel: UInt8(channel))
    }
    
    func selectInstrument(_ inst: AVAudioUnitComponent, channel : Int = 0) { //TODO: This absolutely should NOT be here.
        AudioService.shared.loadInstrument(fromDescription: inst.audioComponentDescription, channel: channel) { [weak self] (successful) in
            guard let self = self else { return }
            self.displayInstrumentInterface(channel: channel)
        }
    }
    func select(effect: AVAudioUnitComponent, channel: Int = 0) {  //TODO: This absolutely should NOT be here.
        AudioService.shared.loadEffect(fromDescription: effect.audioComponentDescription, channel: channel) { [weak self] (successful) in
            guard let self = self else { return }
            self.displayEffectInterface(channel: channel)
        }
    }
    func displayEffectInterface(channel: Int){
        DispatchQueue.main.async {
            guard let audioEffect = AudioService.shared.getAudioEffect(channel: channel, number: 0) else { return }
            let view = loadViewForAudioUnit(audioEffect.audioUnit, CGSize(width: 0, height: 0))
            let interfaceInstance = view.map(InterfaceInstance.view)
            PluginInterfaceModel.shared.pluginInterfaceInstance = interfaceInstance
            DispatchQueue.main.async {                        
                [weak self] in guard let this = self else { return }
                self?.loadVC()
            }           
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
            return 2 //TODO: 16
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
        channelView.instrumentSelectionDelegate = self
        if indexPath[0] == 2{
            channelView.type = .master
        }
        return channelView
    }

}

extension MixerViewController4 : InstrumentSelectionDelegate{
    func getListOfInstruments() -> [AVAudioUnitComponent] {
        let instruments = AudioService.shared.getListOfInstruments()
        return instruments
    }
    public func setMasterVolume(_ volume: Float) {
        AudioService.shared.audioEngine.mainMixerNode.outputVolume = volume
    }

    
}


