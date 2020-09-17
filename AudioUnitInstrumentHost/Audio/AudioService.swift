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
    public var delegate : AudioServiceDelegate!
    private var instrumentControllers : [InstrumentChannelController] = []
    private var auxControllers : [ChannelController] = []
    private var masterController : ChannelController!
    private var busses : [AVAudioNode] = []
    private override init (){
        super.init()
    }
    public func initialize(){
        masterController = MasterChannelController(delegate: self)
        if let masterOutput = masterController.outputNode{
            let format = masterOutput.outputFormat(forBus: 0)
            engine.connect(masterOutput, to: engine.mainMixerNode, format: format)
        }
        if delegate == nil { return }
        //Instrument Channels
        for _ in 0..<1{ //TODO: Get num channels from delegate
            let channelController = InstrumentChannelController(delegate: self)
            channelController.delegate = self
            instrumentControllers.append(channelController)
            if let channelOutput = channelController.outputNode, let masterInput = masterController.inputNode{
                let format = channelOutput.outputFormat(forBus: 0)
                engine.connect(channelOutput, to: masterInput, format: format)
            }
        }
        //Aux Channels
        for _ in 0..<2{
            let auxController = AuxChannelController(delegate: self)
            auxController.delegate = self
            auxController.type = .aux
            auxControllers.append(auxController)
            if let channelOutput = auxController.outputNode, let masterInput = masterController.inputNode{
                let format = channelOutput.outputFormat(forBus: 0)
                engine.connect(channelOutput, to: masterInput, format: format)
            }
        }
        //Busses
        for _ in 0..<4{
            let bus = AudioNodeFactory.mixerNode()
            engine.attach(bus)
            busses.append(bus)
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
        if channel >= instrumentControllers.count { return }
        let channelController = instrumentControllers[channel]
        channelController.loadInstrument(fromDescription: desc, completion: completion)
        print("")
    }
    public func requestInstrumentInterface(channel: Int, _ completion: @escaping (InterfaceInstance?)->()) {
        if channel >= instrumentControllers.count { completion(nil) }
        let host = instrumentControllers[channel]
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
        if channel >= instrumentControllers.count { return }
        startEngineIfNeeded()
        let channelController = instrumentControllers[Int(channel)]
        channelController.noteOn(note, withVelocity: velocity, channel: channel)
    }
    
    public func noteOff(_ note: UInt8, channel: UInt8) {
        if channel >= instrumentControllers.count { return }
        let channelController = instrumentControllers[Int(channel)]
        channelController.noteOff(note, channel: channel)
    } 
    public func set(volume: Float, channel: Int, channelType: ChannelType){
        guard let channelController = getChannelController(type: channelType, channel: channel) else { return }
        channelController.volume = volume
    }
    public func set(pan: UInt8, channel: UInt8){
        if channel >= instrumentControllers.count { return }
        let channelController = instrumentControllers[Int(channel)]
        channelController.set(pan: pan, channel: channel)
    }
    public func set(tempo: UInt8){
        for channel in 0..<instrumentControllers.count{
            let host = instrumentControllers[channel]
            host.set(tempo: tempo)
        }
    }
    public func setController(number: UInt8, value: UInt8, channel: UInt8){
        if channel >= instrumentControllers.count { return }
        let channelController = instrumentControllers[Int(channel)]
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
            for channelController in instrumentControllers{
                let audioUnitData = channelController.getChannelPluginData()
                allData.channels.append(audioUnitData)
            }
            return allData
        }
        set {
            let allData = newValue
            for i in 0..<allData.channels.count{
                let channelPluginData = allData.channels[i]
                if i >= instrumentControllers.count {
                    let instrumentChannelController = InstrumentChannelController(delegate: self)
                    instrumentControllers.append(instrumentChannelController)
                }
                let channelController = instrumentControllers[i]
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
        guard let channelController = getChannelController(type: channelType, channel: channel) else { return nil }
        let pluginSelection = channelController.getPluginSelection(pluginType: pluginType, pluginNumber: pluginNumber)
        return pluginSelection
    }
    ////////////////////////////////////////////////////////////
    func getChannelController(type: ChannelType, channel: Int) -> ChannelController? {
        if channel < 0 { return nil }
        if type == .master {
            return masterController
        } else if type == .midiInstrument{
            if channel >= instrumentControllers.count { return nil }
            let channelController = instrumentControllers[channel]
            return channelController
        } else if type == .aux {
            if channel >= auxControllers.count { return nil }
            let auxController = auxControllers[channel]
            return auxController
        }
        return nil
    }
    func load(viewController: NSViewController){
        delegate.load(viewController: viewController)
    }
    /////////////////////////////////////////////////////////////
    //
    ///////////////////////////////////////////////////////////////
    fileprivate func startEngineIfNeeded() { //TODO: Move somewhere else
        if !engine.isRunning {
            do {
                if engine.attachedNodes.count > 0 {
                    try engine.start()
                }
            } catch {
                print("Could not start audio engine. Error: \(error)")
            }
        }
    }
    public func render(musicSequence: MusicSequence, url: URL){}
    func select(sendNumber: Int, busNumber: Int, channel: Int, channelType: ChannelType){
        guard let channelController = getChannelController(type: channelType, channel: channel) else { return }
        let sendOutput = channelController.sendOutputs[sendNumber]
        if engine.outputConnectionPoints(for: sendOutput, outputBus: 0).count > 0{
            engine.disconnectNodeOutput(sendOutput) 
        }
        if busNumber < 0 || busNumber >= busses.count { 
            return
        }
        let bus = busses[busNumber]
        let format = sendOutput.outputFormat(forBus: 0)
        engine.connect(sendOutput, to: bus, format: format)
    }
    func numBusses() -> Int{
        return busses.count
    }
    func selectInputBus(number: Int, channel: Int, channelType: ChannelType) {
        guard let channelInput = getChannelController(type: channelType, channel: channel)?.inputNode else { return }
        engine.disconnectNodeInput(channelInput)
        if number < 0 || number >= busses.count { return }
        let bus = busses[number]
        let format = bus.outputFormat(forBus: 0)
        engine.connect(bus, to: channelInput, format: format)
    }
    func setSend(volume: Double, sendNumber: Int, channelNumber: Int, channelType: ChannelType) {
        guard let channelController = getChannelController(type: channelType, channel: channelNumber) else { return }
        channelController.setSend(volume: volume, number: sendNumber)
    }
    func getSendOutput(sendNumber: Int, channelNumber: Int, channelType: ChannelType) -> Int? {
        guard let channelController = getChannelController(type: channelType, channel: channelNumber) else { return nil}
        if sendNumber < 0 || sendNumber >= channelController.sendOutputs.count { return nil }
        let sendNode = channelController.sendOutputs[sendNumber]
        let connections = engine.outputConnectionPoints(for: sendNode, outputBus: 0)
        if connections.count != 1 { return nil }
        guard let connectionNode = connections[0].node else { return nil }
        for i in 0..<busses.count{
            let bus = busses[i]
            if connectionNode === bus { return i }
        }
        return nil
    }
    func getBusInputNumber(channelNumber: Int, channelType: ChannelType) -> Int?{
        if channelType != .aux { return nil }
        guard let channelController = getChannelController(type: channelType, channel: channelNumber) else { return nil }
        guard let channelInput = channelController.inputNode else { return nil }
        guard let inputConnection = engine.inputConnectionPoint(for: channelInput, inputBus: 0) else { return nil }
        guard let sourceNode = inputConnection.node else { return nil}
        for b in 0..<busses.count{
            let bus = busses[b]
            if sourceNode === bus { return b }
        }
        return nil
    }

}

extension AudioService : ChannelControllerDelegate{
    func log(_ message: String) {
        delegate.log(message)
    }
}



