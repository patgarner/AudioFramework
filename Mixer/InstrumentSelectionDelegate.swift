//
//  InstrumentSelectionDelegate.swift
//  Composer Bot Desktop
//
//  Created by Admin on 5/14/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation
import CoreAudioKit

protocol InstrumentSelectionDelegate{
    func selectInstrument(_ inst: AVAudioUnitComponent, channel: Int)
    func select(effect: AVAudioUnitComponent, channel: Int)
    func getListOfInstruments() -> [AVAudioUnitComponent]
    func displayInstrumentInterface(channel: Int)
    func displayEffectInterface(channel: Int)
}
