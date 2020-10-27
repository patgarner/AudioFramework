//
//  StemDelegates.swift
//  AudioFramework
//
//  Created by Admin on 10/27/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

public protocol StemCreatorDelegate {
    func set(mute: Bool, for channelId: String)
    func muteAllExcept(channelIds: [String])
    func exportStem(to url: URL, includeMP3: Bool, number: Int)
}

public protocol StemViewDelegate{
    var numChannels : Int { get }
    var numStems : Int { get }
    func getNameFor(channelId : String) -> String?
    func addStem()
    func getNameFor(stem: Int) -> String?
    func setName(stemNumber: Int, name: String)
    func getIdFor(channel: Int) -> String?
    func selectionChangedTo(selected: Bool, stemNumber: Int, channelId: String)
    func isSelected(stemNumber: Int, channelId: String) -> Bool
    func delete(stemNumber: Int)
    func exportStems(destinationFolder: URL)
    var namePrefix : String { get set }
}

public protocol StemRowViewDelegate{
    func refresh()
}

public protocol StemCheckboxDelegate{
    func getNameFor(channelId : String) -> String?
    func checkboxChangedTo(selected: Bool, channelId: String)
    func isSelected(channelId: String) -> Bool
    func changeMultiple(to selected: Bool, location: NSPoint)
}

