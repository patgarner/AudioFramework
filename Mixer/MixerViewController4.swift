//
//  MixerViewController4.swift
//  Composer Bot Desktop
//
//  Created by Admin on 6/19/19.
//  Copyright © 2019 UltraMusician. All rights reserved.
//

import Cocoa
import AVFoundation

public class MixerViewController4: NSViewController, ChannelViewDelegate, NSCollectionViewDataSource {
    @IBOutlet weak var channelCollectionView: NSCollectionView!
    
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
    
    func selectInstrument(_ inst: AVAudioUnitComponent, channel : Int = 0) { //TODO: This absolutely should NOT be here.
        AudioService.shared.loadInstrument(fromDescription: inst.audioComponentDescription) { [weak self] (successful) in
            DispatchQueue.main.async {
                AudioService.shared.requestInstrumentInterface{ (maybeInterface) in
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
    func select(effect: AVAudioUnitComponent, channel: Int = 0) {  //TODO: This absolutely should NOT be here.
        AudioService.shared.loadEffect(fromDescription: effect.audioComponentDescription) { [weak self] (successful) in
            DispatchQueue.main.async {
                AudioService.shared.requestInstrumentInterface{ (maybeInterface) in
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
    func loadVC(){
        guard let interfaceInstance = SamplerModel.shared.instrumentInterfaceInstance  else { return }
        switch(interfaceInstance) {
        case .view(let view):
            let vc = InstrumentViewController()
            self.presentAsModalWindow(vc)
            vc.view = view
        case .viewController(let vc):
            self.presentAsModalWindow(vc)
        }
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
            return 16
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


