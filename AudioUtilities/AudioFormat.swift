//
//  AudioFileType.swift
//  AudioFramework
//
//  Created by Admin on 12/10/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation

public class AudioFormat : Codable, Equatable{  
    public var id = UUID().uuidString
    public var type = AudioFormatType.none
    public var name = ""
    public var sampleRate = 44100
    public var bitRate = 16
    public var mp3BitRate = 320
    public var constantBitRate = true
    enum AudioFormatCodingKeys : CodingKey{
        case id, type, name, sampleRate, bitRate, constantBitRate, mp3BitRate
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AudioFormatCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        let typeInt = try container.decode(Int.self, forKey: .type)
        if let type = AudioFormatType(rawValue: typeInt){
            self.type = type
        }
        name = try container.decode(String.self, forKey: .name)
        sampleRate = try container.decode(Int.self, forKey: .sampleRate)
        bitRate = try container.decode(Int.self, forKey: .bitRate)
        mp3BitRate = try container.decode(Int.self, forKey: .mp3BitRate)
        constantBitRate = try container.decode(Bool.self, forKey: .constantBitRate)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AudioFormatCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(bitRate, forKey: .bitRate)
        try container.encode(sampleRate, forKey: .sampleRate)
        try container.encode(constantBitRate, forKey: .constantBitRate)
        try container.encode(mp3BitRate, forKey: .mp3BitRate)
    }
    public init(){
        
    }
    public init(type: AudioFormatType){
        self.type = type
    }
    func equals(_ other: Any) -> Bool {
        guard let other = other as? AudioFormat else { return false }
        if self.type != other.type { return false }
        if self.name != other.name { return false }
        if self.bitRate != other.bitRate { return false }
        if self.mp3BitRate != other.mp3BitRate { return false }
        if self.constantBitRate != other.constantBitRate { return false }
        return true
    }
    public static func == (lhs: AudioFormat, rhs: AudioFormat) -> Bool {
        return lhs.equals(rhs)
    }
    func updateValuesWith(audioFormat: AudioFormat){
        type = audioFormat.type
        name = audioFormat.name
        sampleRate = audioFormat.sampleRate
        bitRate = audioFormat.bitRate
        constantBitRate = audioFormat.constantBitRate
        mp3BitRate = audioFormat.mp3BitRate
    }
}
/*
public class WavFormat : AudioFormat{
    public var sampleRate = 44100
    public var bitRate = 16
    public override init(){
        super.init()
        name = "WAV"
        type = .wav
    }
    enum WavCodingKeys: CodingKey{
        case parent
        case sampleRate 
        case bitRate
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WavCodingKeys.self)
        sampleRate = try container.decode(Int.self, forKey: .sampleRate)
        bitRate = try container.decode(Int.self, forKey: .bitRate)
        let baseDecoder = try container.superDecoder(forKey: .parent)
        try super.init(from: baseDecoder)
    }
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WavCodingKeys.self)
        try container.encode(sampleRate, forKey: .sampleRate)
        try container.encode(bitRate, forKey: .bitRate)
        let baseEncoder = container.superEncoder(forKey: .parent)
        do {
            try super.encode(to: baseEncoder)
        } catch {}
    }
    static func == (lhs: WavFormat, rhs: WavFormat) -> Bool {
        return lhs.equals(rhs)
    }
    override func equals(_ other: Any) -> Bool {
        guard let other = other as? WavFormat else { return false }
        if !super.equals(other) { return false }
        if self.sampleRate != other.sampleRate { return false }
        if self.bitRate != other.bitRate { return false }
        return true
    }
}

public class Mp3Format : AudioFormat{
    public var constantBitRate = false
    public var bitRate = 320
    public override init() {
        super.init()
        name = "MP3"
        type = .mp3
    }
    enum Mp3CodingKeys: CodingKey{
        case parent
        case constantBitRate 
        case bitRate
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Mp3CodingKeys.self)
        constantBitRate = try container.decode(Bool.self, forKey: .constantBitRate)
        bitRate = try container.decode(Int.self, forKey: .bitRate)
        let baseDecoder = try container.superDecoder(forKey: .parent)
        try super.init(from: baseDecoder)
    }
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Mp3CodingKeys.self)
        try container.encode(constantBitRate, forKey: .constantBitRate)
        try container.encode(bitRate, forKey: .bitRate)
        let baseEncoder = container.superEncoder(forKey: .parent)
        do {
            try super.encode(to: baseEncoder)
        } catch {}
    }
    static func == (lhs: Mp3Format, rhs: Mp3Format) -> Bool {
        return lhs.equals(rhs)
    }
    override func equals(_ other: Any) -> Bool {
        guard let other = other as? Mp3Format else { return false }
        if !super.equals(other) { return false }
        if self.constantBitRate != other.constantBitRate { return false }
        if self.bitRate != other.bitRate { return false }
        return true
    }
}
*/
public enum AudioFormatType : Int, Codable{
    case none
    case wav
    case mp3
}
