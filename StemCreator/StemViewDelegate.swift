//
//  StemViewDelegate.swift
//  AudioFramework
//
//  Created by Admin on 9/25/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

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
    func export(url: URL)
    var namePrefix : String { get set }
}

public protocol StemRowViewDelegate{
    func refresh()
}
