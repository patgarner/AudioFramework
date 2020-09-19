//
//  InstrumentSelectionDelegate.swift
//
/*
 Copyright 2020 David Mann Music LLC
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import AVFoundation
import CoreAudioKit

protocol PluginSelectionDelegate{
    //Consolidate these two......................
    func selectInstrument(_ inst: AVAudioUnitComponent, channel: Int, type: ChannelType)
    func select(effect: AVAudioUnitComponent, channel: Int, number: Int, type: ChannelType)
    //Consolidate these two...
    func displayInstrumentInterface(channel: Int)
    func displayEffectInterface(channel: Int, number: Int, type: ChannelType)
    //////////////////////////////////////////////////////////////////////////////////////////
    func numBusses() -> Int
    func selectInput(busNumber: Int, channel: Int, channelType: ChannelType)
    func getBusInputNumber(channelNumber: Int, channelType: ChannelType) -> Int?
}

public protocol ChannelViewDelegate2 {
    var volume : Float { get set }
    var pan : Float { get set }
    var mute : Bool { get set }
    var solo : Bool { get set }
    var trackName: String { get set }
    func deselectEffect(number: Int)
    func getPluginSelection(pluginType: PluginType, pluginNumber: Int) -> PluginSelection?
    func setSend(volume: Float, sendNumber: Int)
    func getSendData(sendNumber: Int) -> SendData?
    func select(sendNumber: Int, busNumber: Int, channel: Int, channelType: ChannelType)
    func getSendOutput(sendNumber: Int) -> Int?
}
