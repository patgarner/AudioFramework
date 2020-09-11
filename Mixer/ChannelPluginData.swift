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

public class ChannelPluginData : Codable{
    public var instrumentPlugin = PluginData()
    public var effectPlugins : [PluginData] = []
    enum CodingKeys: CodingKey{
        case instrumentPlugin
        case effectPlugins
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
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instrumentPlugin, forKey: .instrumentPlugin)
        try container.encode(effectPlugins, forKey: .effectPlugins)
    }
}
