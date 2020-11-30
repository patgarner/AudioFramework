//
//  StemDelegates.swift
//  AudioFramework
//
//  Created by Admin on 10/27/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

public protocol StemCreatorDelegate { //These absolutely need to call back to AudioController
    func muteAllExcept(channelIds: [String]) 
    func exportStem(to url: URL, includeMP3: Bool, number: Int)
}

public protocol StemViewDelegate{
    var numChannels : Int { get } //YES
    func getNameFor(channelId : String) -> String?
    func getIdFor(channel: Int) -> String?
    func prepareForStemExport(destinationFolder: URL)
    func muteAllExcept(channelIds: [String]) 
    func exportStem(to url: URL, includeMP3: Bool, number: Int)
    func stemExportComplete()
}

public protocol StemRowViewDelegate{
    func refresh()
    func isSelected(stemNumber: Int, channelId: String) -> Bool
    var numStems : Int { get } //YES
    func getNameFor(stemNumber: Int) -> String?
    func setName(stemNumber: Int, name: String)
    func selectionChangedTo(selected: Bool, stemNumber: Int, channelId: String)
    func delete(stemNumber: Int)
    func stemIncludedDidChangeTo(include: Bool, stemNumber: Int)
    func isIncluded(stemNumber: Int) -> Bool
    //Pass Through
    var numChannels : Int { get } //YES
    func getNameFor(channelId : String) -> String?
    func getIdFor(channel: Int) -> String?
}

public protocol StemCheckboxDelegate{
    func getNameFor(channelId : String) -> String?
    func checkboxChangedTo(selected: Bool, channelId: String)
    func isSelected(channelId: String) -> Bool
    func changeMultiple(to selected: Bool, location: NSPoint)
}

