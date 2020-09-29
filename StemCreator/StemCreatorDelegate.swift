//
//  StemCreatorDelegate.swift
//  AudioFramework
//
//  Created by Admin on 9/26/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

public protocol StemCreatorDelegate {
    func set(mute: Bool, for channelId: String)
    func muteAllExcept(channelIds: [String])
}
