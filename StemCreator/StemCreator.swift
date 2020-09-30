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
    init(delegate: StemCreatorDelegate){
        self.delegate = delegate
    }
    func createStems(model: StemCreatorModel, folder: URL){
        for stem in model.stems{
            createStem(stemModel: stem, prefix: model.namePrefix, folder: folder)
        }
    }
    private func createStem(stemModel: StemModel, prefix: String, folder: URL){
        delegate.muteAllExcept(channelIds: stemModel.channelIds)
        let filename = prefix + "(" + stemModel.stemShortName +  ")"
        let stemPath = folder.appendingPathComponent(filename)
        print("stem path: \(stemPath)")
        delegate.exportStem(to: stemPath)
    }
}
