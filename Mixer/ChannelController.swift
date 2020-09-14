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

class ChannelController {
    var delegate : ChannelControllerDelegate!
    var type : ChannelType = .midiInstrument
    public var effects : [AVAudioUnit] = []
    var inputNode : AVAudioNode? = nil
    var outputNode : AVAudioNode? = nil
    public init(delegate: ChannelControllerDelegate){
        self.delegate = delegate
        createIONodes()
    }
    public init(type: ChannelType){
        self.type = type
    }
    func getChannelPluginData() -> ChannelPluginData{
        let channelPluginData = ChannelPluginData()
             for effect in effects{
                 let effectPluginData = PluginData()
                 effectPluginData.audioComponentDescription = effect.audioComponentDescription
                 effectPluginData.state = effect.auAudioUnit.fullState
                 channelPluginData.effectPlugins.append(effectPluginData)
             }
             return channelPluginData
    }
    func set(channelPluginData: ChannelPluginData){
         for effectNumber in 0..<channelPluginData.effectPlugins.count{
             let pluginData = channelPluginData.effectPlugins[effectNumber]
             loadEffect(pluginData: pluginData, number: effectNumber)
         }
    }
    func connectEverything(){
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
        //delegate?.updateChannelOutput(avAudioNode: audioUnits.last!)
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
        let canLoadInProcess = flags.contains(AudioComponentFlags.canLoadInProcess)
        let loadOptions: AudioComponentInstantiationOptions = canLoadInProcess ? .loadInProcess : .loadOutOfProcess
        AVAudioUnitEffect.instantiate(with: desc, options: loadOptions) { (avAudioUnit, error) in
            if let e = error {
                self.delegate?.log("Failed to load effect. Error: \(e)")
                completion(false)
            }
            guard let audioUnitEffect = avAudioUnit else { return }
            self.set(effect: audioUnitEffect, number: number)
            self.connectEverything()
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
        if number >= effects.count {
            return nil
        }
        return effects[number]
    }
    func createIONodes() {
        assertionFailure("ChannelController child must override createIONodes()")
    }
}

protocol ChannelControllerDelegate{
    func log(_ message: String)
    var engine : AVAudioEngine { get }
}

enum PluginType{
    case instrument
    case effect
}
