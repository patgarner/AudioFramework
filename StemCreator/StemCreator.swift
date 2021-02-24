//
//  StemCreator.swift
//  AudioFramework
//
//  Created by Admin on 9/26/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation

public class StemCreator{
    var delegate: StemCreatorDelegate!
    //private let letters = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z".components(separatedBy: ",")
    private var shouldCancel = false
    init(delegate: StemCreatorDelegate){
        self.delegate = delegate
    }
    init(){
        
    }
    func createStems(model: StemCreatorModel, folder: URL){
        for i in 0..<model.stems.count{
            if shouldCancel { return }
            let stem = model.stems[i]
            if !stem.include { continue }
            if stem.audioFormatIds.count == 0 { 
                MessageHandler.log("Error: Stem \(stem.stemShortName) has no audio formats selected.", displayFormat: [.notification])                
                continue 
            }
            createStem(stemModel: stem, prefix: model.namePrefix, folder: folder, number: i, audioFormats: model.audioFormats, tailLength: model.tailLength)
        }
    }
    private func createStem(stemModel: StemModel, prefix: String, folder: URL, number: Int, audioFormats: [AudioFormat], tailLength: Double){
        delegate.muteAllExcept(channelIds: stemModel.channelIds)
        let letter = stemModel.letter//letters[number]
        let filename = prefix + " " + letter + "(" + stemModel.stemShortName +  ")"
        let stemPath = folder.appendingPathComponent(filename)
        var selectedAudioFormats : [AudioFormat] = []
        for audioFormatId in stemModel.audioFormatIds{
            for audioFormat in audioFormats{
                if audioFormat.id == audioFormatId {
                    selectedAudioFormats.append(audioFormat)
                }
            }
        }
        delegate.exportStem(to: stemPath, number: number, formats: selectedAudioFormats, tailLength: tailLength)
    }
    func cancelStemExport(){
        shouldCancel = true
    }
}
