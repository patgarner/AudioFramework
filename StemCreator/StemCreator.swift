//
//  StemCreator.swift
//  AudioFramework
//
//  Created by Admin on 9/26/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public class StemCreator{
    var delegate: StemCreatorDelegate!
    let letters = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z".components(separatedBy: ",")
    init(delegate: StemCreatorDelegate){
        self.delegate = delegate
    }
    func createStems(model: StemCreatorModel, folder: URL){
        for i in 0..<model.stems.count{
            let stem = model.stems[i]
            createStem(stemModel: stem, prefix: model.namePrefix, folder: folder, number: i)
        }
    }
    private func createStem(stemModel: StemModel, prefix: String, folder: URL, number: Int){
        delegate.muteAllExcept(channelIds: stemModel.channelIds)
        let letter = letters[number]
        let filename = prefix + " " + letter + "(" + stemModel.stemShortName +  ")"
        let stemPath = folder.appendingPathComponent(filename)
        print("stem path: \(stemPath)")
        var mp3 = false
        if number == 0 { mp3 = true }
        delegate.exportStem(to: stemPath, includeMP3: mp3)
    }
}
