//
//  AllAudioUnitData.swift
//
/*
 Copyright 2020 David Mann Music LLC
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

public class AllPluginData : Codable{
    public var instrumentChannels : [ChannelPluginData] = []
    public var auxChannels : [ChannelPluginData] = []
    public var masterChannel = ChannelPluginData()

    public var sends : [SendData] = []
    enum CodingKeys : CodingKey{
        case instrumentChannels
        case auxChannels
        case masterChannel
    }
    public init(){
        
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            instrumentChannels = try container.decode([ChannelPluginData].self, forKey: .instrumentChannels)
        } catch {
            print("AllPluginData: failed to load instrument channels: Error: \(error)")
        }
        do {
            auxChannels = try container.decode([ChannelPluginData].self, forKey: .auxChannels)
        } catch {
            print("AllPluginData: failed to load aux channels: Error: \(error)")
        }
        do {
            masterChannel = try container.decode(ChannelPluginData.self, forKey: .masterChannel)
        } catch {
            print("AllPluginData: failed to load master channel: Error: \(error)")
        }
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instrumentChannels, forKey: .instrumentChannels)
        try container.encode(auxChannels, forKey: .auxChannels)
        try container.encode(masterChannel, forKey: .masterChannel)

    }
}
