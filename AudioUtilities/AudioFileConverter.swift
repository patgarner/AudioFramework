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
    class func convert(sourceURL: URL, destinationURL: URL, formats: [AudioFormat], deleteSource: Bool){
        for format in formats {
            if format.type == .wav{
                let destinationURL = destinationURL.appendingPathExtension("wav")
                convertToWav(sourceURL: sourceURL, destinationURL: destinationURL, deleteSource: false, sampleRate: format.sampleRate, bitRate: format.bitRate)
            } else if format.type == .mp3 {
                let destinationURL = destinationURL.appendingPathExtension("mp3")
                convertToMP3(sourceURL: sourceURL, destinationURL: destinationURL, deleteSource: false, bitRate: format.mp3BitRate)
            }
        }
        if deleteSource{
            let fileManager = FileManager()
            do {
                try fileManager.removeItem(at: sourceURL)
            } catch {
                print(error)
            }
        }
    }
    class func convertToWav(sourceURL: URL, destinationURL: URL, deleteSource: Bool, sampleRate: Int = 44100, bitRate: Int = 16){
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launchPath = "/usr/bin/afconvert"
        let sourcePath = sourceURL.path
        let destPath = destinationURL.path
        
        let sampleFormatString = "LEI\(bitRate)@\(sampleRate)"
        task.arguments = ["-f",  "WAVE", "-d", sampleFormatString, sourcePath, destPath, ]
        task.launch()
        let handle = pipe.fileHandleForReading
        let data = handle.readDataToEndOfFile()
        guard let result_s = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
            print("Couldn't get WAV conversion results")
            return
        }
        print(result_s)
        if deleteSource{
            let fileManager = FileManager()
            do {
                try fileManager.removeItem(at: sourceURL)
            } catch {
                print(error)
            }
        }
    }
    class func convertToMP3(sourceURL: URL, destinationURL: URL, deleteSource: Bool, bitRate: Int = 320){
        var sourceURL = sourceURL
        var wavTempURL : URL? = nil
        if sourceURL.pathExtension == "caf"{ //Uses 0.05 seconds but reliable
            wavTempURL = destinationURL.appendingPathExtension("wav")
            convertToWav(sourceURL: sourceURL, destinationURL: wavTempURL!, deleteSource: false, sampleRate: 44100, bitRate: 16)
            sourceURL = wavTempURL!
        }
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launchPath = "/usr/local/bin/lame"
        let sourcePath = sourceURL.path
        let destPath = destinationURL.path
        task.arguments = [sourcePath, destPath, "-b \(bitRate)"]
        task.launch()
        let handle = pipe.fileHandleForReading
        let data = handle.readDataToEndOfFile()
        guard let result_s = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
            print("Couldn't get mp3 conversion results")
            return
        }
        print(result_s)
        let fileManager = FileManager()
        if deleteSource{
            do {
                try fileManager.removeItem(at: sourceURL)
            } catch {
                print(error)
            }
        }
        if let wavTempURL = wavTempURL{
            do {
                try fileManager.removeItem(at: wavTempURL)
            } catch {
                print(error)
            }
        }
    }
    class func convert(sourceURL: URL, destinationURL: URL, deleteSource: Bool){
        let asset = AVAsset(url: sourceURL)
        let fileManager = FileManager()
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
            if fileManager.fileExists(atPath: outURL.relativePath){
                try fileManager.removeItem(at: outURL)
            }
            let writer = try AVAssetWriter(outputURL: outURL, fileType: AVFileType.wav)
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
                if writer.error != nil { 
                    print("Error = \(writer.error!)")
                }
                print("Done!")
            }
            if deleteSource{
                try fileManager.removeItem(at: sourceURL)
            }
        } catch {
            print(error)
        }
        
    }
}
