//
//  ChannelState.swift
//  Composer Bot Desktop
//
//  Created by Admin on 4/24/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

public class ChannelState : Codable, Equatable{
    public var mute = false
    public var volume = 127
    public var trackName = ""
    public var solo = false
    public var pan = 64
    public var number = 0
    public var virtualInstrument = PluginSelection()
    private var effects : [PluginSelection] = []
    public static func == (lhs: ChannelState, rhs: ChannelState) -> Bool {
        if lhs.mute != rhs.mute { return false }
        if lhs.volume != rhs.volume { return false }
        if lhs.trackName != rhs.trackName { return false }
        if lhs.solo != rhs.solo { return false }
        if lhs.pan != rhs.pan { return false }
        if lhs.virtualInstrument != rhs.virtualInstrument { return false }
        if lhs.effects != rhs.effects { return false }
        return true
    }
    func set(effect: PluginSelection, number: Int){
        while effects.count <= number {
            effects.append(PluginSelection())
        }
        effects[number] = effect
    }
    func getEffect(number: Int) -> PluginSelection?{
        if number >= effects.count { return nil }
        if number < 0 { return nil }
        return effects[number]
    }
}

public struct PluginSelection : Codable, Equatable{
    public var manufacturer = ""
    public var name = ""
}
