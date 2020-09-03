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
    private override init (){
        super.init()
    }
    var host: InstrumentHost = AUv3InstrumentHost()
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
    
    public func loadInstrument(fromDescription desc: AudioComponentDescription, completion: @escaping (Bool)->()) {
        host.loadInstrument(fromDescription: desc, completion: completion)
    }
    
    public func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->()) {
        self.host.requestInstrumentInterface(completion)
    }
    
    public func noteOn(_ note: UInt8, withVelocity velocity: UInt8, channel: UInt8) {
        host.noteOn(note, withVelocity: velocity, channel: channel)
    }
    
    public func noteOff(_ note: UInt8, channel: UInt8) {
        host.noteOff(note, channel: channel)
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
    func recordTo2(url: URL) { //TODO: Move somewhere else
//        let assetOutputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44100, channels: 2, interleaved: true)!
//        let tapFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 2, interleaved: false)!
//        do{
//            let assetWriter = try AVAssetWriter(outputURL: url, fileType: .wav) //No worries here..
//            let assetInput = AVAssetWriterInput(mediaType: .audio, outputSettings: assetOutputFormat.settings)
//            assetWriter.add(assetInput)
//            engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: tapFormat) { (buffer, when) in // <========SETTINGS!
//                let cmBuffer = buffer as! CMSampleBuffer //CRASHES HERE
//                
//                assetInput.append(cmBuffer)
//            }
//        } catch {
//            print("Error: Problem writing audio file. \(error)")
//        }
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
    public func set(volume: UInt8, channel: UInt8){
        host.set(volume: volume, channel: channel)
    }
    public func set(pan: UInt8, channel: UInt8){
        host.set(pan: pan, channel: channel)
    }
    public func set(tempo: UInt8){
        host.set(tempo: tempo)
    }
    public func setController(number: UInt8, value: UInt8, channel: UInt8){
        host.setController(number: number, value: value, channel: channel)
    }
    public var samplerData : SamplerData {
        get {
            let s = host.samplerData
            return s
        } 
        set {
            guard let audioComponentDescription = newValue.audioComponentDescription else { return }
            self.loadInstrument(fromDescription: audioComponentDescription) { (success) in
                self.requestInstrumentInterface{ (maybeInterface) in
                    guard let interface = maybeInterface else { return }
                    SamplerModel.shared.instrumentInterfaceInstance = interface
                    self.host.fullState = newValue.state //You are putting the state in but no vc yet...
                }
            }
        }
    }
    /////////////////////////////////////////////////////////////
    // Effects
    /////////////////////////////////////////////////////////////
    public func loadEffect(fromDescription desc: AudioComponentDescription, completion: @escaping (Bool)->()) {
        let flags = AudioComponentFlags(rawValue: desc.componentFlags)
        let canLoadInProcess = flags.contains(AudioComponentFlags.canLoadInProcess)
        let loadOptions: AudioComponentInstantiationOptions = canLoadInProcess ? .loadInProcess : .loadOutOfProcess
        AVAudioUnitEffect.instantiate(with: desc, options: loadOptions) { (avAudioUnit, error) in
            if let e = error {
                print("Failed to load instrument: \(e)")
                completion(false)
            }
            if avAudioUnit == nil { return }
            //DispatchQueue.main.async {
            self.requestInstrumentInterface2(audioUnit: avAudioUnit!) { (interfaceInstance) in
                    completion(true)
            }
            //}
        }
    }
    @available(OSX 10.12, *)
    func requestInstrumentInterface2(audioUnit: AVAudioUnit, _ completion: @escaping (InterfaceInstance?)->()) {
        let au = audioUnit.auAudioUnit
        au.requestViewController { (vc) in
            if let vc = vc {
                self.delegate?.load(viewController: vc)
            }
        }
    }
    
    func load(viewController: NSViewController){
        delegate?.load(viewController: viewController)
    }

}



