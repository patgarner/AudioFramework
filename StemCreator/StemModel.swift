//
//  StemModel.swift
//  AudioFramework
//
//  Created by Admin on 9/25/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public class StemModel : Codable, Equatable{
    var stemShortName = ""
    var channelIds : [String] = []
    public static func == (lhs: StemModel, rhs: StemModel) -> Bool {
        return false
    }
    func selectionChanged(selected: Bool, channelId: String){
        //Four cases: 
        //False with no channel id - don't need to delete it. Do nothing.
        //False with channel id
        //True with no channel id
        //True with channel id - already have it. Do nothing.
        if let index = indexOf(channelId: channelId){
            if !selected {
                channelIds.remove(at: index)
            }
        } else {
            if selected{
                channelIds.append(channelId)
            }
        }
        
    }
    private func indexOf(channelId: String) -> Int?{
        for i in 0..<channelIds.count{
            let thisId = channelIds[i]
            if thisId == channelId { return i }
        }
        return nil
    }
    func isSelected(channelId: String) -> Bool{
        if let _ = indexOf(channelId: channelId){
            return true
        } else { 
            return false
        }
    }
}
