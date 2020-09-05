//
//  AudioServiceDelegate.swift
//  AudioFramework
//
//  Created by Admin on 9/1/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation
import Cocoa

public protocol AudioServiceDelegate{
    func load(viewController: NSViewController)
    func log(_ message : String)
}
