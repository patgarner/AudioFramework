//
//  ChannelController.swift
//
/*
 Copyright 2020 David Mann Music LLC
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import AVFoundation
import AppKit

public class ChannelController : ChannelViewDelegate {
    var delegate : ChannelControllerDelegate!
    weak var channelView : ChannelCollectionViewItem?
    var inputNode : AVAudioNode!
    private var effects : [AVAudioUnit] = []
    private weak var soloNode : UltraMixerNode!
    private weak var muteNode : UltraMixerNode!
    private weak var sendSplitterNode : UltraMixerNode!
    private var sendOutputs : [UltraMixerNode] = []
    private weak var volumeNode : UltraMixerNode!
    weak var outputNode : UltraMixerNode!
    //Model
    public var trackName = ""
    var id = UUID().uuidString
    public var solo : Bool = false {
        didSet {
            delegate.soloDidChange()
        }
    }
    var isSelected : Bool {
        get {
            if let channelView = channelView{
                return channelView.isSelected
            } else {
                return false
            }
        }
        set {
            if let channelView = channelView{
                channelView.isSelected = newValue
            }
        }
    }
    public init(delegate: ChannelControllerDelegate){
        self.delegate = delegate
        createIONodes()
        reconnectNodes()
    }
    public init(){
    }
    public func getChannelPluginData() -> ChannelModel{
        let channelPluginData = ChannelModel()
        for effect in effects{
            let effectPluginData = PluginData()
            effectPluginData.audioComponentDescription = effect.audioComponentDescription
            effectPluginData.state = effect.auAudioUnit.fullState
            channelPluginData.effectPlugins.append(effectPluginData)
        }
        for i in 0..<sendOutputs.count{
            let sendOutput = sendOutputs[i]
            let busInfo = delegate.getOutputDestination(for: sendOutput)
            let sendLevel = sendOutput.outputVolume
            let sendData = SendData(busNumber: busInfo.number, level: sendLevel)
            channelPluginData.sends.append(sendData)
        }
        let outputInfo = delegate.getOutputDestination(for: outputNode)
        channelPluginData.output.number = outputInfo.number
        channelPluginData.output.type = outputInfo.type
        channelPluginData.volume = volume
        channelPluginData.pan = outputNode.pan
        channelPluginData.trackName = trackName
        channelPluginData.id = id
        channelPluginData.mute = mute
        channelPluginData.solo = solo
        return channelPluginData
    }
    public func set(channelPluginData: ChannelModel){
        for effectNumber in 0..<channelPluginData.effectPlugins.count{
            let pluginData = channelPluginData.effectPlugins[effectNumber]
            loadEffect(pluginData: pluginData, number: effectNumber)
        }
        for i in 0..<channelPluginData.sends.count{
            let sendData = channelPluginData.sends[i]
            if i >= sendOutputs.count { break }
            let sendOutput = sendOutputs[i]
            sendOutput.outputVolume = sendData.level
            delegate.connect(sourceNode: sendOutput, destinationNumber: sendData.busNumber, destinationType: .bus)
        }
        delegate.connect(sourceNode: outputNode, destinationNumber: 0, destinationType: channelPluginData.output.type)
        volume = channelPluginData.volume
        outputNode.pan = channelPluginData.pan
        trackName = channelPluginData.trackName
        id = channelPluginData.id
        mute = channelPluginData.mute
        solo = channelPluginData.solo
    }
    func reconnectNodes(){
        let audioUnits = allAudioUnits()
        if audioUnits.count == 0 { return }
        disconnectNodes()
        for i in 1..<audioUnits.count{
            let previousUnit = audioUnits[i-1]
            let thisUnit = audioUnits[i]
            delegate.connect(sourceNode: previousUnit, destinationNode: thisUnit, bus: 0)
        }
        guard let sendSplitterNode = sendSplitterNode else { return }
        let format = sendSplitterNode.outputFormat(forBus: 0)
        var connectionPoints = delegate.engine.outputConnectionPoints(for: sendSplitterNode, outputBus: 0)
        for i in 0..<sendOutputs.count{
            let sendOutput = sendOutputs[i]
            let connectionPoint = AVAudioConnectionPoint(node: sendOutput, bus: 0)
            connectionPoints.append(connectionPoint)
        }
        delegate.engine.connect(sendSplitterNode, to: connectionPoints, fromBus: 0, format: format)
    }
    private func disconnectNodes(includeLast: Bool = false){
        let nodes = allAudioUnits()
        if nodes.count == 0 { return }
        for i in 0..<nodes.count-1{
            let node = nodes[i]
            disconnectOutput(audioUnit: node)
        }
        if includeLast, let node = nodes.last{
            disconnectOutput(audioUnit: node)
        }
    }
    private func allAudioUnits(includeSends: Bool = false) -> [AVAudioNode] {
        //The order determines the order in which they will be connected
        var audioUnits : [AVAudioNode] = []
        if inputNode != nil {
            audioUnits.append(inputNode!)
        }
        audioUnits.append(contentsOf: effects)
        if muteNode != nil {
            audioUnits.append(muteNode!)
        }
        if soloNode != nil{
            audioUnits.append(soloNode!)
        }
        if volumeNode != nil{
            audioUnits.append(volumeNode)
        }
        if sendSplitterNode != nil{
            audioUnits.append(sendSplitterNode!)
        }
        if includeSends{
            audioUnits.append(contentsOf: sendOutputs)
        }
        if outputNode != nil {
            audioUnits.append(outputNode)
        }
        return audioUnits
    }
    private func createIONodes() {
        let inputNode = AudioNodeFactory.mixerNode(name: "AudioInputNode")
        delegate.engine.attach(inputNode)
        self.inputNode = inputNode
        
        let dummyNode = AVAudioPlayerNode() //TODO: HACK ****************************
        delegate.engine.attach(dummyNode)
        delegate.connect(sourceNode: dummyNode, destinationNode: inputNode, bus: 1)
        
        let muteNode = AudioNodeFactory.mixerNode(name: "MuteNode")
        delegate.engine.attach(muteNode)
        self.muteNode = muteNode
        
        let soloNode = AudioNodeFactory.mixerNode(name: "SoloNode")
        delegate.engine.attach(soloNode)
        self.soloNode = soloNode
        
        let sendSplitterNode = AudioNodeFactory.mixerNode(name: "SendSplitter")
        delegate.engine.attach(sendSplitterNode)
        self.sendSplitterNode = sendSplitterNode
        
        let numSends = 2
        for i in 0..<numSends{
            let name = "Send Output \(i + 1)"
            let sendOutput = AudioNodeFactory.mixerNode(name: name)
            self.delegate.engine.attach(sendOutput)
            sendOutputs.append(sendOutput)
            sendOutput.outputVolume = 0.0
        }
        
        let volumeNode = AudioNodeFactory.mixerNode(name: "Volume")
        delegate.engine.attach(volumeNode)
        self.volumeNode = volumeNode
        
        let channelOutput = AudioNodeFactory.mixerNode(name: "ChannelOutput")
        delegate.engine.attach(channelOutput)
        self.outputNode = channelOutput
        
        let format = outputNode.outputFormat(forBus: 0)
        outputNode.installTap(onBus: 0, bufferSize: 2048, format: format) { (buffer, time) in
            let stereoDataUnsafePointer = buffer.floatChannelData!
            let monoPointer = stereoDataUnsafePointer.pointee
            let count = buffer.frameLength
            let bufferPointer = UnsafeBufferPointer(start: monoPointer, count: Int(count))
            let array = Array(bufferPointer)
            var peak : Float = 0
            for i in stride(from: 0, to: array.count, by: 20){
                let element = array[i]
                peak = max(element, peak)
            }
            self.channelView?.updateVUMeter(level: peak)
        }
    }
    private func disconnectOutput(audioUnit: AVAudioNode?){
        if let audioUnit = audioUnit{
            if delegate.engine.attachedNodes.contains(audioUnit){
                delegate.engine.disconnectNodeOutput(audioUnit)
            }
        }
    }
    public var mute : Bool {
        get {
            if muteNode == nil { return false }
            if muteNode!.outputVolume > 0 {
                return false
            } else {
                return true
            }
        }
        set {
            if muteNode == nil { return }
            if newValue == true {
                muteNode!.outputVolume = 0
            } else {
                muteNode!.outputVolume = 1
            }
        }
    }
    
    func setSoloVolume(on: Bool){
        guard let soloNode = soloNode else { return }
        if on {
            soloNode.outputVolume = 1.0
        } else {
            soloNode.outputVolume = 0.0
        }
    }
    
    public func displayInterface(type: PluginType, number: Int) {
        if type == .effect, let effect = getEffect(number: number) {
            delegate.displayInterface(audioUnit: effect)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Effects
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func loadEffect(pluginData: PluginData, number: Int){
        guard let audioComponentDescription = pluginData.audioComponentDescription else { return }
        loadEffect(fromDescription: audioComponentDescription, number: number, showInterface: false)
        if effects.count <= number { 
            delegate.log("ChannelController.loadEffect(pluginData) effects index out of bounds.")
            return
        }
        let effect = effects[number]
        let audioUnit = effect.auAudioUnit
        audioUnit.fullState = pluginData.state
        
    }
    public func loadEffect(fromDescription desc: AudioComponentDescription, number: Int, showInterface: Bool) {
        let contextBlock = AudioController.shared.contextBlock()
       // delegate.engine.stop()
        let audioUnitEffect = AudioNodeFactory.effect(description: desc, context: contextBlock) 
        set(effect: audioUnitEffect, number: number)
        reconnectNodes()
        if showInterface {
            delegate.displayInterface(audioUnit: audioUnitEffect)
        }
    }
    func set(effect: AVAudioUnit, number: Int){
        if number < effects.count { //There is already an effect there
            let existingEffect = effects[number]
            delegate.engine.disconnectNodeOutput(existingEffect)
            effects[number] = effect
            delegate.engine.detach(existingEffect)
            delegate.engine.attach(effect)
        } else if number == effects.count {
            effects.append(effect)
            delegate.engine.attach(effect)
        } else {
            print("Error: trying to add effect out of sequence")
        }
    }
    func getEffect(number: Int) -> AVAudioUnit?{
        if number >= effects.count || number < 0 {
            return nil
        }
        return effects[number]
    }
    
    public var pan : Float {
        get {
            return outputNode.pan
        }
        set {
            outputNode.pan = newValue
        }
    }
    func get(sendNumber: Int) -> AVAudioMixerNode?{
        if sendNumber < 0 || sendNumber >= sendOutputs.count {
            return nil
        }
        let sendOutput = sendOutputs[sendNumber]
        return sendOutput
    }
    func disconnectAll(){
        for node in allAudioUnits(includeSends: true){
            delegate.engine.disconnectNodeOutput(node)
            delegate.engine.detach(node)
        }
    }
    var midiIn : AVAudioUnit?{
        return nil
    }
    ///////////////////////////////////////////////////////////////////////////////
    // ChannelViewDelegate2
    ///////////////////////////////////////////////////////////////////////////////
    public func getAudioComponentList(type: PluginType) -> [AVAudioUnitComponent]{
        let list = delegate.getAudioComponentList(type: type)
        return list
    }
    public var volume : Float {
        get {
            return volumeNode.outputVolume
        }
        set {
            volumeNode.outputVolume = newValue
        }
    }
    public func deselectEffect(number: Int){
        if number < 0 || number >= effects.count{
            return
        }
        effects.remove(at: number)
        reconnectNodes()
    }
    public func deselectInstrument() {
        
    }
    public func getPluginSelection(pluginType: PluginType, pluginNumber: Int) -> PluginSelection? {
        if pluginType == .effect{
            guard let effect = getEffect(number: pluginNumber) else { return nil }
            let manufacturer = effect.manufacturerName
            let name = effect.name
            let pluginSelection = PluginSelection(manufacturer: manufacturer, name: name)
            return pluginSelection
        } else {
            return nil
        }
    }
    public func setSend(volume: Float, sendNumber: Int){
        if sendNumber < 0 || sendNumber >= sendOutputs.count { return }
        let sendOutput = sendOutputs[sendNumber]
        sendOutput.outputVolume = volume
    }
    public func getSendData(sendNumber: Int) -> SendData?{
        guard let sendOutput = get(sendNumber: sendNumber) else { return nil }
        let sendData = SendData(busNumber: -1, level: sendOutput.outputVolume) //TODO: Get actual bus number
        return sendData
    }
    
    public func getDestination(type: ConnectionType, number: Int) -> BusInfo{
        var sourceNode : AVAudioNode!
        if type == .output{
            sourceNode = outputNode
        } else if type == .send, let sendNode = get(sendNumber: number) {
            sourceNode = sendNode
        } else { 
            return BusInfo()
        }
        let destination = delegate.getOutputDestination(for: sourceNode)
        return destination
    }
    
    public func selectInput(busNumber: Int){ //Only Aux nodes need this
        guard let inputNode = inputNode else {
            delegate.log("ChannelController could not set input bus because input node is empty")
            return
        }
        delegate.connect(busNumber: busNumber, destinationNode: inputNode)
    }
    public func getBusInputNumber() -> Int?{
        guard let inputNode = inputNode else { return nil }
        let busNumber = delegate.getBusInput(for: inputNode)
        return busNumber
    }
    public func didSelectChannel() {
        delegate.didSelectChannel()
    }
    public func connect(sourceType: ConnectionType, sourceNumber: Int = 0, destinationType: BusType, destinationNumber: Int = 0){
        var sourceNode : AVAudioNode!
        if sourceType == .output{
            sourceNode = outputNode
        } else if sourceType == .send{
            guard let node = get(sendNumber: sourceNumber) else { return }
            sourceNode = node
        } else {
            return
        }
        delegate.connect(sourceNode: sourceNode!, destinationNumber: destinationNumber, destinationType: destinationType)
    }
    
    public var numBusses : Int { //Pass through
        return delegate.numBusses
    }
    public func select(description: AudioComponentDescription, type: PluginType, number: Int) {
        if type == .effect {
            //let contextBlock = delegate.contextBlock()
            let contextBlock = AudioController.shared.contextBlock()
            delegate.engine.stop()
            let audioUnit = AudioNodeFactory.effect(description: description, context: contextBlock) 
            set(effect: audioUnit, number: number)
            reconnectNodes()
            delegate.displayInterface(audioUnit: audioUnit)
        }
    }
    func visualize(){
        var string = ""
        if inputNode != nil {
            let busInput = delegate.getBusInput(for: inputNode!)
            let identity = identify(node: inputNode!)
            var inputString = "nil -> "
            if busInput != nil {
                inputString = "Bus \(busInput!) -> "
            }
            string += inputString + identity + "\n"
        }
        for audioUnit in allAudioUnits(includeSends: true){
            let sourceIdentity = identify(node: audioUnit)
            if !delegate.engine.attachedNodes.contains(audioUnit){
                print("ChannelController.Visualize Engine doesn't contain node.")
                continue
            }
            let connections = delegate.engine.outputConnectionPoints(for: audioUnit, outputBus: 0)
            for connection in connections {
                guard let destNode = connection.node else { continue }
                let destIdentity = identify(node: destNode)
                let sampleRate = destNode.inputFormat(forBus: connection.bus).sampleRate
                let thisConnection = sourceIdentity + " -> " + destIdentity + "\t\t\(sampleRate)\n"
                string += thisConnection
            }
            if connections.count == 0{
                let thisConnection = sourceIdentity + " -> nil\n"
                string += thisConnection
            }
        }
        print(string)
        delegate.log(string)
    }
    func identify(node : AVAudioNode) -> String {
        if let ultraMixer = node as? UltraMixerNode {
            return ultraMixer.name
        }
        if let midiInstrument = node as? AVAudioUnitMIDIInstrument{
            let string = midiInstrument.manufacturerName
            //let context = midiInstrument.auAudioUnit.musicalContextBlock
            return string
        }
        if node === inputNode {
            return "InputNode" 
        }
        for i in 0..<effects.count{
            let effect = effects[i]
            if node === effect {
                let string = "Audio Effect \(i)"
                return string
            }
        }
        for i in 0..<sendOutputs.count{
            let sendOutput = sendOutputs[i]
            if node === sendOutput {
                let string = "\tSend Output \(i)"
                return string
            }
        }
        return "Unidentified \(node.debugDescription)"
    }
    func set(musicalContextBlock : AUHostMusicalContextBlock?, transportBlock: AUHostTransportStateBlock? ){ 
        if inputNode != nil {
            inputNode.auAudioUnit.musicalContextBlock = musicalContextBlock
            inputNode.auAudioUnit.transportStateBlock = transportBlock
        }
        for effect in effects{
            effect.auAudioUnit.musicalContextBlock = musicalContextBlock
            effect.auAudioUnit.transportStateBlock = transportBlock
        }
    }
    func resetMeter(){
        channelView?.updateVUMeter(level: 0)
    }
    public func didReceiveSoloValueChange(gestureRect: CGRect, buttonType: DraggableButtonType, newState: NSControl.StateValue) {
        channelView?.soloValueChanges(gestureRect: gestureRect, buttonType: buttonType, newState: newState)
    }
    public func soloValueChanged(gestureRect: CGRect, buttonType: DraggableButtonType, newState: NSControl.StateValue) {
        delegate.soloValueChanges(gestureRect: gestureRect, buttonType: buttonType, newState: newState)
    }
}

public enum PluginType{
    case instrument
    case effect
}
