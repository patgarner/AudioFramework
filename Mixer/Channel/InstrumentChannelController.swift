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
    var instrumentHost : VirtualInstrumentHost = AudioUnit3Host()
    func loadInstrument(pluginData: PluginData){
        guard let audioComponentDescription = pluginData.audioComponentDescription else { return }
        loadInstrument(fromDescription: audioComponentDescription)
        instrumentHost.fullState = pluginData.state
    }
    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->()){
        instrumentHost.requestInstrumentInterface(completion)
    }
    func loadInstrument(fromDescription desc: AudioComponentDescription){
        let context = delegate.contextBlock
        instrumentHost.loadInstrument(fromDescription: desc, context: context)
        reconnectNodes()
        if let audioUnit = instrumentHost.audioUnit{
            delegate.displayInterface(audioUnit: audioUnit)
        }
    }
    override func select(description: AudioComponentDescription, type: PluginType, number: Int) {
        if type == .instrument {
            let contextBlock = delegate.contextBlock
            instrumentHost.loadInstrument(fromDescription: description, context: contextBlock)
            reconnectNodes()
            if let audioUnit = instrumentHost.audioUnit{
                delegate.displayInterface(audioUnit: audioUnit)
            }
        } else {
            super.select(description: description, type: type, number: number)
        }
    }
    override func set(channelPluginData: ChannelPluginData){
        super.set(channelPluginData: channelPluginData)
        loadInstrument(pluginData: channelPluginData.instrumentPlugin)
    }
    public func noteOn(_ note: UInt8, withVelocity velocity: UInt8, channel: UInt8) {
        instrumentHost.noteOn(note, withVelocity: velocity, channel: channel)
    }
    public func noteOff(_ note: UInt8, channel: UInt8) {
        instrumentHost.noteOff(note, channel: channel)
    } 
    public func set(volume: UInt8, channel: UInt8){
        instrumentHost.set(volume: volume, channel: channel)
    }
    public func set(pan: UInt8, channel: UInt8){
        instrumentHost.set(pan: pan, channel: channel)
    }
    public func set(tempo: UInt8){
        instrumentHost.set(tempo: tempo)
    }
    public func setController(number: UInt8, value: UInt8, channel: UInt8){
        instrumentHost.setController(number: number, value: value, channel: channel)
    }
    public func allNotesOff(){
        
    }
    override func getChannelPluginData() -> ChannelPluginData{
        let channelPluginData = super.getChannelPluginData()
        let instrumentPluginData = instrumentHost.samplerData
        channelPluginData.instrumentPlugin = instrumentPluginData
        return channelPluginData
    }
    override func allAudioUnits(includeSends: Bool = false) -> [AVAudioNode] {
        var audioUnits : [AVAudioNode] = []
        if let instrumentAU = instrumentHost.audioUnit {
            audioUnits.append(instrumentAU)
        }
        audioUnits.append(contentsOf: effects)
        if muteNode != nil {
             audioUnits.append(muteNode!)
         }
         if soloNode != nil{
             audioUnits.append(soloNode!)
         }
        if let sendSplitter = sendSplitterNode{
            audioUnits.append(sendSplitter)
        }
        if includeSends{
            audioUnits.append(contentsOf: sendOutputs)
        }
        if outputNode != nil {
            audioUnits.append(outputNode)
        }
        return audioUnits
    }
    override func createIONodes() {
        super.createIONodes()
    }
    override func getPluginSelection(pluginType: PluginType, pluginNumber: Int) -> PluginSelection? {
        if pluginType == .effect {
            let pluginSelection = super.getPluginSelection(pluginType: pluginType, pluginNumber: pluginNumber)
            return pluginSelection
        }
        guard let audioUnit = instrumentHost.audioUnit else { return nil }
        let manufacturer = audioUnit.manufacturerName
        let name = audioUnit.name
        let pluginSelection = PluginSelection(manufacturer: manufacturer, name: name)
        return pluginSelection
    }
    override var midiIn : AVAudioUnit?{
        guard let avAudioUnit = instrumentHost.audioUnit else { return nil }
        return avAudioUnit
    }
    override func displayInterface(type: PluginType, number: Int) {
        if type == .instrument {
            if let audioUnit = instrumentHost.audioUnit {
                delegate.displayInterface(audioUnit: audioUnit)
            }
        } else {
            super.displayInterface(type: type, number: number)
        }
    }
}