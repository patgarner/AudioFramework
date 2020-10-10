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

//protocol PluginSelectionDelegate{
    //Consolidate these two......................
//    func selectInstrument(_ inst: AVAudioUnitComponent, channel: Int, type: ChannelType)
//    func select(effect: AVAudioUnitComponent, channel: Int, number: Int, type: ChannelType)
    //////////////////////////////////////////////////////////////////////////////////////////
//}

public protocol ChannelViewDelegate {
    var volume : Float { get set }
    var pan : Float { get set }
    var mute : Bool { get set }
    var solo : Bool { get set }
    var trackName: String { get set }
    var numBusses : Int { get }
    func deselectEffect(number: Int)
    func getPluginSelection(pluginType: PluginType, pluginNumber: Int) -> PluginSelection?
    func selectInput(busNumber: Int) //Set Input
    func getBusInputNumber() -> Int? //Get Input
    func didSelectChannel()
    func setSend(volume: Float, sendNumber: Int)
    func getDestination(type: ConnectionType, number: Int) -> BusInfo?
    func getSendData(sendNumber: Int) -> SendData?
    func connect(sourceType: ConnectionType, sourceNumber: Int, destinationType: BusType, destinationNumber: Int)
    func displayInterface(type: PluginType, number: Int)
    func select(description: AudioComponentDescription, type: PluginType, number: Int)
}

protocol ChannelControllerDelegate{
    var numBusses : Int { get }
    func log(_ message: String)
    var engine : AVAudioEngine { get }
    func soloDidChange()
    func didSelectChannel()
    func getOutputDestination(for node: AVAudioNode) -> BusInfo? //Get Output
    func connect(sourceNode: AVAudioNode, destinationNumber: Int, destinationType: BusType) //Connect
    func getBusInput(for node: AVAudioNode) -> Int? //Get input (for aux nodes)
    func connect(busNumber: Int, to node: AVAudioNode) //Connects input (for aux nodes)
    func displayInterface(audioUnit: AVAudioUnit)
    var contextBlock : AUHostMusicalContextBlock { get }
}

public enum ConnectionType {
    case send
    case output
}
