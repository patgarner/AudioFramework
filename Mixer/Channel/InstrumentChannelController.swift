//
//  InstrumentChannelController.swift
//  AudioFramework
//
//  Created by Admin on 9/12/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

class InstrumentChannelController : ChannelController{
    override func set(channelPluginData: ChannelPluginData){
        super.set(channelPluginData: channelPluginData)
        loadInstrument(pluginData: channelPluginData.instrumentPlugin)
    }
    override func select(description: AudioComponentDescription, type: PluginType, number: Int) {
        if type == .instrument {
            loadInstrument(fromDescription: description, showInterface: true)
            reconnectNodes()
        } else {
            super.select(description: description, type: type, number: number)
        }
    }
    private func loadInstrument(pluginData: PluginData){
        guard let audioComponentDescription = pluginData.audioComponentDescription else { return }
        loadInstrument(fromDescription: audioComponentDescription, showInterface: false)
        fullState = pluginData.state
    }
    private func loadInstrument(fromDescription desc: AudioComponentDescription, showInterface: Bool){
        let context = delegate.contextBlock
        let audioUnit = PluginFactory.instrument(description: desc, context: context)
        if inputNode != nil {
            delegate.engine.detach(inputNode!)
        }
        delegate.engine.attach(audioUnit)
        inputNode = audioUnit
        reconnectNodes()
        if showInterface{
            delegate.displayInterface(audioUnit: audioUnit)
        }
    }
    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->()){
        guard let au = self.auAudioUnit else { completion(nil) ; return }
        au.requestViewController { (vc) in
            completion(vc.map(InterfaceInstance.viewController))
        }
    }

    private var fullState : [String : Any]? {
        get {
            guard let au = self.auAudioUnit else { return nil }
            let state = au.fullState
            return state
        }
        set {
            guard let au = self.auAudioUnit else { return }
            au.fullState = newValue
        }
    }
    func noteOn(_ note: UInt8, withVelocity velocity: UInt8, channel: UInt8) {
        guard let inst = inputNode as? AVAudioUnitMIDIInstrument else { return }
        inst.startNote(note, withVelocity: velocity, onChannel: channel)
    }
    
    func noteOff(_ note: UInt8, channel: UInt8) {
        guard let inst = inputNode as? AVAudioUnitMIDIInstrument else { return }
        inst.stopNote(note, onChannel: channel)
    }
    func set(volume: UInt8, channel: UInt8){
        guard let inst = inputNode as? AVAudioUnitMIDIInstrument else { return }
        let controller = UInt8(7)
        inst.sendController(controller, withValue: volume, onChannel: 0)
    }
    func set(pan: UInt8, channel: UInt8){
        guard let inst = inputNode as? AVAudioUnitMIDIInstrument else { return }
        let controller = UInt8(10)
        inst.sendController(controller, withValue: pan, onChannel: channel)
    }
    func setController(number: UInt8, value: UInt8, channel: UInt8){
        guard let inst = inputNode as? AVAudioUnitMIDIInstrument else { return }
        inst.sendController(number, withValue: value, onChannel: channel)
    }
    public func allNotesOff(){
        
    }
    override func getChannelPluginData() -> ChannelPluginData{
        let channelPluginData = super.getChannelPluginData()
        let state = fullState
        let desc = audioComponentDescription
        let instrumentPluginData = PluginData(state: state, audioComponentDescription: desc)
        channelPluginData.instrumentPlugin = instrumentPluginData
        return channelPluginData
    }
    var audioComponentDescription : AudioComponentDescription? {
        get {
            guard let au = self.auAudioUnit else { return nil }
            let desc = au.componentDescription
            return desc
        }
    }
    var auAudioUnit : AUAudioUnit? {
        guard let instrumentHost = inputNode as? AVAudioUnitMIDIInstrument else { return nil }
        return instrumentHost.auAudioUnit
    }
    override func getPluginSelection(pluginType: PluginType, pluginNumber: Int) -> PluginSelection? {
        if pluginType == .effect {
            let pluginSelection = super.getPluginSelection(pluginType: pluginType, pluginNumber: pluginNumber)
            return pluginSelection
        }
        guard let audioUnit = inputNode as? AVAudioUnitMIDIInstrument else { return nil }
        let manufacturer = audioUnit.manufacturerName
        let name = audioUnit.name
        let pluginSelection = PluginSelection(manufacturer: manufacturer, name: name)
        return pluginSelection
    }
    override var midiIn : AVAudioUnit?{
        guard let avAudioUnit = inputNode as? AVAudioUnitMIDIInstrument else { return nil }
        return avAudioUnit
    }
    override func displayInterface(type: PluginType, number: Int) {
        if type == .instrument {
            if let audioUnit = inputNode as? AVAudioUnitMIDIInstrument {
                delegate.displayInterface(audioUnit: audioUnit)
            }
        } else {
            super.displayInterface(type: type, number: number)
        }
    }
}
