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

class ChannelController : ChannelViewDelegate {    
    var delegate : ChannelControllerDelegate!
    weak var channelView : ChannelCollectionViewItem?
    var inputNode : AVAudioNode? = nil
    public var effects : [AVAudioUnit] = []
    var sendSplitterNode : AVAudioMixerNode? = nil
    private var sendOutputs : [AVAudioMixerNode] = []
    var soloNode : AVAudioMixerNode? = nil
    var outputNode : AVAudioMixerNode!
    //Model
    var trackName = ""
    var id = UUID().uuidString
    var solo : Bool = false {
        didSet {
            delegate.soloDidChange()
        }
    }
    var isSelected : Bool {
        if let channelView = channelView{
            return channelView.isSelected
        } else {
            return false
        }
    }

    //
    public init(delegate: ChannelControllerDelegate){
        self.delegate = delegate
        createIONodes()
    }
    public init(){
    }
    func getChannelPluginData() -> ChannelPluginData{
        let channelPluginData = ChannelPluginData()
        for effect in effects{
            let effectPluginData = PluginData()
            effectPluginData.audioComponentDescription = effect.audioComponentDescription
            effectPluginData.state = effect.auAudioUnit.fullState
            channelPluginData.effectPlugins.append(effectPluginData)
        }
        for i in 0..<sendOutputs.count{
            let sendOutput = sendOutputs[i]
            var busNumber = -1
            if let number = AudioController.shared.getSendOutput(for: sendOutput){
                busNumber = number
            }
            let sendLevel = sendOutput.outputVolume
            let sendData = SendData(busNumber: busNumber, level: sendLevel)
            channelPluginData.sends.append(sendData)
        }
        channelPluginData.volume = outputNode.outputVolume
        channelPluginData.pan = outputNode.pan
        channelPluginData.trackName = trackName
        channelPluginData.id = id
        return channelPluginData
    }
    func set(channelPluginData: ChannelPluginData){
        for effectNumber in 0..<channelPluginData.effectPlugins.count{
            let pluginData = channelPluginData.effectPlugins[effectNumber]
            loadEffect(pluginData: pluginData, number: effectNumber)
        }
        for i in 0..<channelPluginData.sends.count{
            let sendData = channelPluginData.sends[i]
            if i >= sendOutputs.count { break }
            let sendOutput = sendOutputs[i]
            sendOutput.outputVolume = sendData.level
            delegate.setSendOutput(for: sendOutput, to: sendData.busNumber)
        }
        outputNode.outputVolume = channelPluginData.volume
        outputNode.pan = channelPluginData.pan
        trackName = channelPluginData.trackName
        id = channelPluginData.id
    }
    func reconnectNodes(){
        let audioUnits = allAudioUnits
        if audioUnits.count == 0 { return }
        disconnectNodes()
        let nodes = delegate.engine.attachedNodes
        for i in 1..<audioUnits.count{
            let previousUnit = audioUnits[i-1]
            let thisUnit = audioUnits[i]
            let format = previousUnit.outputFormat(forBus: 0)
            if nodes.contains(previousUnit), nodes.contains(thisUnit){
                delegate.engine.connect(previousUnit, to: thisUnit, format: format)
            } else {
                print("Sorry, engine needs to contain BOTH nodes it is connecting.")
            }
        }
        guard let sendSplitterNode = sendSplitterNode else { return }
        let format = sendSplitterNode.outputFormat(forBus: 0)
        //var connectionPoints : [AVAudioConnectionPoint] = []
        //let connectionPoint = AVAudioConnectionPoint(node: outputNode, bus: 0)
        //connectionPoints.append(connectionPoint)
        var connectionPoints = delegate.engine.outputConnectionPoints(for: sendSplitterNode, outputBus: 0)
        for i in 0..<sendOutputs.count{
            let sendOutput = sendOutputs[i]
            let connectionPoint = AVAudioConnectionPoint(node: sendOutput, bus: 0)
            connectionPoints.append(connectionPoint)
        }
        delegate.engine.connect(sendSplitterNode, to: connectionPoints, fromBus: 0, format: format)
    }
    func disconnectNodes(includeLast: Bool = false){
        let nodes = allAudioUnits
        if nodes.count == 0 { return }
        var lastIndex = nodes.count
        if !includeLast {
            lastIndex = nodes.count - 1
        }
        for i in 0..<lastIndex{
            let node = nodes[i]
            disconnectOutput(audioUnit: node)
        }
    }
    var allAudioUnits : [AVAudioNode] {
        assertionFailure("ChannelController.allAudioUnits() child class must override")
        return []
    }
    func disconnectOutput(audioUnit: AVAudioNode?){
        if let audioUnit = audioUnit{
            if delegate.engine.attachedNodes.contains(audioUnit){
                delegate.engine.disconnectNodeOutput(audioUnit)
            }
        }
    }
    var mute : Bool {
        get {
            if sendSplitterNode == nil { return false }
            if sendSplitterNode!.outputVolume > 0 {
                return false
            } else {
                return true
            }
        }
        set {
            if sendSplitterNode == nil { return }
            if newValue == true {
                sendSplitterNode!.outputVolume = 0
            } else {
                sendSplitterNode!.outputVolume = 1
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

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Effects
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func loadEffect(pluginData: PluginData, number: Int){
        guard let audioComponentDescription = pluginData.audioComponentDescription else { return }
        loadEffect(fromDescription: audioComponentDescription, number: number) { (success) in
            if !success { return }
            let effect = self.effects[number]
            let au = effect.auAudioUnit
            au.fullState = pluginData.state
        }
    }
    public func loadEffect(fromDescription desc: AudioComponentDescription, number: Int, completion: @escaping (Bool)->()) {
        let flags = AudioComponentFlags(rawValue: desc.componentFlags)
//        let canLoadInProcess = flags.contains(AudioComponentFlags.canLoadInProcess)
        //let loadOptions: AudioComponentInstantiationOptions = canLoadInProcess ? .loadInProcess : .loadOutOfProcess
//        let loadOptions : AudioComponentInstantiationOptions = .loadOutOfProcess
        AVAudioUnitEffect.instantiate(with: desc, options: []) { (avAudioUnit, error) in
            if let e = error {
                self.delegate?.log("Failed to load effect. Error: \(e)")
                completion(false)
            }
            guard let audioUnitEffect = avAudioUnit else { return }
            self.set(effect: audioUnitEffect, number: number)
            self.reconnectNodes()
            completion(true)
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
    func createIONodes() {
        let numSends = 2
        for _ in 0..<numSends{
            let sendOutput = AudioNodeFactory.mixerNode()
            self.delegate.engine.attach(sendOutput)
            sendOutputs.append(sendOutput)
            sendOutput.outputVolume = 0.0
        }
        let sendSplitterNode = AudioNodeFactory.mixerNode()
        self.delegate.engine.attach(sendSplitterNode)
        self.sendSplitterNode = sendSplitterNode
        
        let soloNode = AudioNodeFactory.mixerNode()
        self.delegate.engine.attach(soloNode)
        self.soloNode = soloNode
        
        let mixerOutput = AudioNodeFactory.mixerNode()
        self.delegate.engine.attach(mixerOutput)
        self.outputNode = mixerOutput
        
        let format = outputNode.outputFormat(forBus: 0)
        outputNode.installTap(onBus: 0, bufferSize: 2048, format: format) { (buffer, time) in
            let stereoDataUnsafePointer = buffer.floatChannelData!
            let monoPointer = stereoDataUnsafePointer.pointee
            let count = buffer.frameLength
            let bufferPointer = UnsafeBufferPointer(start: monoPointer, count: Int(count))
            let array = Array(bufferPointer)
            var peak : Float = 0
            for element in array { //We can probably just do every 10 samples or so
                peak = max(element, peak)
            }
            //self.vuMeterDelegate?.updateVUMeter(level: peak)
            self.channelView?.updateVUMeter(level: peak)
        }
    }
    var pan : Float {
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
        for node in allAudioUnits{
            delegate.engine.disconnectNodeOutput(node)
            delegate.engine.detach(node)
        }
        for sendOutput in sendOutputs{
            delegate.engine.disconnectNodeOutput(sendOutput)
            delegate.engine.detach(sendOutput)
        }
    }
    var midiIn : AVAudioUnit?{
        return nil
    }
    ///////////////////////////////////////////////////////////////////////////////
    // ChannelViewDelegate2
    ///////////////////////////////////////////////////////////////////////////////
    var volume : Float {
        get {
            return outputNode.outputVolume
        }
        set {
            outputNode.outputVolume = newValue
        }
    }
    func deselectEffect(number: Int){
        if number < 0 || number >= effects.count{
            return
        }
        effects.remove(at: number)
        reconnectNodes()
    }
    func getPluginSelection(pluginType: PluginType, pluginNumber: Int) -> PluginSelection? {
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
    func setSend(volume: Float, sendNumber: Int){
        if sendNumber < 0 || sendNumber >= sendOutputs.count { return }
        let sendOutput = sendOutputs[sendNumber]
        sendOutput.outputVolume = volume
    }
    func getSendData(sendNumber: Int) -> SendData?{
        guard let sendOutput = get(sendNumber: sendNumber) else { return nil }
        let sendData = SendData(busNumber: -1, level: sendOutput.outputVolume) //TODO: Get actual bus number
        return sendData
    }
    func select(sendNumber: Int, busNumber: Int, channel: Int, channelType: ChannelType) {
        guard let sendNode = get(sendNumber: sendNumber) else { return }
        delegate.setSendOutput(for: sendNode, to: busNumber)
    }
    func getSendOutput(sendNumber: Int) -> Int? {
        guard let sendNode = get(sendNumber: sendNumber) else { return nil}
        let sendOutput = delegate.getSendOutput(for: sendNode)
        return sendOutput
    }
    func selectInput(busNumber: Int){ //Only Aux nodes need this
        guard let inputNode = inputNode else { return }
        delegate.connectBusInput(to: inputNode, busNumber: busNumber)
    }
    func getBusInputNumber() -> Int?{
        guard let inputNode = inputNode else { return nil }
        let busNumber = delegate.getBusInput(for: inputNode)
        return busNumber
    }
    func displayInterface(type: PluginType, number: Int = 0){
        if type != .effect { return }
        if let effect = getEffect(number: number){
            delegate.displayInterface(audioUnit: effect.audioUnit)
        }
    }
    ////////////////////////////////////

}

public enum PluginType{
    case instrument
    case effect
}
