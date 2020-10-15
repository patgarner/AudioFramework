//
//  AudioUnitViewController.swift
//  PassThroughNode
//
//  Created by Admin on 10/14/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AUAudioUnit?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if audioUnit == nil {
            return
        }
        
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try PassThroughNodeAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
    
}
