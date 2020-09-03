//
//  AudioFileConverter.swift
//  Composer Bot Desktop
//
//  Created by Admin on 7/9/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

class AudioFileConverter{
    class func convert(sourceURL: URL, destinationURL: URL){
        let asset = AVAsset(url: sourceURL)
        do {
            let reader = try AVAssetReader(asset: asset)
            let track = asset .tracks(withMediaType: AVMediaType.audio)[0]
            let compressionSettings : [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey : 48000,
                AVLinearPCMBitDepthKey : 16,
                AVLinearPCMIsNonInterleaved : false,
                AVLinearPCMIsFloatKey : false,
                AVLinearPCMIsBigEndianKey : false,
                AVNumberOfChannelsKey : 2
            ]
            let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: compressionSettings)
            reader.add(readerOutput)
            let outURL = destinationURL
            if FileManager.default.fileExists(atPath: outURL.relativeString){
                print("File exists! Kill!\(outURL.absoluteString)")
            }
            
            let writer = try AVAssetWriter(outputURL: outURL, fileType: AVFileType.wav)
            //Need to delete output file if it exists
            let writerInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: compressionSettings)
            writer.add(writerInput)
            writer.startWriting()
            reader.startReading()
            let startTime = CMTime(seconds: 0, preferredTimescale: 1)
            writer.startSession(atSourceTime: startTime)
            var sample = readerOutput.copyNextSampleBuffer()
            while sample != nil{
                while true {
                    if writerInput.isReadyForMoreMediaData {
                        writerInput.append(sample!)
                        break
                    }
                }
                sample = readerOutput.copyNextSampleBuffer()
            }
            writer.finishWriting { 
                print("status = \(writer.status)")
                print("Error = \(writer.error)")
                print("Done!")
            }
        } catch {
            print(error)
        }
    }
}
