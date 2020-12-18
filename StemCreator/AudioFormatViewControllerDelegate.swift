//
//  AudioFormatViewControllerDelegate.swift
//  AudioFramework
//
//  Created by Admin on 12/17/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Foundation

protocol AudioFormatViewControllerDelegate{
    func deleteAudioFormatWith(id: String)
    func updateValuesFor(audioFormatId: String, newAudioFormat: AudioFormat)
}
