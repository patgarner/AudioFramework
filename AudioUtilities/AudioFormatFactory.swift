//
//  AudioFormatFactory.swift
//  AudioFramework
//
//  Created by Admin on 12/15/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public class AudioFormatFactory {
    class var wav44_16 : AudioFormat{
        let audioFormat = AudioFormat(type: .wav)
        audioFormat.name = "WAV 44 16"
        audioFormat.sampleRate = 44100
        audioFormat.bitRate = 16
        return audioFormat
    }
    class var wav48_16 : AudioFormat{
        let audioFormat = AudioFormat(type: .wav)
        audioFormat.name = "WAV 48 16"
        audioFormat.sampleRate = 48000
        audioFormat.bitRate = 16
        return audioFormat
    }
    class var mp3_320 : AudioFormat{
        let audioFormat = AudioFormat(type: .mp3)
        audioFormat.name = "MP3 320"
        audioFormat.mp3BitRate = 320
        audioFormat.constantBitRate = true
        return audioFormat
    }
}
