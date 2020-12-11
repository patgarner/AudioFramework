//
//  PluginDisplayDelegate.swift
//  AudioFramework
//
//  Created by Admin on 10/10/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation
import CoreAudioKit

public protocol PluginDisplayDelegate {
    func display(viewController: AUViewController)
}
