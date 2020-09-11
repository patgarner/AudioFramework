//
//  ChannelRouter.swift
//
/*
 Copyright 2020 David Mann Music LLC
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
