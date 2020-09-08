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
    var channelControllers : [ChannelController] = []
    private override init (){
        super.init()
        for _ in 0..<16{
            channelControllers.append(ChannelController())
        }
    }

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
        if channel >= channelControllers.count { return }
        let channelController = channelControllers[channel]
        channelController.loadInstrument(fromDescription: desc, completion: completion)
        print("")
    }
    
    public func requestInstrumentInterface(channel: Int, _ completion: @escaping (InterfaceInstance?)->()) {
        if channel >= channelControllers.count { completion(nil) }
        let host = channelControllers[channel]
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
        if channel >= channelControllers.count { return }
        let channelController = channelControllers[Int(channel)]
        channelController.noteOn(note, withVelocity: velocity, channel: channel)
    }
    
    public func noteOff(_ note: UInt8, channel: UInt8) {
        if channel >= channelControllers.count { return }
        let channelController = channelControllers[Int(channel)]
        channelController.noteOff(note, channel: channel)
    } 
    public func set(volume: UInt8, channel: UInt8){
        if channel >= channelControllers.count { return }
        let channelController = channelControllers[Int(channel)]
        channelController.set(volume: volume, channel: channel)
    }
    public func set(pan: UInt8, channel: UInt8){
        if channel >= channelControllers.count { return }
        let channelController = channelControllers[Int(channel)]
        channelController.set(pan: pan, channel: channel)
    }
    public func set(tempo: UInt8){
        for channel in 0..<channelControllers.count{
            let host = channelControllers[channel]
            host.set(tempo: tempo)
        }
    }
    public func setController(number: UInt8, value: UInt8, channel: UInt8){
        if channel >= channelControllers.count { return }
        let channelController = channelControllers[Int(channel)]
        channelController.setController(number: number, value: value, channel: channel)
    }
    public var allPluginData : AllPluginData{
        get {
            let allData = AllPluginData()
            for channelController in channelControllers{
                let audioUnitData = channelController.pluginData
                allData.plugins.append(audioUnitData)
            }
            return allData
        }
        set {
            let allData = newValue
            for i in 0..<allData.plugins.count{
                let audioPluginData = allData.plugins[i]
                if i >= channelControllers.count {
                    channelControllers.append(ChannelController())
                }
                let channelController = channelControllers[i]
                channelController.pluginData = audioPluginData
            }
        }
    }
    /////////////////////////////////////////////////////////////
    // Effects
    /////////////////////////////////////////////////////////////
    public func loadEffect(fromDescription desc: AudioComponentDescription, channel: Int, completion: @escaping (Bool)->()) {
        let channelController = channelControllers[channel]
        channelController.loadEffect(fromDescription: desc, number: 0, completion: completion)
    }

    func getAudioEffect(channel:Int, number: Int) -> AVAudioUnit?{
        let channelController = channelControllers[channel]
        let effect = channelController.getEffect(number: number)
        return effect
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
}



