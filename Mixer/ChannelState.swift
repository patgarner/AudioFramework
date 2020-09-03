//
//  ChannelState.swift
//  Composer Bot Desktop
//
//  Created by Admin on 4/24/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public class ChannelState : Codable, Equatable{
    public var mute = false
    public var volume = 127
    public var trackName = ""
    public var solo = false
    public var pan = 64
    public static func == (lhs: ChannelState, rhs: ChannelState) -> Bool {
        if lhs.mute != rhs.mute { return false }
        if lhs.volume != rhs.volume { return false }
        if lhs.trackName != rhs.trackName { return false }
        if lhs.solo != rhs.solo { return false }
        if lhs.pan != rhs.pan { return false }
        return true
    }
}
