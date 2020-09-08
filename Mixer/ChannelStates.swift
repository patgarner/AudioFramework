//
//  ChannelStates.swift
//  Composer Bot Desktop
//
//  Created by Admin on 4/24/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

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
