//
//  ChannelState.swift
//
/*
 Copyright 2020 David Mann Music LLC
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
    public static func == (lhs: ChannelState, rhs: ChannelState) -> Bool {
        if lhs.mute != rhs.mute { return false }
        if lhs.volume != rhs.volume { return false }
        if lhs.trackName != rhs.trackName { return false }
        if lhs.solo != rhs.solo { return false }
        if lhs.pan != rhs.pan { return false }
        if lhs.virtualInstrument != rhs.virtualInstrument { return false }
        return true
    }
}

public struct PluginSelection : Codable, Equatable{
    public var manufacturer = ""
    public var name = ""
}
