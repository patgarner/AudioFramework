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
        let channelPluginData = ChannelPluginData()
        let instrumentPluginData = instrumentHost.samplerData
        channelPluginData.instrumentPlugin = instrumentPluginData
        for effect in effects{
            let effectPluginData = PluginData()
            effectPluginData.audioComponentDescription = effect.audioComponentDescription
            effectPluginData.state = effect.auAudioUnit.fullState
            channelPluginData.effectPlugins.append(effectPluginData)
        }
        return channelPluginData
    }
    
    override var allAudioUnits : [AVAudioNode] {
        var audioUnits : [AVAudioNode] = []
        if let instrumentAU = instrumentHost.audioUnit {
            audioUnits.append(instrumentAU)
        }
        audioUnits.append(contentsOf: effects)
        if let output = outputNode {
            audioUnits.append(output)
        }
        return audioUnits
    }
    override func createIONodes() {
        let mixerOutput = AudioNodeFactory.mixerNode()
        self.delegate.engine.attach(mixerOutput)
        self.outputNode = mixerOutput
    }
}
