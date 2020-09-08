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
    public var audioUnitEffects : [AVAudioUnit] = []

    func loadInstrument(fromDescription desc: AudioComponentDescription, completion: @escaping (Bool)->()){
        instrumentHost.loadInstrument(fromDescription: desc, completion: completion)
    }
    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->()){
        instrumentHost.requestInstrumentInterface(completion)
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
    public var pluginData : PluginData { //Need to make this multitrack
        get {
            let s = instrumentHost.samplerData
            return s
        } 
        set {
            instrumentHost.samplerData = newValue
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Effects
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public func loadEffect(fromDescription desc: AudioComponentDescription, number: Int, completion: @escaping (Bool)->()) {
        let flags = AudioComponentFlags(rawValue: desc.componentFlags)
        let canLoadInProcess = flags.contains(AudioComponentFlags.canLoadInProcess)
        let loadOptions: AudioComponentInstantiationOptions = canLoadInProcess ? .loadInProcess : .loadOutOfProcess
        AVAudioUnitEffect.instantiate(with: desc, options: loadOptions) { (avAudioUnit, error) in
            if let e = error {
                self.delegate?.log("Failed to load effect. Error: \(e)")
                completion(false)
            }
            self.audioUnitEffects.removeAll() //TODO: Remove
            guard let audioUnitEffect = avAudioUnit else { return }
            self.audioUnitEffects.append(audioUnitEffect)
            completion(true)
        }
    }
    func getEffect(number: Int) -> AVAudioUnit?{
        if number >= audioUnitEffects.count {
            return nil
        }
        return audioUnitEffects[number]
    }
}

protocol ChannelControllerDelegate{
    func log(_ message: String)
}
