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
import CoreAudioKit

public class AudioController: NSObject {
    public static var shared = AudioController()
    public let engine = AVAudioEngine()
    public var delegate : AudioControllerDelegate?
    public var pluginDisplayDelegate : PluginDisplayDelegate?
    private var instrumentControllers : [InstrumentChannelController] = []
    private var auxControllers : [ChannelController] = []
    private var masterController : ChannelController!
    private var busses : [UltraMixerNode] = []
    private var sequencer : AVAudioSequencer!
    private let beatGenerator = BeatGenerator(tempo: 120)
    private var instrumentList : [AVAudioUnitComponent] = []
    private var effectList : [AVAudioUnitComponent] = []
    private var context : AUHostMusicalContextBlock!
    private var transportBlock : AUHostTransportStateBlock!
    private var isRendering = false
    var stemCreatorModel = StemCreatorModel()
    
    private override init (){
        super.init()
        initialize()
    }
    public func test(){
        let inst1 = instrumentControllers[0]
        if let instNode = inst1.inputNode as? AVAudioUnitMIDIInstrument {
            let context = instNode.auAudioUnit.musicalContextBlock
            if context == nil {
                print("context is nil")
            } else {
                print("context is not nil")
            }
        } else {
            print("Node == nil")
        }
    }
    private func initialize(){
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: format)
        context = getMusicalContext
        transportBlock = getTransportState
        createChannels(numInstChannels: 16, numAuxChannels: 2, numBusses: 4)
        var channelIds : [String] = []
        for instrumentController in instrumentControllers {
            channelIds.append(instrumentController.id)
        }
        stemCreatorModel.addDefaultStem(channelIds: [])
        sequencer = AVAudioSequencer(audioEngine: engine)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: NSNotification.Name.AVAudioEngineConfigurationChange,
            object: engine)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(displayMessage),
            name: .AudioControllerMessage,
            object: nil)
        populatePluginLists()
    }
    @objc private func displayMessage(notification: Notification){
        guard let string = notification.object as? String else { return }
        delegate?.log(string)
    }
    private func populatePluginLists(){
        var desc = AudioComponentDescription()
        desc.componentType = kAudioUnitType_MusicDevice
        instrumentList = AVAudioUnitComponentManager.shared().components(matching: desc).sorted(by: { (component1, component2) -> Bool in
            if component1.manufacturerName > component2.manufacturerName { return false }
            if component1.manufacturerName < component2.manufacturerName { return true }
            return component1.name < component2.name
        })
        desc.componentType = kAudioUnitType_Effect
        effectList = AVAudioUnitComponentManager.shared().components(matching: desc)
        desc.componentType = kAudioUnitType_MusicEffect
        let musicEffectList = AVAudioUnitComponentManager.shared().components(matching: desc)
        effectList.append(contentsOf: musicEffectList)
        effectList.sort(by: { (component1, component2) -> Bool in
            if component1.manufacturerName > component2.manufacturerName { return false }
            if component1.manufacturerName < component2.manufacturerName { return true }
            return component1.name < component2.name
        })
        effectList = effectList.filter { (component) -> Bool in
            if component.manufacturerName == "Waves" {
                return false
            } else {
                return true
            }
        }
    }
    @objc func handleInterruption(sender: Any){
        print("Engine interrupted.")
    }
    /////////////////////////////////////////////////////////////////////////
    // Context
    /////////////////////////////////////////////////////////////////////////
    func getMusicalContext(currentTempo : UnsafeMutablePointer<Double>?,
                           timeSignatureNumerator : UnsafeMutablePointer<Double>?,
                           timeSignatureDenominator : UnsafeMutablePointer<Int>?,
                           currentBeatPosition: UnsafeMutablePointer<Double>?,
                           sampleOffsetToNextBeat : UnsafeMutablePointer<Int>?,
                           currentMeasureDownbeatPosition: UnsafeMutablePointer<Double>?) -> Bool {
        let context = musicalContext
        currentTempo?.pointee = context.currentTempo
        timeSignatureNumerator?.pointee = context.timeSignatureNumerator
        timeSignatureDenominator?.pointee = context.timeSignatureDenominator
        currentBeatPosition?.pointee = context.currentBeatPosition
        sampleOffsetToNextBeat?.pointee = context.sampleOffsetToNextBeat
        currentMeasureDownbeatPosition?.pointee = context.currentMeasureDownbeatPosition
        return true
    }
    var musicalContext : MusicalContext {
        let context = MusicalContext()
        let barLength = 4.0 //TODO: Use actual meter
        context.currentTempo = beatGenerator.getTempo()
        context.timeSignatureNumerator = 4.0 //TODO
        context.timeSignatureDenominator = 4 //TODO
        var exactBeat = beatGenerator.exactBeat
        if isRendering {
            exactBeat = sequencer.currentPositionInBeats
        }
        context.currentBeatPosition = exactBeat
        let currentMeasure = floor(exactBeat / barLength) 
        let currentMeasureStart = currentMeasure * barLength
        context.currentMeasureDownbeatPosition = currentMeasureStart
        let beatsTillNextBeat = ceil(exactBeat) - exactBeat
        let timeTillNextBeat = 60.0 / context.currentTempo * beatsTillNextBeat
        let sampleRate = format.sampleRate
        let samplesTillNextBeat = Int(round(sampleRate * timeTillNextBeat))
        context.sampleOffsetToNextBeat = samplesTillNextBeat
        return context
    }
    private func setAllMusicalContextBlocks(){
        for channelController in allChannelControllers{
            channelController.set(musicalContextBlock: context, transportBlock: transportBlock)
        }
    }  
    func getTransportState(transportStateFlags : UnsafeMutablePointer<AUHostTransportStateFlags>?,
                           currentSamplePosition : UnsafeMutablePointer<Double>?,
                           cycleStartBeatPosition : UnsafeMutablePointer<Double>?,
                           cycleEndBeatPosition: UnsafeMutablePointer<Double>?) -> Bool {
        let exactBeat = beatGenerator.exactBeat
        let sampleRate = format.sampleRate
        let samplePosition = exactBeat / beatGenerator.getTempo() * 60.0 * sampleRate
        if beatGenerator.isPlaying || isRendering {
            transportStateFlags?.pointee = .moving
        } 
        currentSamplePosition?.pointee = samplePosition
        return false
    }
    ////////////////////////////////////////////////////////////////////////////
    //
    ////////////////////////////////////////////////////////////////////////////
    private func createChannels(numInstChannels: Int, numAuxChannels: Int, numBusses: Int){
        masterController = MasterChannelController(delegate: self)
        if let masterOutput = masterController.outputNode{
            connect(sourceNode: masterOutput, destinationNode: engine.mainMixerNode)
        }
        //Instrument Channels
        for _ in 0..<numInstChannels{
            let channelController = InstrumentChannelController(delegate: self)
            instrumentControllers.append(channelController)
            connectToMaster(channelController: channelController)
        }
        //Aux Channels
        for i in 0..<numAuxChannels{
            let auxController = AuxChannelController(delegate: self)
            auxController.trackName = "Aux " + String(i + 1)
            auxControllers.append(auxController)
            connectToMaster(channelController: auxController)
        }
        //Busses
        for i in 0..<numBusses{
            let name = "Bus \(i + 1)"
            let bus = AudioNodeFactory.mixerNode(name: name)
            engine.attach(bus)
            busses.append(bus)
        }
    }
    func isFirstNodeConnected(message: String){ //TODO: Remove
        if instrumentControllers.count == 0 {
            print(message + " ************InstrumentControllers empty.**********************")
            return
        }
        let channelController = instrumentControllers[0]
        if let input = channelController.inputNode{
            let outputConnections = engine.outputConnectionPoints(for: input, outputBus: 0)
            if outputConnections.count == 0 {
                print(message + "*************INPUT NODE DISCONNECTED*****************")
            } else {
                print(message + "******************INPUT node OK!!****************")
            }
        } else {
            print(message + "*****************INPUT node nil.**************")
        }
    }
    private func connectToMaster(channelController : ChannelController){
        if let channelOutput = channelController.outputNode, let masterInput = masterController.inputNode{
            connect(sourceNode: channelOutput, destinationNode: masterInput)
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
        engine.stop()
        removeAll()        
        createChannels(numInstChannels: audioModel.instrumentChannels.count, numAuxChannels: audioModel.auxChannels.count, numBusses: 4)
        masterController.set(channelPluginData: audioModel.masterChannel)
        let masterOutput = masterController.outputNode!
        connect(sourceNode: masterOutput, destinationNode: engine.mainMixerNode)
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
        masterController = nil
        for bus in busses {
            engine.disconnectNodeOutput(bus)
            engine.detach(bus)
        }
        busses.removeAll()
    }
    public func initDefault(){
        removeAll()
        createChannels(numInstChannels: 16, numAuxChannels: 2, numBusses: 4)
    }
    public func clearStems(){
        stemCreatorModel.removeAll()
    }
    private var allChannelControllers : [ChannelController]{
        var allControllers : [ChannelController] = []
        allControllers.append(contentsOf: instrumentControllers)
        allControllers.append(contentsOf: auxControllers)
        allControllers.append(masterController)
        return allControllers
    }
    func reconnectSelectedChannels(){
        for channelController in allChannelControllers{
            if channelController.isSelected {
                channelController.reconnectNodes()
            }
        }
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
    public func setController(number: UInt8, value: UInt8, channel: UInt8){
        if channel >= instrumentControllers.count { return }
        let channelController = instrumentControllers[Int(channel)]
        channelController.setController(number: number, value: value, channel: channel)
    }
    public func reset(){
        engine.reset()
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
        MidiAudioExporter.renderMidiOffline(sequencer: sequencer, engine: engine, audioDestinationURL: audioDestinationURL, includeMP3: true)
    }
    public func playFromSequence(midiSourceURL: URL){
        if !loadMidiSequence(from: midiSourceURL) { return }
        sequencer.prepareToPlay()
        do {
            try sequencer.start()
        } catch {
            delegate?.log("AudioConroller.playFromSequence failed.")
        }
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
    func loadMidiSequence(from url: URL) -> Bool{ //TODO: These are mostly identical. Refactor.
        do {
            try sequencer.load(from: url)
            if sequencer.tracks.count < 1 { return false }
            let tempoTrackOffset = 1 //If no tempo track, set to zero.
            for i in tempoTrackOffset..<sequencer.tracks.count{
                let track = sequencer.tracks[i]
                guard let channel = getChannelController(type: .midiInstrument, channel: i - tempoTrackOffset) else { continue }
                let destination = channel.midiIn
                track.destinationAudioUnit = destination
                let trackDestinationAudioUnit = track.destinationAudioUnit
                print("")
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
                channelController.disconnectAll()
                instrumentControllers.remove(at: i)
            }
        }
        for i in stride(from: auxControllers.count-1, through: 0, by: -1){
            let channelController = auxControllers[i]
            if channelController.isSelected{
                channelController.disconnectAll()
                auxControllers.remove(at: i)
            }
        }
    }
    public func visualize(){
        for channelController in allChannelControllers{
            if channelController.isSelected {
                channelController.visualize()
            }
        }
        var string = ""
        for busNumber in 0..<busses.count{
            string += "****************** BUS \(busNumber+1) *********************\n"
            let bus = busses[busNumber]
            string += "   =====INPUTS=====\n"
            for inputNumber in 0..<bus.numberOfInputs{
                let input = engine.inputConnectionPoint(for: bus, inputBus: inputNumber)
                if let node = input?.node {
                    if let ultraMixer = node as? UltraMixerNode {
                        string += "      \(inputNumber): \(ultraMixer.name)\n"
                    } else {
                        string += "      \(inputNumber): NoName\n"
                    }
                } 
            }
            string += "   =====OUTPUTS=====\n"
            let outputConnections = engine.outputConnectionPoints(for: bus, outputBus: 0)
            for outputNumber in 0..<outputConnections.count{
                let connection = outputConnections[outputNumber]
                if let node = connection.node {
                    if let ultraMixer = node as? UltraMixerNode {
                        string += "      \(outputNumber): \(ultraMixer.name)\n"
                    } else {
                        string += "      \(outputNumber): NoName"
                    }
                }                
            }
        }
        log(string)
    }
    //    public var sampleRate : Double {
    //        //let sr = engine.mainMixerNode.outputFormat(forBus: 0).sampleRate
    //        return 48000
    //    }
    func getSendDestination(sendNumber: Int, channelNumber: Int, channelType: ChannelType) -> BusInfo? { 
        guard let channelController = getChannelController(type: channelType, channel: channelNumber) else { return nil}
        guard let sendNode = channelController.get(sendNumber: sendNumber) else { return nil }
        let sendOutput = getOutputDestination(for: sendNode)
        return sendOutput
    }
    func select(sendNumber: Int, busNumber: Int, channel: Int, channelType: ChannelType){
        guard let channelController = getChannelController(type: channelType, channel: channel) else { return }
        guard let sendOutput = channelController.get(sendNumber: sendNumber) else { return }
        connect(sourceNode: sendOutput, destinationNumber: busNumber, destinationType: .bus)
    }
}

extension AudioController : ChannelControllerDelegate {
    public func getOutputDestination(for node: AVAudioNode) -> BusInfo{
        let connections = engine.outputConnectionPoints(for: node, outputBus: 0)
        if connections.count != 1 {
            return BusInfo()
        }
        guard let destinationNode = connections[0].node else { 
            return BusInfo()
        }
        if destinationNode === masterController.inputNode {
            return BusInfo(number: 0, type: .master)
        }
        for i in 0..<busses.count{
            let output = busses[i]
            if destinationNode === output {
                let busData = BusInfo(number: i, type: .bus)
                return busData
            }
        }
        return BusInfo()
    }
    public func log(_ message: String) {
        delegate?.log(message)
    }
    public func getBusInput(for node: AVAudioNode) -> Int? {
        guard let inputConnection = engine.inputConnectionPoint(for: node, inputBus: 0) else { return nil }
        guard let sourceNode = inputConnection.node else { return nil }
        for i in 0..<busses.count{
            let bus = busses[i]
            if sourceNode === bus { return i}
        }
        return nil
    }
    public func connect(busNumber : Int, destinationNode: AVAudioNode) {
        engine.disconnectNodeInput(destinationNode)
        if busNumber < 0 || busNumber >= busses.count { return }
        let sourceBus = busses[busNumber]
        //let format = sourceBus.outputFormat(forBus: 0)
        var connections = engine.outputConnectionPoints(for: sourceBus, outputBus: 0)
        for connection in connections{
            if let existingNode = connection.node, existingNode === destinationNode { return } //This connection already exists. Exit.
        }
        var destinationBusNumber : AVAudioNodeBus = 0
        if let mixer = destinationNode as? UltraMixerNode{
            destinationBusNumber = mixer.nextAvailableInputBus
        }
        let newConnection = AVAudioConnectionPoint(node: destinationNode, bus: destinationBusNumber)
        connections.append(newConnection)
        engine.connect(sourceBus, to: connections, fromBus: 0, format: format)
        if engine.isRunning { engine.pause() }
        
        if !isConnected(sourceNode: sourceBus, destinationNode: destinationNode){
            delegate?.log("Error: AudioController unable to connect bus to destination node.")
            for i in 0..<destinationNode.numberOfInputs{
                guard  let connection = engine.inputConnectionPoint(for: destinationNode, inputBus: i) else {
                    print("no input connection for bus \(i)")
                    continue
                }
                guard let node = connection.node else {
                    print("no node for connection \(i)")
                    continue
                }
                print("node: \(node)")
            }
        }
    }
    func isConnected(sourceNode: AVAudioNode, destinationNode: AVAudioNode) -> Bool {
        let connections = engine.outputConnectionPoints(for: sourceNode, outputBus: 0)
        for connection in connections {
            guard let node = connection.node else { continue }
            if node === destinationNode {
                return true
            }
        }
        let attachedNodes = engine.attachedNodes
        if !attachedNodes.contains(sourceNode) {
            delegate?.log("areConnected = false. SourceNode not attached to engine.")
        }
        if !attachedNodes.contains(destinationNode) {
            delegate?.log("areConnected = false. DestinationNode not attached to engine.")
        }
        return false
    }
    public func soloDidChange() {
        var soloMode = false
        for channelController in instrumentControllers{
            if channelController.solo {
                soloMode = true
                break
            }
        }
        var channelControllers : [ChannelController] = []
        channelControllers.append(contentsOf: instrumentControllers)
        channelControllers.append(contentsOf: auxControllers)
        for channelController in instrumentControllers {
            if soloMode{
                channelController.setSoloVolume(on: channelController.solo)
            }  else {
                channelController.setSoloVolume(on: true)
            }
        }
    }
    public func didSelectChannel(){
        for channel in allChannelControllers{
            channel.isSelected = false
        }
    }
    public var numBusses : Int{
        return busses.count
    }
    public func connect(sourceNode: AVAudioNode, destinationNumber: Int, destinationType: BusType){
        if engine.outputConnectionPoints(for: sourceNode, outputBus: 0).count > 0{
            engine.disconnectNodeOutput(sourceNode) 
        }
        if destinationNumber < 0 { return }
        guard let destinationNode = locateDestinationNode(type: destinationType, number: destinationNumber) else {
            print("Error: AudioController.connect(sourceNode, destinationNumber, destinationType) failed because it couldn't locate destination node.")
            return
        }
        engine.pause()
        connect(sourceNode: sourceNode, destinationNode: destinationNode)
        do {
            try engine.start()
        } catch {
            print("AudioController.connect(...) Coudn't start engine.")
        }
    }
    private func locateDestinationNode(type: BusType, number: Int) -> AVAudioNode? {
        var destinationNode : AVAudioNode?
        if type == .master{
            destinationNode = masterController.inputNode!
        } else if type == .bus{
            if number >= 0, number < busses.count { 
                destinationNode = busses[number]
            }
        } 
        return destinationNode
    }
    public func displayInterface(audioUnit: AVAudioUnit) {
        audioUnit.auAudioUnit.requestViewController { (viewController) in
            guard let auViewController = viewController as? AUViewController else {
                self.log("Error: AudioController.displayInterface viewController = nil")
                return
            }
            self.pluginDisplayDelegate?.display(viewController: auViewController)
        }
    }
    public func contextBlock() -> AUHostMusicalContextBlock {
        return context
    }
    public func connect(sourceNode: AVAudioNode, destinationNode: AVAudioNode, bus: Int? = nil) {
        let attachedNodes = engine.attachedNodes
        if !attachedNodes.contains(sourceNode){
            engine.attach(sourceNode)
        }
        if !attachedNodes.contains(destinationNode){
            engine.attach(destinationNode)
        }
        if bus == nil {
            engine.connect(sourceNode, to: destinationNode, format: format)
        } else {
            engine.connect(sourceNode, to: destinationNode, fromBus: 0, toBus: bus!, format: format)
        }
        if !isConnected(sourceNode: sourceNode, destinationNode: destinationNode){
            print("AudioController.connect() \(sourceNode) is not connected to \(destinationNode). Connection might be pending, meaning it will become active later.")
        }
    }
    public func getAudioComponentList(type: PluginType) -> [AVAudioUnitComponent]{
        if type == .instrument {
            return instrumentList
        } else if type == .effect {
            return effectList
        } else {
            return []
        }
    }
    private var format : AVAudioFormat{
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        return format
    }
    public func soloValueChanges(gestureRect: CGRect, buttonType: DraggableButtonType, newState: NSControl.StateValue) {
        allChannelControllers.forEach { channelController in
            channelController.didReceiveSoloValueChange(gestureRect: gestureRect, buttonType: buttonType, newState: newState)
        }
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Stems
///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
extension AudioController : StemViewDelegate { 
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
    public var numChannels: Int {
        return instrumentControllers.count
    }
    public func prepareForStemExport(destinationFolder: URL){
        guard let delegate = delegate else { return }
        for channelController in allChannelControllers{
            channelController.solo = false
            channelController.mute = false
        }
        let midiTempURL = destinationFolder.appendingPathComponent("temp.mid")
        delegate.exportMidi(to: midiTempURL)
        if !loadMidiSequence(from: midiTempURL) { return }
        isRendering = true
        setAllMusicalContextBlocks()
    }
    public func exportStem(to url: URL, includeMP3: Bool, number: Int, sampleRate: Int){
        MidiAudioExporter.renderMidiOffline(sequencer: sequencer, engine: engine, audioDestinationURL: url, includeMP3: includeMP3, delegate: self, number: number, sampleRate: sampleRate)
    }
    public func exportStem(to url: URL, number: Int, formats: [AudioFormat]) {
        MidiAudioExporter.renderMidiOffline(sequencer: sequencer, engine: engine, audioDestinationURL: url, delegate: self, number: number, formats: formats)
    }
    public func stemExportComplete() {
        self.isRendering = false
        for channelController in self.allChannelControllers{
            channelController.mute = false
        }
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
    public func cancelStemExport(){
        MidiAudioExporter.cancelOfflineRender(engine: engine)
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
extension AudioController: MidiAudioExporterDelegate{
    func willStartMidiAudioExport() {
        setAllMusicalContextBlocks()
    }
    public func set(progress: Double, number: Int){
        let numberProgress = (number, progress)
        NotificationCenter.default.post(name: .StemProgress, object: numberProgress) 
    }
}

extension AudioController : BeatInfoSource {
    public func set(tempo: Double){
        beatGenerator.set(tempo: tempo)
    }
    public var isPlaying : Bool { 
        return beatGenerator.isPlaying
    }
    public func start() {
        engine.stop()
        setAllMusicalContextBlocks()
        engine.prepare()
        do {
            try engine.start()
            beatGenerator.start()
        } catch {
            print("Failed to start engine.")
            return
        }
    }
    public func stop(){
        beatGenerator.stop()
        sequencer.stop()
        for channelController in allChannelControllers{
            channelController.resetMeter()
        }
    }
    public func add(beatListener: BeatDelegate){
        beatGenerator.addListener(beatListener)
    }
    public func removeBeatListeners(){
        beatGenerator.removeListeners()
    }
    
    public func playOffline(numBars: Int, barLength: Double){
        beatGenerator.playOffline(numBars: numBars, barLength: barLength)
    }
    public func playOffline(until: Double){
        beatGenerator.playOffline(until: until)
    }
    public var currentBeat : Double { 
        get {
            return beatGenerator.getCurrentBeat()
        }
        set {
            beatGenerator.goto(beat: newValue)
        }
    }
    public var exactBeat : Double { 
        return beatGenerator.exactBeat
    }
}



