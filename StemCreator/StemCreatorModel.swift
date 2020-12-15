//
//  StemCreatorModel.swift
//  AudioFramework
//
//  Created by Admin on 9/25/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation

public class StemCreatorModel : Codable, Equatable {
    public var namePrefix = ""
    public var stems : [StemModel] = []
//    var sampleRate = 44100
    public var audioFormats : [AudioFormat] = [WavFormat(), Mp3Format()]
    public init(){
        
    }
    public static func == (lhs: StemCreatorModel, rhs: StemCreatorModel) -> Bool {
        return true
    }
    var numStems : Int {
        return stems.count
    }
    public func addStem(){
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
    public func selectionChangedTo(selected: Bool, stemNumber: Int, channelId: String) {
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
    func stemIncludedDidChangeTo(include: Bool, stemNumber: Int) {
        if stemNumber < 0 || stemNumber >= stems.count { return }
        let stem = stems[stemNumber]
        stem.include = include
    }
    func isIncluded(stemNumber: Int) -> Bool {
        if stemNumber < 0 || stemNumber >= stems.count { return false }
        let stem = stems[stemNumber]
        return stem.include
    }
    func removeAll(){
        stems.removeAll()
        namePrefix = ""
    }
    public func getFormatsWith(ids: [String]) -> [AudioFormat]{
        var matchingFormats : [AudioFormat] = []
        for id in ids {
            for audioFormat in audioFormats{
                if audioFormat.id == id {
                    matchingFormats.append(audioFormat)
                }
            }
        }
        return matchingFormats
    }
}
