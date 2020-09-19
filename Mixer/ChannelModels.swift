//
//  ChannelStates.swift
//
/*
 Copyright 2020 David Mann Music LLC
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

public class ChannelModels : Codable, Equatable, ChannelViewDelegate{
    var channels : [ChannelModel] = []
    var aux : [ChannelModel] = []
    var master : ChannelModel = ChannelModel()
    public init(){
        initialize()
    }
    private func initialize(){
        for _ in 0..<1 {
            let channel = ChannelModel()
            channels.append(channel)
        }
        for _ in 0..<2 {
            let channel = ChannelModel()
            aux.append(channel)
        }
    }
    public func setTrackName(trackNumber: Int, name: String) {
        let channel = channels[trackNumber]
        channel.trackName = name
    }
    public func getTrackName(_ trackNumber: Int) -> String? {
        let channel = channels[trackNumber]
        return channel.trackName
    }
    
    public func setMute(_ muteEnabled: Bool, trackNumber: Int) {
        let channel = channels[trackNumber]
        channel.mute = muteEnabled
    }
    
    public func isMuted(trackNumber: Int) -> Bool {
        let channel = channels[trackNumber]
        return channel.mute
    }
    
    public static func == (lhs: ChannelModels, rhs: ChannelModels) -> Bool {
        if lhs.channels.count != rhs.channels.count { return false }
        for i in 0..<lhs.channels.count{
            if lhs.channels[i] != rhs.channels[i] { return false }
        }
        return true
    }
    public func numChannels(type: ChannelType) -> Int{
        if type == .master{
            return 1
        } else if type == .midiInstrument{
            return channels.count
        } else if type == .aux {
            return aux.count
        }
        return 0
    }
    public func getChannelState(_ index: Int, type: ChannelType) -> ChannelModel? {
        var state : ChannelModel? = nil
        if type == .midiInstrument{
            if index < 0 || index >= channels.count {
                return nil
            }
            state = channels[index]
        } else if type == .master{
            state = master
        } else if type == .aux{
            if index < 0 || index >= aux.count {
                 return nil
             }
            state = aux[index]
        }
        return state
    }
    public func set(channelState: ChannelModel, index: Int){
        channels[index] = channelState
    }
    public func reset(){
        for channel in channels {
            channel.mute = false
//            channel.volume = 127
            channel.trackName = ""
        }
    }
//    public func set(volume: Float, channel: Int, channelType: ChannelType) {}
//    public func getVolume(channel: Int, channelType: ChannelType) -> Float {
//        return 1.0
//    }
    public func getPan(channel: Int, channelType: ChannelType) -> Float {
        return 0.0
    }
    public func set(pan: Float, channel: Int, channelType: ChannelType){}

}
