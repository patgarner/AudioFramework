//
//  ChannelController.swift
//  AudioFramework
//
//  Created by Admin on 9/7/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

class ChannelController {
    //Inst
    //[FX]
    //Busses
    var delegate : ChannelControllerDelegate?
    var instrumentHost : InstrumentHost = AUv3InstrumentHost()
    public var effects : [AVAudioUnit] = []
    var engine : AVAudioEngine{
        return AudioService.shared.engine
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
    func getChannelPluginData() -> ChannelPluginData{
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
    func set(channelPluginData: ChannelPluginData){
        loadInstrument(pluginData: channelPluginData.instrumentPlugin)
         for effectNumber in 0..<channelPluginData.effectPlugins.count{
             let pluginData = channelPluginData.effectPlugins[effectNumber]
             loadEffect(pluginData: pluginData, number: effectNumber)
         }
    }
    func loadInstrument(fromDescription desc: AudioComponentDescription, completion: @escaping (Bool)->()){
        //instrumentHost.loadInstrument(fromDescription: desc, completion: completion)
        instrumentHost.loadInstrument(fromDescription: desc){(success) in
            if success {
                //self.connect(audioUnit: self.instrumentHost.audioUnit)
                self.connectEverything()
            }
            completion(success)
        }
    }
    func connect(audioUnit: AVAudioUnit?){
        guard let audioUnit = audioUnit else { return }
        let instOutputFormat = audioUnit.outputFormat(forBus: 0)
        engine.connect(audioUnit, to: self.engine.mainMixerNode, format: instOutputFormat)
    }
    func connectEverything(){
        disconnectOutput(audioUnit: instrumentHost.audioUnit)
        for effect in effects{
            disconnectOutput(audioUnit: effect)
        }
        var audioUnits : [AVAudioUnit] = []
        var nodes = engine.attachedNodes
        print("num nodes = \(nodes.count)")
        guard let instrumentAU = instrumentHost.audioUnit else { return }
        audioUnits.append(instrumentAU)
        audioUnits.append(contentsOf: effects)
        for i in 1..<audioUnits.count{
            let previousUnit = audioUnits[i-1]
            let thisUnit = audioUnits[i]
            let format = previousUnit.outputFormat(forBus: 0)
            if nodes.contains(previousUnit), nodes.contains(thisUnit){
                engine.connect(previousUnit, to: thisUnit, format: format)
            } else {
                print("Sorry, engine needs to contain BOTH nodes it is connecting.")
            }
        }
        let format = audioUnits.last!.outputFormat(forBus: 0)
        engine.connect(audioUnits.last!, to: engine.mainMixerNode, format: format)
    }
    func disconnectOutput(audioUnit: AVAudioUnit?){
        if let audioUnit = audioUnit{
            if engine.attachedNodes.contains(audioUnit){
                engine.disconnectNodeOutput(audioUnit)
            }
        }
    }
    func loadInstrument(pluginData: PluginData){
        guard let audioComponentDescription = pluginData.audioComponentDescription else { return }
        self.loadInstrument(fromDescription: audioComponentDescription) { (success) in
            self.instrumentHost.fullState = pluginData.state
        }
    }
    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->()){
        instrumentHost.requestInstrumentInterface(completion)
    }


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Effects
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func loadEffect(pluginData: PluginData, number: Int){
        guard let audioComponentDescription = pluginData.audioComponentDescription else { return }
        loadEffect(fromDescription: audioComponentDescription, number: number) { (success) in
            if !success { return }
            let effect = self.effects[number]
            let au = effect.auAudioUnit
            au.fullState = pluginData.state
        }
    }
    public func loadEffect(fromDescription desc: AudioComponentDescription, number: Int, completion: @escaping (Bool)->()) {
        let flags = AudioComponentFlags(rawValue: desc.componentFlags)
        let canLoadInProcess = flags.contains(AudioComponentFlags.canLoadInProcess)
        let loadOptions: AudioComponentInstantiationOptions = canLoadInProcess ? .loadInProcess : .loadOutOfProcess
        AVAudioUnitEffect.instantiate(with: desc, options: loadOptions) { (avAudioUnit, error) in
            if let e = error {
                self.delegate?.log("Failed to load effect. Error: \(e)")
                completion(false)
            }
            guard let audioUnitEffect = avAudioUnit else { return }
            //self.effects.removeAll() //TODO: This only allows for one effect, or at least destroys the references.
            //self.effects.append(audioUnitEffect)
            self.set(effect: audioUnitEffect, number: number)
            self.connectEverything()
            completion(true)
        }
    }
    func set(effect: AVAudioUnit, number: Int){
        if number < effects.count { //There is already an effect there
            let existingEffect = effects[number]
            engine.disconnectNodeOutput(existingEffect)
            effects[number] = effect
            engine.detach(existingEffect)
            engine.attach(effect)
        } else if number == effects.count {
            effects.append(effect)
            engine.attach(effect)
        } else {
            print("Error: trying to add effect out of sequence")
        }
    }
    func getEffect(number: Int) -> AVAudioUnit?{
        if number >= effects.count {
            return nil
        }
        return effects[number]
    }
}

protocol ChannelControllerDelegate{
    func log(_ message: String)
}

enum PluginType{
    case instrument
    case effect
}
