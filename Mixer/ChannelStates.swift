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

public class ChannelStates : Codable, Equatable, ChannelViewDelegate{
    var channels : [ChannelState] = []
    public init(){
        initialize()
    }
    private func initialize(){
        for _ in 0..<16 {
            let channel = ChannelState()
            channels.append(channel)
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
    
    public static func == (lhs: ChannelStates, rhs: ChannelStates) -> Bool {
        if lhs.channels.count != rhs.channels.count { return false }
        for i in 0..<lhs.channels.count{
            if lhs.channels[i] != rhs.channels[i] { return false }
        }
        return true
    }
    public var count : Int {
        return channels.count
    }
    public func getChannelState(_ index: Int) -> ChannelState? {
        if index < 0 || index >= channels.count {
            return nil
        }
        let state = channels[index]
        return state
    }
    public func set(channelState: ChannelState, index: Int){
        channels[index] = channelState
    }
    public func reset(){
        for channel in channels {
            channel.mute = false
            channel.volume = 127
            channel.trackName = ""
        }
    }
    public func setMasterVolume(_ volume: Float) {}
    public func set(volume: Int, channel: Int) {}
    
}
