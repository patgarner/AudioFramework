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

public class AudioController: NSObject {
    var timer = Timer()
    public static var shared = AudioController()
    var recordingUrl : URL?
    public let engine = AVAudioEngine()
    public var delegate : AudioControllerDelegate?
    private var instrumentControllers : [InstrumentChannelController] = []
    private var auxControllers : [ChannelController] = []
    private var masterController : ChannelController!
    private var busses : [AVAudioNode] = []
    private var stemCreatorModel = StemCreatorModel()
    private var sequencer : AVAudioSequencer!
    private override init (){
        super.init()
        initialize()
    }
    public func initialize(){
        sequencer = AVAudioSequencer(audioEngine: engine)
        createChannels(numInstChannels: 16, numAuxChannels: 4, numBusses: 10)
    }
    private func createChannels(numInstChannels: Int, numAuxChannels: Int, numBusses: Int){
        masterController = MasterChannelController(delegate: self)
        if let masterOutput = masterController.outputNode{
            let format = masterOutput.outputFormat(forBus: 0)
            engine.connect(masterOutput, to: engine.mainMixerNode, format: format)
        }
        //Instrument Channels
        for _ in 0..<numInstChannels{
            let channelController = InstrumentChannelController(delegate: self)
            instrumentControllers.append(channelController)
            connectToMaster(channelController: channelController)
        }
        //Aux Channels
        for _ in 0..<numAuxChannels{
            let auxController = AuxChannelController(delegate: self)
            auxControllers.append(auxController)
            connectToMaster(channelController: auxController)
        }
        //Busses
        for _ in 0..<numBusses{
            let bus = AudioNodeFactory.mixerNode()
            engine.attach(bus)
            busses.append(bus)
        }
    }
    private func connectToMaster(channelController : ChannelController){
        if let channelOutput = channelController.outputNode, let masterInput = masterController.inputNode{
            let format = channelOutput.outputFormat(forBus: 0)
            engine.connect(channelOutput, to: masterInput, format: format)
        }
    }
    func add(channelType: ChannelType){
        if channelType == .master { return }
        if channelType == .midiInstrument{
            let channelController = InstrumentChannelController(delegate: self)
            instrumentControllers.append(channelController)
            connectToMaster(channelController: channelController)
        } else if channelType == .aux{
            let channelController = AuxChannelController(delegate: self)
            auxControllers.append(channelController)
            connectToMaster(channelController: channelController)
        }
    }
    public func getAudioModel() -> AudioModel{
        let allData = AudioModel()
        for channelController in instrumentControllers{
            let channelData = channelController.getChannelPluginData()
            allData.instrumentChannels.append(channelData)
        }
        for auxController in auxControllers{
            let channelData = auxController.getChannelPluginData()
            allData.auxChannels.append(channelData)
        }
        let masterChannelData = masterController.getChannelPluginData()
        allData.masterChannel = masterChannelData
        allData.stemCreatorModel = stemCreatorModel 
        return allData
    }
    public func set(audioModel: AudioModel){
        removeAll()
        createChannels(numInstChannels: audioModel.instrumentChannels.count, numAuxChannels: audioModel.auxChannels.count, numBusses: 4)
        masterController.set(channelPluginData: audioModel.masterChannel)
        
        for i in 0..<audioModel.instrumentChannels.count{
            let channelPluginData = audioModel.instrumentChannels[i]
            let channelController = instrumentControllers[i]
            channelController.set(channelPluginData: channelPluginData)
        }
        for i in 0..<audioModel.auxChannels.count{
            let channelPluginData = audioModel.auxChannels[i]
            let channelController = auxControllers[i]
            channelController.set(channelPluginData: channelPluginData)
        }
        stemCreatorModel = audioModel.stemCreatorModel
    }
    private func removeAll(){
        for channelController in allChannelControllers{
            channelController.disconnectAll()
        }
        instrumentControllers.removeAll()
        auxControllers.removeAll()
        for bus in busses {
            engine.disconnectNodeOutput(bus)
            engine.detach(bus)
        }
        busses.removeAll()
    }
    private var allChannelControllers : [ChannelController]{
        var allControllers : [ChannelController] = []
        allControllers.append(contentsOf: instrumentControllers)
        allControllers.append(contentsOf: auxControllers)
        allControllers.append(masterController)
        return allControllers
    }
    public func loadInstrument(fromDescription desc: AudioComponentDescription, channel: Int, completion: @escaping (Bool)->()) {
        if channel >= instrumentControllers.count { return }
        let channelController = instrumentControllers[channel]
        channelController.loadInstrument(fromDescription: desc, completion: completion)
    }
    public func requestInstrumentInterface(channel: Int, _ completion: @escaping (InterfaceInstance?)->()) {
        if channel >= instrumentControllers.count { completion(nil) }
        let host = instrumentControllers[channel]
        host.requestInstrumentInterface(completion)
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
    
    public func set(pan: UInt8, channel: UInt8){ //TODO: MIDI Pan. Kill.
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
    
    /////////////////////////////////////////////////////////////
    // Effects
    /////////////////////////////////////////////////////////////
    public func loadEffect(fromDescription desc: AudioComponentDescription, channel: Int, number: Int, type: ChannelType, completion: @escaping (Bool)->()) {
        if let channelController = getChannelController(type: type, channel: channel) {
            channelController.loadEffect(fromDescription: desc, number: number, completion: completion)
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
    func getChannelControllerWith(id: String) -> ChannelController?{
        if masterController.id == id { return masterController }
        for instrumentController in instrumentControllers {
            if instrumentController.id == id {
                return instrumentController
            }
        }
        for auxController in auxControllers{
            if auxController.id == id { return auxController}
        }
        return nil
    }
    public func getTrackName(channel: Int, channelType: ChannelType) -> String?{
        guard let channelController = getChannelController(type: channelType, channel: channel) else { return nil }
        let trackName = channelController.trackName
        return trackName
    }
    public func isMuted(channel: Int, channelType: ChannelType) -> Bool{
        guard let channelController = getChannelController(type: channelType, channel: channel) else { return false }
        let mute = channelController.mute
        return mute
    }
    public func numTracks(channelType: ChannelType) -> Int{
        if channelType == .midiInstrument {
            return instrumentControllers.count
        } else if channelType == .aux {
            return auxControllers.count
        } else if channelType == .master {
            return 1
        }
        return 0
    }
    func load(viewController: NSViewController){
        delegate?.load(viewController: viewController)
    }
    /////////////////////////////////////////////////////////////
    //
    ///////////////////////////////////////////////////////////////
    fileprivate func startEngineIfNeeded() { //TODO: Move somewhere else
        if engine.isRunning { return }
        do {
            if engine.attachedNodes.count > 0 {
                try engine.start()
            }
        } catch {
            print("Could not start audio engine. Error: \(error)")
        }
    }
    public func renderAudio(midiSourceURL: URL, audioDestinationURL: URL){
        if !loadMidiSequence(from: midiSourceURL) { return }
        AudioExporter.renderMidiOffline(sequencer: sequencer, engine: engine, audioDestinationURL: audioDestinationURL, includeMP3: true)
    }
    func createMidiSequencer(url: URL) ->AVAudioSequencer?{
        let sequencer = AVAudioSequencer(audioEngine: engine)
        do {
            try sequencer.load(from: url)
            if sequencer.tracks.count < 1 { return sequencer }
            let tempoTrackOffset = 1 //If no tempo track, set to zero.
            for i in tempoTrackOffset..<sequencer.tracks.count{
                let track = sequencer.tracks[i]
                guard let channel = getChannelController(type: .midiInstrument, channel: i - tempoTrackOffset) else { continue }
                let destination = channel.midiIn
                track.destinationAudioUnit = destination
            }
        } catch {
            print("Connecting sequencer tracks to midi instrument channels failed: \(error)")
            return nil
        }
        return sequencer
    }
    func loadMidiSequence(from url: URL) -> Bool{
        do {
            try sequencer.load(from: url)
            if sequencer.tracks.count < 1 { return false }
            let tempoTrackOffset = 1 //If no tempo track, set to zero.
            for i in tempoTrackOffset..<sequencer.tracks.count{
                let track = sequencer.tracks[i]
                guard let channel = getChannelController(type: .midiInstrument, channel: i - tempoTrackOffset) else { continue }
                let destination = channel.midiIn
                track.destinationAudioUnit = destination
            }
        } catch {
            print("Connecting sequencer tracks to midi instrument channels failed: \(error)")
            return  false
        }
        return true
    }
    func deleteSelectedChannels(){
        for i in stride(from: instrumentControllers.count-1, through: 0, by: -1){
            let channelController = instrumentControllers[i]
            if channelController.isSelected{
                instrumentControllers.remove(at: i)
            }
        }
        for i in stride(from: auxControllers.count-1, through: 0, by: -1){
            let channelController = auxControllers[i]
            if channelController.isSelected{
                auxControllers.remove(at: i)
            }
        }
    }
}

extension AudioController : PluginSelectionDelegate{
    func selectInstrument(_ inst: AVAudioUnitComponent, channel: Int, type: ChannelType){}
    func select(effect: AVAudioUnitComponent, channel: Int, number: Int, type: ChannelType){}
    func displayInstrumentInterface(channel: Int){}
    func displayEffectInterface(channel: Int, number: Int, type: ChannelType){}
    func numBusses() -> Int{
        return busses.count
    }
    func getSendOutput(sendNumber: Int, channelNumber: Int, channelType: ChannelType) -> Int? { //TODO: Remove
        guard let channelController = getChannelController(type: channelType, channel: channelNumber) else { return nil}
        guard let sendNode = channelController.get(sendNumber: sendNumber) else { return nil }
        let sendOutput = getSendOutput(for: sendNode)
        return sendOutput
    }
    func select(sendNumber: Int, busNumber: Int, channel: Int, channelType: ChannelType){
        guard let channelController = getChannelController(type: channelType, channel: channel) else { return }
        guard let sendOutput = channelController.get(sendNumber: sendNumber) else { return }
        setSendOutput(for: sendOutput, to: busNumber)
    }
}

extension AudioController : ChannelControllerDelegate {
    func getSendOutput(for node: AVAudioNode) -> Int?{
        let connections = engine.outputConnectionPoints(for: node, outputBus: 0)
        if connections.count != 1 { return nil }
        guard let connectionNode = connections[0].node else { return nil }
        for i in 0..<busses.count{
            let bus = busses[i]
            if connectionNode === bus { return i }
        }
        return nil
    }
    func setSendOutput(for node: AVAudioNode, to busNumber: Int){
        if engine.outputConnectionPoints(for: node, outputBus: 0).count > 0{
            engine.disconnectNodeOutput(node) 
        }
        if busNumber < 0 || busNumber >= busses.count { 
            return
        }
        let bus = busses[busNumber]
        let format = node.outputFormat(forBus: 0)
        engine.connect(node, to: bus, format: format)
    }
    
    func log(_ message: String) {
        delegate?.log(message)
    }
    func getBusInput(for node: AVAudioNode) -> Int? {
        guard let inputConnection = engine.inputConnectionPoint(for: node, inputBus: 0) else { return nil }
        guard let sourceNode = inputConnection.node else { return nil }
        for i in 0..<busses.count{
            let bus = busses[i]
            if sourceNode === bus { return i}
        }
        return nil
    }
    func connectBusInput(to node: AVAudioNode, busNumber: Int) {
        engine.disconnectNodeInput(node)
        if busNumber < 0 || busNumber >= busses.count { return }
        let bus = busses[busNumber]
        let format = bus.outputFormat(forBus: 0)
        var connections = engine.outputConnectionPoints(for: bus, outputBus: 0)
        for connection in connections{
            if let existingNode = connection.node, existingNode === node { return } //This connection already exists. Exit.
        }
        let newConnection = AVAudioConnectionPoint(node: node, bus: 0)
        connections.append(newConnection)
        engine.connect(bus, to: connections, fromBus: 0, format: format)
    }
    func displayInterface(audioUnit: AudioUnit) {
        print("")
    }
    func soloDidChange() {
        var soloMode = false
        for channelController in allChannelControllers{
            if channelController.solo {
                soloMode = true
            }
        }
        for channelController in allChannelControllers{
            if soloMode{
                channelController.setSoloVolume(on: channelController.solo)
            }  else {
                channelController.setSoloVolume(on: true)
            }
        }
    }
}

extension AudioController : StemViewDelegate { 
    //Mark: AudioController
    public var numChannels: Int {
        return instrumentControllers.count
    }
    public func getNameFor(channelId: String) -> String? {
        guard let channelController = getChannelControllerWith(id: channelId) else { return nil }
        let name = channelController.trackName
        return name
    }
    public func getIdFor(channel: Int) -> String?{
        guard let channelController = getChannelController(type: .midiInstrument, channel: channel) else { return nil }
        let id = channelController.id
        return id
    }
    
    //MARK : StemCreatorModel
    public func setName(stemNumber: Int, name: String){
        stemCreatorModel.setName(stemNumber: stemNumber, name: name)
    }
    public var numStems: Int {
        let stems = stemCreatorModel.numStems
        return stems
    }
    public func getNameFor(stem: Int) -> String?{
        let name = stemCreatorModel.getNameFor(stem: stem)
        return name
    }
    public func addStem(){
        stemCreatorModel.addStem()
    }
    public func selectionChangedTo(selected: Bool, stemNumber: Int, channelId: String) {
        stemCreatorModel.selectionChangedTo(selected: selected, stemNumber: stemNumber, channelId: channelId)
    }
    public func isSelected(stemNumber: Int, channelId: String) -> Bool {
        let selected = stemCreatorModel.isSelected(stemNumber: stemNumber, channelId: channelId)
        return selected
    }
    public func delete(stemNumber: Int){
        stemCreatorModel.delete(stemNumber: stemNumber)
    }
    public func exportStems(destinationFolder: URL){
        guard let delegate = delegate else { return }
        let midiTempURL = destinationFolder.appendingPathComponent("temp.mid")
        delegate.exportMidi(to: midiTempURL)
        if !loadMidiSequence(from: midiTempURL) { return }
        let stemCreator = StemCreator(delegate: self)
        stemCreator.createStems(model: stemCreatorModel, folder: destinationFolder)
    }
    public var namePrefix: String {
        get {
            return stemCreatorModel.namePrefix
        } 
        set {
            stemCreatorModel.namePrefix = newValue
        }
    }
}

extension AudioController : StemCreatorDelegate{
    public func set(mute: Bool, for channelId: String) {
        guard let channelController = getChannelControllerWith(id: channelId) else { return }
        channelController.mute = mute
    }
    public func muteAllExcept(channelIds: [String]) {
        for channelController in instrumentControllers{
            if channelIds.contains(channelController.id){
                channelController.mute = false
            } else {
                channelController.mute = true
            }
        }
    }
    public func exportStem(to url: URL, includeMP3: Bool){
        AudioExporter.renderMidiOffline(sequencer: sequencer, engine: engine, audioDestinationURL: url, includeMP3: includeMP3)
    }
}



