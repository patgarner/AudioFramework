//
//  VirtualMixerModel.swift
//  Composer Bot Desktop
//
//  Created by Admin on 6/25/19.
//  Copyright © 2019 UltraMusician. All rights reserved.
//

import Foundation


public class ChannelRouter : Equatable{    
    private var numInputChannels = 0
    private var numOutputChannels = 0
    private var outputChannels : [Int] = []
    private var muteStatus : [Bool] = []

    public init(numInputChannels: Int, numOutputChannels: Int){
        self.numInputChannels = numInputChannels
        self.numOutputChannels = numOutputChannels
        for i in 0..<numInputChannels{
            outputChannels.append(i)
        }
        for _ in 0..<numInputChannels{
            muteStatus.append(false)
        }
    }
    public init(dictionary: [String:Any]){
        if let outputs = dictionary["outputChannels"] as? [Int]{
            outputChannels = outputs
        }
    }
    public var dictionary : [String:Any]{
        var dictionary : [String:Any] = [:]
        dictionary["outputChannels"] = outputChannels 
        return dictionary
    }
    public static func == (lhs: ChannelRouter, rhs: ChannelRouter) -> Bool {
        if lhs.outputChannels.count != rhs.outputChannels.count { return false }
        for i in 0..<lhs.outputChannels.count{
            if lhs.outputChannels[i] != rhs.outputChannels[i]{ return false }
        }
        return true
    }
    public func set(outputChannel: Int, inputChannel: Int) {
        outputChannels[inputChannel] = outputChannel
    }
    
    public func outputChannelFor(_ inputChannel: Int) -> Int?{
        if inputChannel >= outputChannels.count{
            print("Sorry, channel \(inputChannel) out of bounds.")
            return nil
        }
        let outputChannel = outputChannels[inputChannel]
        return outputChannel
    }
    public func isMuted(channel: Int) -> Bool {
        if channel >= muteStatus.count {
            return false
        }
        return muteStatus[channel]
    }
    public func setMute(_ muteEnabled : Bool, channel: Int){
        if channel >= muteStatus.count{
            return
        }
        muteStatus[channel] = muteEnabled
    }
}
