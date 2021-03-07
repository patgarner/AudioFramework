//
//  AudioExporter.swift
//  AudioFramework
//
//  Created by Admin on 9/23/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

class MidiAudioExporter{
    class func renderMidiOffline(sequencer: AVAudioSequencer, engine: AVAudioEngine, audioDestinationURL: URL, delegate: MidiAudioExporterDelegate?, number: Int?, formats: [AudioFormat], headLength: Double, tailLength: Double){
        //TODO: put all code from renderMidiOffline here. have it call this func
        var lengthInSeconds = 0.0
        for track in sequencer.tracks{
            lengthInSeconds = max(track.lengthInSeconds, lengthInSeconds)
        }
        lengthInSeconds += headLength
        lengthInSeconds += tailLength
        engine.stop()
        let format: AVAudioFormat = engine.mainMixerNode.outputFormat(forBus: 0)
        let maxFrames: AVAudioFrameCount = 2048
        do {
            try engine.enableManualRenderingMode(.offline, format: format,
                                                 maximumFrameCount: maxFrames)
        } catch {
            fatalError("Enabling manual rendering mode failed: \(error).")
        }
        delegate?.willStartMidiAudioExport()
        
        do {
            try engine.start()
            sequencer.currentPositionInSeconds = 0
            sequencer.prepareToPlay()
            try sequencer.start()
        } catch {
            fatalError("Unable to start audio engine: \(error).")
        }
        let buffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat, frameCapacity: engine.manualRenderingMaximumFrameCount)!
        let outputFile: AVAudioFile
        let cafURL = audioDestinationURL.appendingPathExtension("caf")
        do {
            var bufferSettings = buffer.format.settings
            bufferSettings["AVLinearPCMIsNonInterleaved"] = 0
            outputFile = try AVAudioFile(forWriting: cafURL, settings: bufferSettings)
        } catch {
            print("Unable to open output audio file: \(error).")
            return
        }
        let sourceFileLength = AVAudioFramePosition(lengthInSeconds * buffer.format.sampleRate)
        var progress = 0.0
        while engine.manualRenderingSampleTime < sourceFileLength {
            do {
                let frameCount = sourceFileLength - engine.manualRenderingSampleTime
                let framesToRender = min(AVAudioFrameCount(frameCount), buffer.frameCapacity)
                let status = try engine.renderOffline(framesToRender, to: buffer)
                switch status {
                case .success:
                    try outputFile.write(from: buffer)
                case .insufficientDataFromInputNode:
                    break
                case .cannotDoInCurrentContext:
                    break
                case .error:
                    fatalError("The manual rendering failed.")
                @unknown default:
                    print("Unknown error.")
                }
            } catch {
                //fatalError("The manual rendering failed: \(error).")
                return
            }
            let newProgress = sequencer.currentPositionInSeconds / lengthInSeconds
            if newProgress - progress >= 0.01 {
                progress = newProgress
                if let number = number {
                    delegate?.set(progress: newProgress, number: number)
                }
            }
        }
        engine.stop()
        engine.disableManualRenderingMode()
        ////////////////////////////////////////////////////////////////////////////////////
        // Now Convert
        ///////////////////////////////////////////////////////////////////////////////////
        AudioFileConverter.convert(sourceURL: cafURL, destinationURL: audioDestinationURL, formats: formats, deleteSource: true)
    }
    class func renderMidiOffline(sequencer: AVAudioSequencer, engine: AVAudioEngine, audioDestinationURL: URL, includeMP3: Bool, delegate: MidiAudioExporterDelegate? = nil, number: Int? = nil, sampleRate: Int = 44100){
//        let wavFormat = WavFormat()
        let wavFormat = AudioFormat()
        wavFormat.sampleRate = sampleRate
        wavFormat.type = .wav
        var audioFormats : [AudioFormat] = [wavFormat]
        if includeMP3 {
            let mp3Format = AudioFormat()
            mp3Format.type = .mp3
            audioFormats.append(mp3Format)
        }
        renderMidiOffline(sequencer: sequencer, engine: engine, audioDestinationURL: audioDestinationURL, delegate: delegate, number: number, formats: audioFormats, headLength: 4.0, tailLength: 4.0)
    }
    class func cancelOfflineRender(engine: AVAudioEngine){
        engine.stop()
        engine.disableManualRenderingMode()
    }
}

protocol MidiAudioExporterDelegate{
    func willStartMidiAudioExport()
    func set(progress: Double, number: Int)
}
