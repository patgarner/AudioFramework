//
//  AudioService.swift
//
/*
 Copyright 2020 David Mann Music LLC
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import AVFoundation
import Cocoa

public class AudioService: NSObject {
    public static var shared = AudioService()
    var recordingUrl : URL?
    public let engine = AVAudioEngine()
    public var delegate : AudioServiceDelegate?
    var channelControllers : [InstrumentChannelController] = []
    var auxControllers : [ChannelController] = []
    var masterController : ChannelController!
    private override init (){
        super.init()
    }
    public func initialize(){
        masterController = MasterChannelController(delegate: self)
        if let masterOutput = masterController.outputNode{
            let format = masterOutput.outputFormat(forBus: 0)
            engine.connect(masterOutput, to: engine.mainMixerNode, format: format)
        }
        for _ in 0..<16{
            let channelController = InstrumentChannelController(delegate: self)
            channelController.delegate = self
            channelControllers.append(channelController)
            if let channelOutput = channelController.outputNode, let masterInput = masterController.inputNode{
                let format = channelOutput.outputFormat(forBus: 0)
                engine.connect(channelOutput, to: masterInput, format: format)
            }
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
        let format = self.engine.mainMixerNode.outputFormat(forBus: 0)
        let settings = format.settings
        do {
            let audioFile = try AVAudioFile(forWriting: url, settings: settings, commonFormat: .pcmFormatFloat32, interleaved: false)
            engine.mainMixerNode.removeTap(onBus: 0)
            engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, when) in
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
        engine.mainMixerNode.volume = 0
        engine.mainMixerNode.removeTap(onBus: 0)
        engine.mainMixerNode.volume = 1
        guard let url = self.recordingUrl else { return }
        let destinationUrl = url.deletingPathExtension().appendingPathExtension("wav")
        AudioFileConverter.convert(sourceURL: url, destinationURL: destinationUrl)
        self.recordingUrl = nil
    }
    public func stop(){
        stopRecording()
    }
    //////////////////////////////////////////////////////////////////
    // MIDI
    //////////////////////////////////////////////////////////////////
    public func noteOn(_ note: UInt8, withVelocity velocity: UInt8, channel: UInt8) {
        if channel >= channelControllers.count { return }
        startEngineIfNeeded()
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
    public func set(timeStamp: UInt64){ //We don't actually know yet the right way to implement this.
        
    }
    /////////////////////////////////////////////////////////////////////
    //
    /////////////////////////////////////////////////////////////////////
    public var allPluginData : AllPluginData{
        get {
            let allData = AllPluginData()
            for channelController in channelControllers{
                let audioUnitData = channelController.getChannelPluginData()
                allData.channels.append(audioUnitData)
            }
            return allData
        }
        set {
            let allData = newValue
            for i in 0..<allData.channels.count{
                let channelPluginData = allData.channels[i]
                if i >= channelControllers.count {
                    let instrumentChannelController = InstrumentChannelController(delegate: self)
                    channelControllers.append(instrumentChannelController)
                }
                let channelController = channelControllers[i]
                channelController.set(channelPluginData:channelPluginData)
            }
        }
    }
    /////////////////////////////////////////////////////////////
    // Effects
    /////////////////////////////////////////////////////////////
    public func loadEffect(fromDescription desc: AudioComponentDescription, channel: Int, number: Int, type: ChannelType, completion: @escaping (Bool)->()) {
        if let channelController = getChannelController(type: type, channel: channel) {
            channelController.loadEffect(fromDescription: desc, number: number, completion: completion)
        }
    }
    func deselectEffect(channel: Int, number: Int, type: ChannelType) {
        if let channelController = getChannelController(type: type, channel: channel) {
            channelController.deselectEffect(number: number)
        }

    }
    func getAudioEffect(channel:Int, number: Int, type: ChannelType) -> AVAudioUnit?{
        if let channelController = getChannelController(type: type, channel: channel) {
            let effect = channelController.getEffect(number: number)
            return effect
        } else {
            return nil
        }
    }
    func getPluginSelection(channel: Int, channelType: ChannelType, pluginType: PluginType, pluginNumber: Int) -> PluginSelection? {
        if pluginType == .effect{
            if let effect = getAudioEffect(channel: channel, number: pluginNumber, type: channelType) {
                let manufacturer = effect.manufacturerName
                let name = effect.name
                let pluginSelection = PluginSelection(manufacturer: manufacturer, name: name)
                return pluginSelection
            } else {
                return nil
            }
        }
        return nil
    }
    func getChannelController(type: ChannelType, channel: Int) -> ChannelController? {
        if channel < 0 { return nil }
        if type == .master {
            return masterController
        } else if type == .midiInstrument{
            if channel >= channelControllers.count { return nil }
            let channelController = channelControllers[channel]
            return channelController
        } else if type == .aux {
            if channel >= auxControllers.count { return nil }
            let auxController = auxControllers[channel]
            return auxController
        }
        return nil
    }
    func load(viewController: NSViewController){
        delegate?.load(viewController: viewController)
    }
    /////////////////////////////////////////////////////////////
    //
    ///////////////////////////////////////////////////////////////
    fileprivate func startEngineIfNeeded() { //TODO: Move somewhere else
        if !engine.isRunning {
            do {
                print("Num inputs = \(engine.mainMixerNode.numberOfInputs)")
                if engine.attachedNodes.count > 0 {
                    try engine.start()
                    print("audio engine started")
                }
                
            } catch {
                print("oops \(error)")
                print("could not start audio engine")
            }
        }
    }
    public func render(musicSequence: MusicSequence, url: URL){
        engine.musicSequence = musicSequence
        var allMidiInstruments : [AVAudioUnit] = []
        for channel in channelControllers {
            if let audioUnit = channel.instrumentHost.audioUnit{
                allMidiInstruments.append(audioUnit)
            }
        }

        let sequencer = AVAudioSequencer(audioEngine: engine)
        let track = AVMusicTrack()
        track.destinationAudioUnit = channelControllers[0].instrumentHost.audioUnit
    }
}

extension AudioService : ChannelControllerDelegate{
    func log(_ message: String) {
        
    }
}



