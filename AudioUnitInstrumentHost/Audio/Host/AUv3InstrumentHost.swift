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
    var audioFile : AVAudioFile?
    var engine : AVAudioEngine {
        return AudioService.shared.audioEngine
    } 
    private var instrumentAU: AVAudioUnitMIDIInstrument? = nil { //TODO: Refactor
        didSet(oldValue) {
            if let oldValue = oldValue {
                self.engine.disconnectNodeOutput(oldValue)
                self.engine.detach(oldValue)
            }
            if let newInst = self.instrumentAU {
                self.engine.attach(newInst)
                let instOutputFormat = newInst.outputFormat(forBus: 0)
                self.engine.connect(newInst, to: self.engine.mainMixerNode, format: instOutputFormat)
            }
        }
    }
    fileprivate func startEngineIfNeeded() { //TODO: Move somewhere else
        if !self.engine.isRunning {
            do {
                try engine.start()
                print("audio engine started")
            } catch {
                print("oops \(error)")
                print("could not start audio engine")
            }
        }
    }
    /////////////////////////////////////////////////////////////////////////
    // Instrument Host Protocal
    /////////////////////////////////////////////////////////////////////////
    var auAudioUnit: AUAudioUnit? { return self.instrumentAU?.auAudioUnit }
        
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
                    self?.instrumentAU = unit
                    completion(true)
                }
            } else {
                fatalError()
            }
        }
    }
        
    func noteOn(_ note: UInt8, withVelocity velocity: UInt8, channel: UInt8) {
        guard let inst = self.instrumentAU else { return }
        self.startEngineIfNeeded() //TODO: Move somewhere else
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
    func set(tempo: UInt8) {
        guard let inst = self.instrumentAU else { return }
        //add(tempo: Float64(metaEvent.value), time: MusicTimeStamp(metaEvent.time), musicSequence: sequence)
        
        //let tempoEvent = ExtendedTempoEvent(bpm: Float64(tempo))
        
        var midiMetaEvent = MIDIMetaEvent()
        midiMetaEvent.metaEventType = UInt8(0)
        midiMetaEvent.data = tempo
        midiMetaEvent.dataLength = 6
        
    
       // inst.met
        

        //FF 51 03 tttttt Set Tempo (in microseconds per MIDI quarter-note)
        
//        internal func addTitle(_ title:String, track:MusicTrack) {
//            let data = [UInt8](title.utf8)
//            var metaEvent = MIDIMetaEvent()
//            metaEvent.metaEventType = 3
//            metaEvent.dataLength = UInt32(data.count)
//            withUnsafeMutablePointer(to: &metaEvent.data, {
//                pointer in
//                for i in 0 ..< data.count {
//                    pointer[i] = data[i]
//                }
//            })
//            let timeStamp : MusicTimeStamp = 0
//            let status = MusicTrackNewMetaEvent(track, timeStamp, &metaEvent)
//            if status != noErr {
//                print("Unable to add title %@. Error: \(status)")
//            }
//        }

        
    }
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
    
    func requestInstrumentInterfaceSimple(){
        guard let au = self.auAudioUnit else { return }
        au.requestViewController { (vc) in
            //Do something now with the view controller
            if let vc = vc {
                AudioService.shared.load(viewController: vc)
            }
        }
    }
}
