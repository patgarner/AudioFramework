//
//  BeatDelegate.swift
//  Ultra Jam Session
//
//  Created by Admin on 11/30/16.
//  Copyright © 2016 UltraMusician. All rights reserved.
//

import Foundation

public protocol BeatDelegate{
    func didPlayBeat(_ beat: Double, absoluteBeat: Double)
}
