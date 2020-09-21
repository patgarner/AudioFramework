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
        self.loadInstrument(fromDescription: audioComponentDescription) { (success) in
            self.instrumentHost.fullState = pluginData.state
        }
    }
    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->()){
        instrumentHost.requestInstrumentInterface(completion)
    }
    func loadInstrument(fromDescription desc: AudioComponentDescription, completion: @escaping (Bool)->()){
        instrumentHost.loadInstrument(fromDescription: desc){(success) in
            if success {
                self.reconnectNodes()
            }
            completion(success)
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
    override var allAudioUnits : [AVAudioNode] {
        var audioUnits : [AVAudioNode] = []
        if let instrumentAU = instrumentHost.audioUnit {
            audioUnits.append(instrumentAU)
        }
        audioUnits.append(contentsOf: effects)
        if let preOutput = preOutputNode{
            audioUnits.append(preOutput)
        }
        if let output = outputNode {
            audioUnits.append(output)
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
    override func displayInterface(type: PluginType, number: Int = 0){
        if type == .effect {
            super.displayInterface(type: type, number: number)
            return
        } else if type == .instrument{
            guard let audioUnit = instrumentHost.audioUnit?.audioUnit else { return }
            delegate.displayInterface(audioUnit: audioUnit)
        }
 
    }
}
