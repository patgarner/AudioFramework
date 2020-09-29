//
//  AudioFileConverter.swift
//
/*
 Copyright 2020 David Mann Music LLC
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import AVFoundation

class AudioFileConverter{
    class func convert(sourceURL: URL, destinationURL: URL, deleteSource: Bool){
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
            if deleteSource{
                let fileManager = FileManager()
                try fileManager.removeItem(at: sourceURL)
            }
        } catch {
            print(error)
        }
        
    }
    class func convertToMP3(sourceURL: URL, destinationURL: URL, deleteSource: Bool){ //WIP
           let asset = AVAsset(url: sourceURL)
           do {
               let reader = try AVAssetReader(asset: asset)
               let track = asset .tracks(withMediaType: AVMediaType.audio)[0]
               let compressionSettings : [String: Any] = [
                   AVFormatIDKey: kAudioFormatMPEGLayer3,
                   AVSampleRateKey : 48000//,
//                   AVLinearPCMBitDepthKey : 16,
//                   AVLinearPCMIsNonInterleaved : false,
//                   AVLinearPCMIsFloatKey : false,
//                   AVLinearPCMIsBigEndianKey : false,
//                   AVNumberOfChannelsKey : 2
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
               if deleteSource{
                   let fileManager = FileManager()
                   try fileManager.removeItem(at: sourceURL)
               }
           } catch {
               print(error)
           }
           
       }
}
