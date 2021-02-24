//
//  MidiDestination.swift
//  AudioFramework
//
//  Created by Admin on 2/16/21.
//  Copyright © 2021 UltraMusician. All rights reserved.
//

import Foundation

public class MidiDestination : Codable, Equatable {
    public var trackId = ""
    public var trackNumber = 0
    public var channel = 0
    public init(){
        
    }
    public init(trackId: String, trackNumber: Int){
        self.trackId = trackId
        self.trackNumber = trackNumber
    }
    public static func == (lhs: MidiDestination, rhs: MidiDestination) -> Bool {
        return lhs.equals(rhs)
    }
    func equals(_ other: MidiDestination) -> Bool {
        if self.trackId != other.trackId { return false }
        if self.trackNumber != other.trackNumber { return false }
        if self.channel != other.channel { return false }
        return true
    }
    public func updateValuesWith(midiDestination: MidiDestination){
        self.trackId = midiDestination.trackId
        self.trackNumber = midiDestination.trackNumber
        self.channel = midiDestination.channel
    }
}
