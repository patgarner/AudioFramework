//
//  StemCreatorModel.swift
//  AudioFramework
//
//  Created by Admin on 9/25/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public class StemCreatorModel : Codable, Equatable {
    var namePrefix = ""
    var stems : [StemModel] = []
    public static func == (lhs: StemCreatorModel, rhs: StemCreatorModel) -> Bool {
        return false
    }
    var numStems : Int {
        return stems.count
    }
    func addStem(){
        let stem = StemModel()
        stems.append(stem)
    }
    func getNameFor(stem stemNumber: Int) -> String?{
        if stemNumber < 0 || stemNumber >= stems.count { return nil }
        let thisStem = stems[stemNumber]
        return thisStem.stemShortName
    }
    func setName(stemNumber: Int, name: String){
        if stemNumber < 0 || stemNumber >= stems.count { return }
        stems[stemNumber].stemShortName = name
    }
    func selectionChangedTo(selected: Bool, stemNumber: Int, channelId: String) {
        if stemNumber < 0 || stemNumber >= stems.count { return }
        let stem = stems[stemNumber]
        stem.selectionChanged(selected: selected, channelId: channelId)
    }
    func isSelected(stemNumber: Int, channelId: String) -> Bool{
        if stemNumber < 0 || stemNumber >= stems.count { return false }
        let stem = stems[stemNumber]
        let result = stem.isSelected(channelId: channelId)
        return result
    }
    func delete(stemNumber: Int){
        if stemNumber < 0 || stemNumber >= stems.count { return }
        stems.remove(at: stemNumber)
    }
    func addDefaultStem(channelIds : [String]){
        let stemModel = StemModel()
        stemModel.channelIds = channelIds
        stemModel.stemShortName = "FULL"
        stems.append(stemModel)
    }
}
