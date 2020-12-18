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
    public var audioFormats : [AudioFormat] = []
    public init(){
        audioFormats.append(AudioFormatFactory.wav48_16)
        audioFormats.append(AudioFormatFactory.mp3_320)
    }
    enum StemCreatorModelCodingKeys: CodingKey {
        case namePrefix
        case stems
        case audioFormats
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StemCreatorModelCodingKeys.self)
        namePrefix = try container.decode(String.self, forKey: .namePrefix)
        stems = try container.decode([StemModel].self, forKey: .stems)
        do {
            audioFormats = try container.decode([AudioFormat].self, forKey: .audioFormats)
        } catch {}
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StemCreatorModelCodingKeys.self)
        try container.encode(namePrefix, forKey: .namePrefix)
        try container.encode(stems, forKey: .stems)
        try container.encode(audioFormats, forKey: .audioFormats)
    }
    public static func == (lhs: StemCreatorModel, rhs: StemCreatorModel) -> Bool {
        if lhs.namePrefix != rhs.namePrefix { return false }
        if lhs.stems.count != rhs.stems.count { return false }
        for i in 0..<lhs.stems.count{
            let leftStem = lhs.stems[i]
            let rightStem = rhs.stems[i]
            if leftStem != rightStem { return false }
        }
        if lhs.audioFormats.count != rhs.audioFormats.count { return false }
        for i in 0..<lhs.audioFormats.count {
            if lhs.audioFormats[i] != rhs.audioFormats[i] { return false }
        }
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
    public func selectionChangedTo(selected: Bool, stemNumber: Int, id: String, type: ColumnType) {
        if stemNumber < 0 || stemNumber >= stems.count { return }
        let stem = stems[stemNumber]
        stem.selectionChanged(selected: selected, id: id, type: type)
    }
    func isSelected(stemNumber: Int, id: String, type: ColumnType) -> Bool{
        if stemNumber < 0 || stemNumber >= stems.count { return false }
        let stem = stems[stemNumber]
        let result = stem.isSelected(id: id, type: type)
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
    public func getFormatWith(id: String) -> AudioFormat?{
        for audioFormat in audioFormats{
            if audioFormat.id == id {
                return audioFormat
            }
        }
        return nil
    }
    public func deleteAudioFormatWith(id: String){
        for i in 0..<audioFormats.count {
            let audioFormat = audioFormats[i]
            if audioFormat.id == id {
                audioFormats.remove(at: i)
                return
            }
        }
        for stem in stems{
            stem.deleteAudioFormatWith(id: id)
        }
    }
    func updateValuesFor(audioFormatId: String, newAudioFormat: AudioFormat) {
        for existingFormat in audioFormats{
            if existingFormat.id == audioFormatId {
                existingFormat.updateValuesWith(audioFormat: newAudioFormat)
            }
        }
    }
}
