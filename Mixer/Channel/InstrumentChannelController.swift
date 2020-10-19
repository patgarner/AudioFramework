//
//  InstrumentChannelController.swift
//  AudioFramework
//
//  Created by Admin on 9/12/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

public class InstrumentChannelController : ChannelController{
    override func set(channelPluginData: ChannelModel){
        super.set(channelPluginData: channelPluginData)
        loadInstrument(pluginData: channelPluginData.instrumentPlugin)
    }
    override public func select(description: AudioComponentDescription, type: PluginType, number: Int) {
        if type == .instrument {
            print("ARM")
            AudioController.shared.test()
            print("LEG")
            loadInstrument(fromDescription: description, showInterface: true)
            print("EYE")
            AudioController.shared.test()
            print("BALL")
            reconnectNodes()
            print("FACE")
            AudioController.shared.test()
            print("LICK")
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
        print("ALIEN")
        AudioController.shared.test()
        print("CONAN")
        let context = delegate.contextBlock()
        print("ONE")
        AudioController.shared.test()
        print("TWO")
        delegate.engine.pause()
        print("APPLE")
        AudioController.shared.test()
        print("ORANGE")
        let audioUnit = AudioNodeFactory.instrument(description: desc, context: context)
        print("GRAPE")
        AudioController.shared.test()
        print("STRAWBERRY")
        if inputNode != nil {
            delegate.engine.detach(inputNode!)
        }
        delegate.engine.attach(audioUnit)
        inputNode = audioUnit
        reconnectNodes()
        if showInterface{
            delegate.displayInterface(audioUnit: audioUnit)
        }
        print("InstrumentChannelController.loadInstrument about to check context FART")
        AudioController.shared.test()
        print("InstrumentChannelController.loadInstrument finished checking context BUTT")
    }
    //    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->()){
    //        guard let au = self.auAudioUnit else { completion(nil) ; return }
    //        au.requestViewController { (vc) in
    //            completion(vc.map(InterfaceInstance.viewController))
    //        }
    //    }
    
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
        guard let instrumentNode = inputNode as? AVAudioUnitMIDIInstrument else { return }
        instrumentNode.startNote(note, withVelocity: velocity, onChannel: channel)
    }
    func noteOff(_ note: UInt8, channel: UInt8) {
        instrumentNode?.stopNote(note, onChannel: channel)
    }
    func set(volume: UInt8, channel: UInt8){
        let controller = UInt8(7)
        instrumentNode?.sendController(controller, withValue: volume, onChannel: 0)
    }
    func set(pan: UInt8, channel: UInt8){
        let controller = UInt8(10)
        instrumentNode?.sendController(controller, withValue: pan, onChannel: channel)
    }
    func setController(number: UInt8, value: UInt8, channel: UInt8){
        instrumentNode?.sendController(number, withValue: value, onChannel: channel)
    }
    private var instrumentNode : AVAudioUnitMIDIInstrument? {
        let node = inputNode as? AVAudioUnitMIDIInstrument
        return node
    }
    public func allNotesOff(){
        
    }
    override func getChannelPluginData() -> ChannelModel{
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
    override public func getPluginSelection(pluginType: PluginType, pluginNumber: Int) -> PluginSelection? {
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
    override public func displayInterface(type: PluginType, number: Int) {
        if type == .instrument {
            if let audioUnit = inputNode as? AVAudioUnitMIDIInstrument {
                delegate.displayInterface(audioUnit: audioUnit)
            }
        } else {
            super.displayInterface(type: type, number: number)
        }
    }
}
