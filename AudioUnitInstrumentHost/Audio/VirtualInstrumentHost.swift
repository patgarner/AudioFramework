//
//  InstrumentHost.swift
//  AUInstHostTest
//
//  Created by acb on 04/12/2017.
//  Copyright © 2017 acb. All rights reserved.
//

import Cocoa
import AVFoundation

public enum InterfaceInstance {
    case view(NSView)
    case viewController(NSViewController)
}

protocol VirtualInstrumentHost {
    func loadInstrument(fromDescription desc: AudioComponentDescription, context: @escaping AUHostMusicalContextBlock/*, completion: @escaping (Bool)->()*/)
    func noteOn(_ note: UInt8, withVelocity velocity: UInt8, channel: UInt8)
    func noteOff(_ note: UInt8, channel: UInt8)
    func set(volume: UInt8, channel: UInt8)
    func set(pan: UInt8, channel: UInt8)
    func setController(number: UInt8, value: UInt8, channel: UInt8)
    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->())
    var fullState : [String : Any]? { get set }
    var samplerData : PluginData { get set }
    var audioUnit : AVAudioUnit? { get }
}
