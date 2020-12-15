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
    private let letters = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z".components(separatedBy: ",")
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
            createStem(stemModel: stem, prefix: model.namePrefix, folder: folder, number: i)
        }
    }
    private func createStem(stemModel: StemModel, prefix: String, folder: URL, number: Int){
        delegate.muteAllExcept(channelIds: stemModel.channelIds)
        let letter = letters[number]
        let filename = prefix + " " + letter + "(" + stemModel.stemShortName +  ")"
        let stemPath = folder.appendingPathComponent(filename)
        var mp3 = true
        if number == 0 { mp3 = true }
        delegate.exportStem(to: stemPath, includeMP3: mp3, number: number, sampleRate: 44100)
//        let audioFormats = 
//        delegate.exportStem(to: stemPath, number: number, formats: stemModel.audioFormats)
    }
    func cancelStemExport(){
        shouldCancel = true
    }
}
