//
//  FakeChannelControllerDelegate.swift
//  AudioFrameworkDemoTests
//
//  Created by Admin on 10/16/20.
//  Copyright © 2020 David Mann Music LLC. All rights reserved.
//

import Foundation
import AudioFramework
import AVFoundation

class FakeChannelControllerDelegate : ChannelControllerDelegate{
    func soloValueChanges(gestureRect: CGRect, buttonType: DraggableButtonType, newState: Bool/*NSControl.StateValue*/) {
        
    }
    
    let fakeContextBlock = FakeMusicalContext()
    var numBusses: Int{
        return 0
    }
    
    func log(_ message: String) {
        
    }
    
    var engine: AVAudioEngine = AVAudioEngine()
    
    func soloDidChange() {
        
    }
    
    func didSelectChannel() {
        
    }
    
    func getOutputDestination(for node: AVAudioNode) -> BusInfo {
        let busInfo = BusInfo()
        return BusInfo()
    }
    
    func connect(sourceNode: AVAudioNode, destinationNumber: Int, destinationType: BusType) {
        
    }
    
    func getBusInput(for node: AVAudioNode) -> Int? {
        return nil
    }
    
    func connect(busNumber: Int, destinationNode: AVAudioNode) {
        
    }
    
    func displayInterface(audioUnit: AVAudioUnit) {
        
    }
    
    func contextBlock() -> AUHostMusicalContextBlock {
        return fakeContextBlock.getMusicalContext
    }
    
    func connect(sourceNode: AVAudioNode, destinationNode: AVAudioNode) {
        
    }
    func connect(sourceNode: AVAudioNode, destinationNode: AVAudioNode, bus: Int?) {
        
    }
    
    func getAudioComponentList(type: PluginType) -> [AVAudioUnitComponent] {
        return []
    }
}
