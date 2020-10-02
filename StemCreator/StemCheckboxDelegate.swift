//
//  StemCheckboxDelegate.swift
//  AudioFramework
//
//  Created by Admin on 9/26/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public protocol StemCheckboxDelegate{
    func getNameFor(channelId : String) -> String?
    func checkboxChangedTo(selected: Bool, channelId: String)
    func isSelected(channelId: String) -> Bool
    func changeMultiple(to selected: Bool, location: NSPoint)
}
