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

public class MixerViewController: NSViewController {
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
}

extension MixerViewController : NSCollectionViewDataSource{
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 4
    }
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{ //Label
            return 1
        } else if section == 1{ //Instrument Channels
            return numChannels(type: .midiInstrument)
        } else if section == 1{ //Aux Channels
            return numChannels(type: .aux)
        } else if section == 3{ //Master Channel
            return 1
        }
        return 0
    }
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let bundle = Bundle(for: ChannelCollectionViewItem.self)
        let channelView = ChannelCollectionViewItem(nibName: nil, bundle: bundle)
        channelView.delegate = self
        let channelNumber = indexPath[1]
        channelView.channelNumber = channelNumber
        channelView.pluginSelectionDelegate = self
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
            channelView.channelViewDelegate2 = channelController
        }
        return channelView
    }
}

extension MixerViewController : ChannelViewDelegate{
    public func getChannelState(_ index: Int, type: ChannelType) -> ChannelModel? {
        delegate?.getChannelState(index, type: type)
    }
    public func set(channelState: ChannelModel, index: Int){
        delegate?.set(channelState: channelState, index: index)
    }

    public func numChannels(type: ChannelType) -> Int{
        if let numChannels = delegate?.numChannels(type: type){
            return numChannels
        } else {
            return 0
        }
    }
//    public func set(volume: Float, channel: Int, channelType: ChannelType) {
//        AudioController.shared.set(volume: volume, channel: channel, channelType: channelType)
//    }
//    public func getVolume(channel: Int, channelType: ChannelType) -> Float {
//        let volume = AudioController.shared.getVolume(channel: channel, channelType: channelType)
//        return volume
//    }
//    public func getPan(channel: Int, channelType: ChannelType) -> Float {
//        let pan = AudioController.shared.getPan(channel: channel, channelType: channelType)
//        return pan
//    }
//    public func set(pan: Float, channel: Int, channelType: ChannelType) {
//        AudioController.shared.set(pan: pan, channel: channel, channelType: channelType)
//    }
}

extension MixerViewController : PluginSelectionDelegate{
    func selectInstrument(_ inst: AVAudioUnitComponent, channel : Int = 0, type: ChannelType) { //TODO: This absolutely should NOT be here.
        AudioController.shared.loadInstrument(fromDescription: inst.audioComponentDescription, channel: channel) { [weak self] (successful) in
            self?.displayInstrumentInterface(channel: channel)
        }
    }
    func displayInstrumentInterface(channel: Int) {
        DispatchQueue.main.async {
            AudioController.shared.requestInstrumentInterface(channel: channel){ (maybeInterface) in
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
        AudioController.shared.loadEffect(fromDescription: effect.audioComponentDescription, channel: channel, number: number, type: type) { [weak self] (successful) in
            self?.displayEffectInterface(channel: channel, number: number, type: type)
        }
    }
    func displayEffectInterface(channel: Int, number: Int, type: ChannelType){
        DispatchQueue.main.async {
            guard let audioEffect = AudioController.shared.getAudioEffect(channel: channel, number: number, type: type) else { return }
            let view = loadViewForAudioUnit(audioEffect.audioUnit, CGSize(width: 0, height: 0))
            let interfaceInstance = view.map(InterfaceInstance.view)
            PluginInterfaceModel.shared.pluginInterfaceInstance = interfaceInstance
            DispatchQueue.main.async {                        
                [weak self] in guard let _ = self else { return }
                self?.loadVC()
            }           
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    //TODO: Pass through functions. These just get infro from the AudioController.
    //////////////////////////////////////////////////////////////////////////////////////
    func getSendData(sendNumber: Int, channel: Int, channelType: ChannelType) -> SendData? {
        let sendData = AudioController.shared.getSendData(sendNumber: sendNumber, channel: channel, channelType: channelType)
        return sendData
    }
    func select(sendNumber: Int, busNumber: Int, channel: Int, channelType: ChannelType){
        AudioController.shared.select(sendNumber: sendNumber, busNumber: busNumber, channel: channel, channelType: channelType)
    }
    func numBusses() -> Int{
        let busses = AudioController.shared.numBusses()
        return busses
    }
    func selectInput(busNumber: Int, channel: Int, channelType: ChannelType) {
        AudioController.shared.selectInput(busNumber: busNumber, channel: channel, channelType: channelType)
    }
    func setSend(volume: Float, sendNumber: Int, channelNumber: Int, channelType: ChannelType) {
        AudioController.shared.setSend(volume: volume, sendNumber: sendNumber, channelNumber: channelNumber, channelType: channelType)
    }
    func getSendOutput(sendNumber: Int, channelNumber: Int, channelType: ChannelType) -> Int? {
        let sendOutput = AudioController.shared.getSendOutput(sendNumber: sendNumber, channelNumber: channelNumber, channelType: channelType)
        return sendOutput
    }
    func getBusInputNumber(channelNumber: Int, channelType: ChannelType) -> Int?{
        let busOutput = AudioController.shared.getBusInputNumber(channelNumber: channelNumber, channelType: channelType)
        return busOutput
    }
    func getPluginSelection(channel: Int, channelType: ChannelType, pluginType: PluginType, pluginNumber: Int) -> PluginSelection? {
        let pluginSelection = AudioController.shared.getPluginSelection(channel: channel, channelType: channelType, pluginType: pluginType, pluginNumber: pluginNumber)
        return pluginSelection
    }
    func deselectEffect(channel: Int, number: Int, type: ChannelType) {
        AudioController.shared.deselectEffect(channel: channel, number: number, type: type)
    }
    func getListOfInstruments() -> [AVAudioUnitComponent] {
        let instruments = AudioController.shared.getListOfInstruments()
        return instruments
    }
}

