//
//  ChannelPluginData.swift
//
/*
 Copyright 2020 David Mann Music LLC
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

public class ChannelModel : Codable, Equatable{  
    public var instrumentPlugin = PluginData()
    public var effectPlugins : [PluginData] = []
    public var sends : [SendData] = []
    public var output = BusInfo(number: -1, type: .none)
    public var volume : Float = 1.0
    public var pan : Float = 0.0
    public var trackName = ""
    public var busInput = -1
    public var id = ""
    public var solo = false
    public var mute = false
    enum CodingKeys: CodingKey{
        case instrumentPlugin
        case effectPlugins
        case volume
        case pan
        case sends
        case trackName
        case busInput
        case id
        case output
        case mute
        case solo
    }
    public init(){
        
    }
    required public init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            instrumentPlugin = try container.decode(PluginData.self, forKey: .instrumentPlugin)
        } catch {}
        do {
            effectPlugins = try container.decode([PluginData].self, forKey: .effectPlugins)
        } catch {}
        do {
            volume = try container.decode(Float.self, forKey: .volume)
        } catch {}
        do {
            pan = try container.decode(Float.self, forKey: .pan)
        } catch {}
        do {
            sends = try container.decode([SendData].self, forKey: .sends)
        } catch {}
        do {
            trackName = try container.decode(String.self, forKey: .trackName)
        } catch {}
        do {
            busInput = try container.decode(Int.self, forKey: .busInput)
        } catch {}
        do {
            id = try container.decode(String.self, forKey: .id)
        } catch {}
        do {
            output = try container.decode(BusInfo.self, forKey: .output)
        } catch {}
        do {
            mute = try container.decode(Bool.self, forKey: .mute)
        } catch {}
        do {
            solo = try container.decode(Bool.self, forKey: .solo)
        } catch {}
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instrumentPlugin, forKey: .instrumentPlugin)
        try container.encode(effectPlugins, forKey: .effectPlugins)
        try container.encode(volume, forKey: .volume)
        try container.encode(pan, forKey: .pan)
        try container.encode(sends, forKey: .sends)
        try container.encode(trackName, forKey: .trackName)
        try container.encode(busInput, forKey: .busInput)
        try container.encode(id, forKey: .id)
        try container.encode(output, forKey: .output)
        try container.encode(mute, forKey: .mute)
        try container.encode(solo, forKey: .solo)
    }
    public static func == (lhs: ChannelModel, rhs: ChannelModel) -> Bool {
        if lhs.busInput != rhs.busInput { return false }
        if lhs.id != rhs.id { return false }
        if lhs.trackName != rhs.trackName { return false }
        if lhs.pan != rhs.pan { return false }
        if lhs.volume != rhs.volume { return false }
        if lhs.solo != rhs.solo { return false }
        if lhs.mute != rhs.mute { return false }
        return true
    }
}

public struct BusInfo: Codable{
    var number = -1
    var type = BusType.none
    public init(){
        
    }
    public init(number: Int, type: BusType){
        self.number = number
        self.type = type
    }
}

public enum BusType : Int, Codable {
    case none
    case master
    case bus
}
