//
//  StemModel.swift
//  AudioFramework
//
//  Created by Admin on 9/25/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation

public class StemModel : Codable, Equatable{
    var stemShortName = ""
    var channelIds : [String] = []
    var include = true
    var audioFormatIds : [String] = []
    public static func == (lhs: StemModel, rhs: StemModel) -> Bool {
        if lhs.stemShortName != rhs.stemShortName { return false }
        if lhs.channelIds.count != rhs.channelIds.count { return false}
        for i in 0..<lhs.channelIds.count {
            if lhs.channelIds[i] != rhs.channelIds[i] { return false}
        }
        if lhs.include != rhs.include { return false }
        if lhs.audioFormatIds.count != rhs.audioFormatIds.count { return false }
        for i in 0..<lhs.audioFormatIds.count {
            if lhs.audioFormatIds[i] != rhs.audioFormatIds[i] { return false }
        }
        return true
    }
    func selectionChanged(selected: Bool, id: String, type: ColumnType){
        if type == .channel {
            channelSelectionChanged(selected: selected, id: id)
        } else if type == .fileType{
            audioFormatSelectionChanged(selected: selected, id: id)
        }
    }
    private func channelSelectionChanged(selected: Bool, id: String){
        //Case 1: False with channel id - delete it
        //Case 2: True with no channel id - add it
        //Case 3: False with no channel id - don't need to delete it. Do nothing.
        //Case 4: True with channel id - already have it. Do nothing.
        if let index = indexOf(channelId: id), !selected {
            channelIds.remove(at: index)
        } else if selected{
            channelIds.append(id)
        }
    }
    private func audioFormatSelectionChanged(selected: Bool, id: String){
        if let index = indexOf(audioFormatId: id), !selected {
            audioFormatIds.remove(at: index)
        } else if selected{
            audioFormatIds.append(id)
        }
    }
    private func indexOf(channelId: String) -> Int?{
        for i in 0..<channelIds.count{
            let thisId = channelIds[i]
            if thisId == channelId { return i }
        }
        return nil
    }
    private func indexOf(audioFormatId: String) -> Int?{
        for i in 0..<audioFormatIds.count{
            let thisId = audioFormatIds[i]
            if thisId == audioFormatId { return i }
        }
        return nil
    }
    public func isSelected(id: String) -> Bool{
        if let _ = indexOf(channelId: id){
            return true
        } 
        if let _ = indexOf(audioFormatId: id){
            return true
        }
        return false
    }
    func deleteAudioFormatWith(id: String){
        for i in 0..<audioFormatIds.count{
            let thisId = audioFormatIds[i]
            if thisId == id {
                audioFormatIds.remove(at: i)
            }
        }
    }
}
