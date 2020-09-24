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

class AudioExporter{
    class func renderMidiOffline(sequencer: AVAudioSequencer, engine: AVAudioEngine){
        var lengthInSeconds = 0.0
        for track in sequencer.tracks{
            lengthInSeconds = max(track.lengthInSeconds, lengthInSeconds)
        }
        lengthInSeconds += 4.0
        engine.stop()
        let format: AVAudioFormat = engine.mainMixerNode.outputFormat(forBus: 0)
        let maxFrames: AVAudioFrameCount = 1024
        do {
            try engine.enableManualRenderingMode(.offline, format: format,
                                                 maximumFrameCount: maxFrames)
        } catch {
            fatalError("Enabling manual rendering mode failed: \(error).")
        }
        do {
            try engine.start()
            sequencer.prepareToPlay()
            try sequencer.start()
        } catch {
            fatalError("Unable to start audio engine: \(error).")
        }
        let buffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat,
                                      frameCapacity: engine.manualRenderingMaximumFrameCount)!
        let outputFile: AVAudioFile
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentsURL.appendingPathComponent("Rhythm-processed.caf")
            outputFile = try AVAudioFile(forWriting: outputURL, settings: buffer.format.settings)
        } catch {
            fatalError("Unable to open output audio file: \(error).")
        }
        let sourceFileLength = AVAudioFramePosition(lengthInSeconds * buffer.format.sampleRate)
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
        }
        engine.stop()
        print("AVAudioEngine offline rendering finished.")
        NSWorkspace.shared.activateFileViewerSelecting([outputFile.url])
    }
}

