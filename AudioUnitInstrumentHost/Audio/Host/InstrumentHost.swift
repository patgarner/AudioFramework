//
//  InstrumentHost.swift
//  AUInstHostTest
//
//  Created by acb on 04/12/2017.
//  Copyright © 2017 acb. All rights reserved.
//

import Cocoa
import AVFoundation

/** Encapsulate a possible interface instance returned by a loaded instrument. Depending on the technique we're using, this may be a NSView or a NSViewController */
public enum InterfaceInstance {
    case view(NSView)
    case viewController(NSViewController)
}

/**
 A protocol wrapping the code that loads, hosts and plays an AudioUnit Instrument
 */

protocol InstrumentHost {
    // This is only implemented in v3 AudioUnits
    var auAudioUnit: AUAudioUnit? { get }
    func loadInstrument(fromDescription desc: AudioComponentDescription, completion: @escaping (Bool)->())
    func requestInstrumentInterfaceSimple()
    func noteOn(_ note: UInt8, withVelocity velocity: UInt8, channel: UInt8)
    func noteOff(_ note: UInt8, channel: UInt8)
    func set(volume: UInt8, channel: UInt8)
    func set(pan: UInt8, channel: UInt8)
    func setController(number: UInt8, value: UInt8, channel: UInt8)
    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->())
    var fullState : [String : Any]? { get set }
    var samplerData : SamplerData { get set }
    func set(tempo: UInt8)
}
