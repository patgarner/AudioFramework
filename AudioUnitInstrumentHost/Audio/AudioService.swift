//
//  AudioService.swift
//  AudioUnitInstrumentHost
//
//  Created by acb on 07/12/2017.
//  Copyright © 2017 acb. All rights reserved.
//

/*
 The AudioUnitv3 hosting code does not always work reliably with commercial softsynths, and can crash when changing presets. Until this improves, the AUv2 code, whilst uglier, is more solid.
 */
import Foundation
import AVFoundation
import Cocoa

public class AudioService: NSObject {
    public static var shared = AudioService()
    var recordingUrl : URL?
    public let audioEngine = AVAudioEngine()
    public var delegate : AudioServiceDelegate?
    public var audioUnitEffect : AVAudioUnit? //TODO: Hack. This doesn't belong here but works for now.

    private override init (){
        super.init()
        for _ in 0..<16{
            channels.append(AUv2InstrumentHost())
        }
    }
    var channels : [InstrumentHost] = []
    func getListOfEffects() -> [AVAudioUnitComponent]{
        var desc = AudioComponentDescription()
        desc.componentType = kAudioUnitType_Effect
        desc.componentSubType = 0
        desc.componentManufacturer = 0
        desc.componentFlags = 0
        desc.componentFlagsMask = 0
        return AVAudioUnitComponentManager.shared().components(matching: desc)
    }
    public func getListOfInstruments() -> [AVAudioUnitComponent] {
        var desc = AudioComponentDescription()
        desc.componentType = kAudioUnitType_MusicDevice
        desc.componentSubType = 0
        desc.componentManufacturer = 0
        desc.componentFlags = 0
        desc.componentFlagsMask = 0
        return AVAudioUnitComponentManager.shared().components(matching: desc)
    }
    
    public func loadInstrument(fromDescription desc: AudioComponentDescription, channel: Int, completion: @escaping (Bool)->()) {
        if channel >= channels.count { return }
        let host = channels[channel]
        host.loadInstrument(fromDescription: desc, completion: completion)
        print("")
    }
    
    public func requestInstrumentInterface(channel: Int, _ completion: @escaping (InterfaceInstance?)->()) {
        if channel >= channels.count { completion(nil) }
        let host = channels[channel]
        host.requestInstrumentInterface(completion)
    }
    public func recordTo(url: URL) { //TODO: Move somewhere else
        self.recordingUrl = url
        let format = self.audioEngine.mainMixerNode.outputFormat(forBus: 0)
        let settings = format.settings
        do {
            let audioFile = try AVAudioFile(forWriting: url, settings: settings, commonFormat: .pcmFormatFloat32, interleaved: false)
            audioEngine.mainMixerNode.removeTap(onBus: 0)
            audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, when) in
                do {
                    try audioFile.write(from: buffer)
                } catch {
                    print("Couldn't write to buffer. Error \(error)")
                }
            }
        } catch {
            print("Couldn't record. Error: \(error)")
        }
    }

    func stopRecording() { //TODO: Move somewhere else
        audioEngine.mainMixerNode.volume = 0
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        audioEngine.mainMixerNode.volume = 1
        guard let url = self.recordingUrl else { return }
        let destinationUrl = url.deletingPathExtension().appendingPathExtension("wav")
        AudioFileConverter.convert(sourceURL: url, destinationURL: destinationUrl)
        self.recordingUrl = nil
    }
    public func stop(){
        stopRecording()
    }
    public func noteOn(_ note: UInt8, withVelocity velocity: UInt8, channel: UInt8) {
        if channel >= channels.count { return }
        let host = channels[Int(channel)]
        host.noteOn(note, withVelocity: velocity, channel: channel)
    }
    
    public func noteOff(_ note: UInt8, channel: UInt8) {
        if channel >= channels.count { return }
        let host = channels[Int(channel)]
        host.noteOff(note, channel: channel)
    } 
    public func set(volume: UInt8, channel: UInt8){
        if channel >= channels.count { return }
        let host = channels[Int(channel)]
        host.set(volume: volume, channel: channel)
    }
    public func set(pan: UInt8, channel: UInt8){
        if channel >= channels.count { return }
        let host = channels[Int(channel)]
        host.set(pan: pan, channel: channel)
    }
    public func set(tempo: UInt8){
        for channel in 0..<channels.count{
            let host = channels[channel]
        }
    }
    public func setController(number: UInt8, value: UInt8, channel: UInt8){
        if channel >= channels.count { return }
        let host = channels[Int(channel)]
        host.setController(number: number, value: value, channel: channel)
    }
    public var samplerData : SamplerData { //Need to make this multitrack
        get {
            let host = channels[0] //TODO
            let s = host.samplerData
            return s
        } 
        set {
            guard let audioComponentDescription = newValue.audioComponentDescription else { return }
            self.loadInstrument(fromDescription: audioComponentDescription, channel: 0) { (success) in
                self.requestInstrumentInterface(channel: 0){ (maybeInterface) in
                    guard let interface = maybeInterface else { return }
                    SamplerInterfaceModel.shared.instrumentInterfaceInstance = interface
                    var host = self.channels[0]
                    host.fullState = newValue.state //You are putting the state in but no vc yet...
                }
            }
        }
    }
    /////////////////////////////////////////////////////////////
    // Effects
    /////////////////////////////////////////////////////////////
    public func loadEffect(fromDescription desc: AudioComponentDescription, channel: Int, completion: @escaping (Bool)->()) {
        let flags = AudioComponentFlags(rawValue: desc.componentFlags)
        let canLoadInProcess = flags.contains(AudioComponentFlags.canLoadInProcess)
        let loadOptions: AudioComponentInstantiationOptions = canLoadInProcess ? .loadInProcess : .loadOutOfProcess
        AVAudioUnitEffect.instantiate(with: desc, options: loadOptions) { (avAudioUnit, error) in
            if let e = error {
                self.delegate?.log("Failed to load effect. Error: \(e)")
                completion(false)
            }
            guard let audioUnitEffect = avAudioUnit else { return }
            self.audioUnitEffect = audioUnitEffect
            completion(true)
        }
    }
    func requestEffectInterface(_ completion: @escaping (InterfaceInstance?)->()) {
        guard let au = audioUnitEffect else { 
            completion(nil)
            return
        } 
        au.auAudioUnit.requestViewController { (vc) in
//              guard let vc = vc else { return }
//              completion(vc)
        }
    }
    @available(OSX 10.12, *)
    func requestInstrumentInterface2(audioUnit: AVAudioUnit, _ completion: @escaping (InterfaceInstance?)->()) {
        let au = audioUnit.auAudioUnit
        au.requestViewController { (vc) in
            guard let vc = vc else { return }
            self.delegate?.load(viewController: vc)
        }
    }
    
    func load(viewController: NSViewController){
        delegate?.load(viewController: viewController)
    }
    
    //Apple
//    func loadAudioUnitViewController(completion: @escaping (NSViewController?) -> Void) {
//        if let audioUnit = audioUnit {
//            audioUnit.requestViewController { viewController in
//                DispatchQueue.main.async {
//                    completion(viewController)
//                }
//            }
//        } else {
//            completion(nil)
//        }
//    }
}



