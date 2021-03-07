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
    func exportStem(to url: URL, number: Int, formats: [AudioFormat], headLength: Double, tailLength: Double)
}

public protocol StemViewDelegate{
    var numChannels : Int { get } //YES
    func getNameFor(channelId : String) -> String?
    func getIdFor(channel: Int) -> String?
    func prepareForStemExport(destinationFolder: URL)
    func muteAllExcept(channelIds: [String]) 
    func exportStem(to url: URL, number: Int, formats: [AudioFormat], headLength: Double, tailLength: Double)
    func stemExportComplete()
    func cancelStemExport()
    func getTempo() -> Double
}

public protocol StemRowViewDelegate{
    func refresh()
    func isSelected(stemNumber: Int, id: String, type: ColumnType) -> Bool
    var numStems : Int { get } //YES
    func getNameFor(stemNumber: Int) -> String?
    func setName(stemNumber: Int, name: String)
    func selectionChangedTo(selected: Bool, stemNumber: Int, id: String, type: ColumnType)
    func delete(stemNumber: Int)
    func stemIncludedDidChangeTo(include: Bool, stemNumber: Int)
    func isIncluded(stemNumber: Int) -> Bool
    var audioFormats : [AudioFormat] { get }
    func addFormat()
    func getLetterFor(stemNumber : Int) -> String?
    func set(letter: String, stemNumber: Int)
    //Pass Through
    var numChannels : Int { get } //YES
    func getNameFor(channelId : String) -> String?
    func getIdFor(channel: Int) -> String?
    func didSelect(audioFormatId: String)
    func stemRowValueChanged(gestureRect: CGRect, buttonType: DraggableButtonType, newState: Bool/*NSControl.StateValue*/)
}

public protocol StemCheckboxDelegate{
    func getNameFor(channelId : String) -> String?
    func selectionChangedTo(selected: Bool, id: String, type: ColumnType)
    func isSelected(id: String, type: ColumnType) -> Bool
    func changeMultiple(to selected: Bool, location: NSPoint)
    func didSelect(audioFormatId: String)

}

