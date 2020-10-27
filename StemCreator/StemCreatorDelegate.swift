//
//  StemCreatorDelegate.swift
//  AudioFramework
//
//  Created by Admin on 9/26/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import AVFoundation

public protocol StemCreatorDelegate {
    func set(mute: Bool, for channelId: String)
    func muteAllExcept(channelIds: [String])
    func exportStem(to url: URL, includeMP3: Bool, number: Int)
}
