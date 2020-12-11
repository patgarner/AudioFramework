//
//  AudioFileType.swift
//  AudioFramework
//
//  Created by Admin on 12/10/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation

class AudioFormat : Codable{
    var id = UUID().uuidString
    var type = AudioFormatType.wav
}

class WavFormat : AudioFormat{
    var sampleRate = 44100
    var bitRate = 16
}

class Mp3Format : AudioFormat{
    var constantBitRate = true
    var bitRate = 320
}

enum AudioFormatType : Int, Codable{
    case wav
    case mp3
}
