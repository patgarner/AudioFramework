//
//  AUv3InstrumentHost.swift
//  AUInstHostTest
//
//  Created by acb on 04/12/2017.
//  Copyright © 2017 acb. All rights reserved.
//

import Foundation
import AVFoundation

class AUv3InstrumentHost : InstrumentHost{
    var engine : AVAudioEngine {
        return AudioService.shared.engine
    } 
    private var instrumentAU : AVAudioUnitMIDIInstrument? = nil
    var audioUnit: AVAudioUnit? {
        return instrumentAU
    }
    func set(instrument : AVAudioUnitMIDIInstrument?){
        detach(audioUnit: instrumentAU)
        attach(audioUnit: instrument)
    }
    func detach(audioUnit: AVAudioUnit?){
        guard let audioUnit = audioUnit else { return }
        engine.disconnectNodeOutput(audioUnit)
        engine.detach(audioUnit)
    }
    func attach(audioUnit: AVAudioUnit?){
        guard let newInst = audioUnit as? AVAudioUnitMIDIInstrument else { return }
        self.instrumentAU = newInst
        engine.attach(newInst)
    }
    func connect(audioUnit: AVAudioUnit?){
        guard let audioUnit = audioUnit else { return }
        let instOutputFormat = audioUnit.outputFormat(forBus: 0)
        engine.connect(audioUnit, to: self.engine.mainMixerNode, format: instOutputFormat)
    }
    /////////////////////////////////////////////////////////////////////////
    // Instrument Host Protocol
    /////////////////////////////////////////////////////////////////////////
    var auAudioUnit: AUAudioUnit? {
        return self.instrumentAU?.auAudioUnit
    }
    func loadInstrument(fromDescription desc: AudioComponentDescription, completion: @escaping (Bool)->()) {
        let flags = AudioComponentFlags(rawValue: desc.componentFlags)
        let canLoadInProcess = flags.contains(AudioComponentFlags.canLoadInProcess)
        let loadOptions: AudioComponentInstantiationOptions = canLoadInProcess ? .loadInProcess : .loadOutOfProcess
        AVAudioUnitMIDIInstrument.instantiate(with: desc, options: loadOptions) { [weak self] avAudioUnit, error in
            if let e = error {
                print("Failed to load instrument: \(e)")
                completion(false)
            } else if let unit = avAudioUnit as? AVAudioUnitMIDIInstrument {
                DispatchQueue.main.async {
                    self?.set(instrument: unit)
                    completion(true)
                }
            } else {
                fatalError()
            }
        }
    }
    func noteOn(_ note: UInt8, withVelocity velocity: UInt8, channel: UInt8) {
        guard let inst = self.instrumentAU else { return }
        inst.startNote(note, withVelocity: velocity, onChannel: channel)
    }
    
    func noteOff(_ note: UInt8, channel: UInt8) {
        guard let inst = self.instrumentAU else { return }
        inst.stopNote(note, onChannel: channel)
    }
    func set(volume: UInt8, channel: UInt8){
        guard let inst = self.instrumentAU else { return }
        let controller = UInt8(7)
        inst.sendController(controller, withValue: volume, onChannel: 0)
    }
    func set(pan: UInt8, channel: UInt8){
        guard let inst = self.instrumentAU else { return }
        let controller = UInt8(10)
        inst.sendController(controller, withValue: pan, onChannel: channel)
    }
    func set(tempo: UInt8) {}
    func setController(number: UInt8, value: UInt8, channel: UInt8){
        guard let inst = self.instrumentAU else { return }
        inst.sendController(number, withValue: value, onChannel: channel)
    }
    var fullState : [String : Any]? {
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
    var audioComponentDescription : AudioComponentDescription? {
        get {
            guard let au = self.auAudioUnit else { return nil }
            let desc = au.componentDescription
            return desc
        }
    }
    var samplerData : PluginData {
        get {
            let state = fullState
            let desc = audioComponentDescription
            let samplerData = PluginData(state: state, audioComponentDescription: desc)
            return samplerData
        } set {
            
        }
    }
    @available(OSX 10.12, *)
    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->()) {
        guard let au = self.auAudioUnit else { completion(nil) ; return }
        au.requestViewController { (vc) in
            completion(vc.map(InterfaceInstance.viewController))
        }
    }
}
