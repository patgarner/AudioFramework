//
//  ChannelViewDelegate.swift
//  Composer Bot Desktop
//
//  Created by Admin on 9/25/19.
//  Copyright © 2019 UltraMusician. All rights reserved.
//

import Foundation

public protocol ChannelViewDelegate {
    func getChannelState(_ index: Int) -> ChannelState?
    func set(channelState: ChannelState, index: Int)
    func setMasterVolume(_ volume: Float)
}
