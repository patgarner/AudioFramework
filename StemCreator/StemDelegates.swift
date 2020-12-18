//
//  StemDelegates.swift
//  AudioFramework
//
//  Created by Admin on 10/27/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation
import AVFoundation

public protocol StemCreatorDelegate { //These absolutely need to call back to AudioController
    func muteAllExcept(channelIds: [String]) 
    func exportStem(to url: URL, includeMP3: Bool, number: Int, sampleRate: Int)
    func exportStem(to url: URL, number: Int, formats: [AudioFormat])
}

public protocol StemViewDelegate{
    var numChannels : Int { get } //YES
    func getNameFor(channelId : String) -> String?
    func getIdFor(channel: Int) -> String?
    func prepareForStemExport(destinationFolder: URL)
    func muteAllExcept(channelIds: [String]) 
    func exportStem(to url: URL, includeMP3: Bool, number: Int, sampleRate: Int)
    func exportStem(to url: URL, number: Int, formats: [AudioFormat])
    func stemExportComplete()
    func cancelStemExport()
}

public protocol StemRowViewDelegate{
    func refresh()
    func isSelected(stemNumber: Int, channelId: String) -> Bool
    var numStems : Int { get } //YES
    func getNameFor(stemNumber: Int) -> String?
    func setName(stemNumber: Int, name: String)
    func selectionChangedTo(selected: Bool, stemNumber: Int, id: String, type: ColumnType)
    func delete(stemNumber: Int)
    func stemIncludedDidChangeTo(include: Bool, stemNumber: Int)
    func isIncluded(stemNumber: Int) -> Bool
    var audioFormats : [AudioFormat] { get }
    //Pass Through
    var numChannels : Int { get } //YES
    func getNameFor(channelId : String) -> String?
    func getIdFor(channel: Int) -> String?
    func didSelect(audioFormatId: String)
//    func audioFormatSelectionChangedTo(selected: Bool, stemNumber: Int, audioFormatId: String)
}

public protocol StemCheckboxDelegate{
    func getNameFor(channelId : String) -> String?
    func selectionChangedTo(selected: Bool, id: String, type: ColumnType)
//    func audioFormatSelectionChangedTo(selected: Bool, audioFormatId: String)
    func isSelected(id: String) -> Bool
    func changeMultiple(to selected: Bool, location: NSPoint)
    func didSelect(audioFormatId: String)

}

