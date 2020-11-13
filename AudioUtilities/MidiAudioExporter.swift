//
//  AudioExporter.swift
//  AudioFramework
//
//  Created by Admin on 9/23/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

class MidiAudioExporter{
    class func renderMidiOffline(sequencer: AVAudioSequencer, engine: AVAudioEngine, audioDestinationURL: URL, includeMP3: Bool, delegate: MidiAudioExporterDelegate? = nil, number: Int? = nil){
        var lengthInSeconds = 0.0
        for track in sequencer.tracks{
            lengthInSeconds = max(track.lengthInSeconds, lengthInSeconds)
        }
        lengthInSeconds += 3.0
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
            let bufferSettings = buffer.format.settings
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
                fatalError("The manual rendering failed: \(error).")
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
        let wavUrl = audioDestinationURL.appendingPathExtension("wav")
        AudioFileConverter.convert(sourceURL: cafURL, destinationURL: wavUrl, deleteSource: false)
        if includeMP3{
            let mp3Url = audioDestinationURL.appendingPathExtension("mp3")
            AudioFileConverter.convertToMP3(sourceURL: wavUrl, destinationURL: mp3Url, deleteSource: false)
        }
        do {
            let fileManager = FileManager()
            try fileManager.removeItem(at: cafURL)
        } catch {
            print(error)
        }
    }
}

protocol MidiAudioExporterDelegate{
    func willStartMidiAudioExport()
    func set(progress: Double, number: Int)
}
