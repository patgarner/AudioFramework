//
//  ChannelCollectionViewItem.swift
//  Composer Bot Desktop
//
//  Created by Admin on 7/11/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Cocoa
import AVFoundation

public class ChannelCollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var instrumentPopup: NSPopUpButton!
    @IBOutlet weak var audioFXPopup: NSPopUpButton!
    @IBOutlet weak var sendPopup: NSPopUpButton!
    @IBOutlet weak var sendLevelKnob: NSSlider!
    @IBOutlet weak var panKnob: NSSlider!
    @IBOutlet weak var volumeValueTextField: NSTextField!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var soloButton: NSButton!
    @IBOutlet weak var muteButton: NSButton!
    @IBOutlet weak var trackNameField: NSTextField!
    
    @IBOutlet weak var labelView: MixerFillView!
    @IBOutlet weak var labelViewTrailingConstraint: NSLayoutConstraint!
    var delegate : ChannelViewDelegate? 
    var trackNumber = -1
    var type = ChannelViewType.midiInstrument
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        instrumentPopup.target = self
        instrumentPopup.action = #selector(instrumentChanged)
        audioFXPopup.target = self
        audioFXPopup.action = #selector(audioFXChanged)
        volumeValueTextField.target = self
        volumeValueTextField.action = #selector(volumeTextChanged)
        panKnob.target = self
        panKnob.action = #selector(panChanged)
        volumeSlider.target = self
        volumeSlider.action = #selector(volumeSliderMoved)
        muteButton.target = self
        muteButton.action = #selector(muteChanged)
        soloButton.target = self
        soloButton.action = #selector(soloChanged)
        trackNameField.target = self
        trackNameField.action = #selector(trackNameChanged)
        refresh()
    }
    public func refresh(){
        if type == .labels{
            labelView.color = NSColor.systemGray
            labelViewTrailingConstraint.constant = 0
            labelView.isHidden = false
            labelView.needsLayout = true
            return
        }
        guard let state = delegate?.getChannelState(trackNumber) else { return }
        trackNameField.stringValue = state.trackName
        if state.mute{
            muteButton.state = .on
        } else {
            muteButton.state = .off
        }
        if state.solo{
            soloButton.state = .on
        } else {
            soloButton.state = .off
        }
        volumeSlider.integerValue = state.volume
        volumeValueTextField.integerValue = state.volume
        panKnob.integerValue = (state.pan + 64) % 128
        fillEffectsPopup()
        reloadInstruments()
        labelView.isHidden = true
        if type == .master {
            self.trackNameField.stringValue = "Master"
            self.trackNameField.isEditable = false
            instrumentPopup.isHidden = true
        }  
    }
    @objc func volumeSliderMoved(){
        let sliderValue = volumeSlider.integerValue
        print("slider moved. value = \(sliderValue)")
        volumeValueTextField.integerValue = sliderValue
        volumeValueTextField.needsDisplay = true
        if type == .master{ //TODO: Move to another location.
            let volumeFloat = Float(sliderValue) / 128.0
            delegate?.setMasterVolume(volumeFloat)
            return 
        }
        if let existingState = delegate?.getChannelState(trackNumber){
            volumeValueTextField.integerValue = sliderValue
            existingState.volume = sliderValue
        }
    }
    @objc func trackNameChanged(){
        let trackName = trackNameField.stringValue
        if let existingState = delegate?.getChannelState(trackNumber){
            existingState.trackName = trackName
        }
        
    }
    @objc func volumeTextChanged(){
        let volumeString = volumeValueTextField.stringValue
        guard let volume = Int(volumeString) else {
            volumeSliderMoved()
            return
        }
      //  let volume = volumeValueTextField.integerValue
        if let existingState = delegate?.getChannelState(trackNumber){
            existingState.volume = volume
            volumeSlider.integerValue = volume
        }
    }
    @objc func muteChanged(){
        let mute = muteButton.state
        if let existingState = delegate?.getChannelState(trackNumber){
            existingState.mute = (mute == .on) 
        }
    }
    @objc func soloChanged(){
        let solo = soloButton.state
        if let existingState = delegate?.getChannelState(trackNumber){
            existingState.solo = (solo == .on) 
        }
    }
    @objc func panChanged(){
        let pan = (panKnob.integerValue + 64) % 127
        print("pan \(pan)")
        if let existingState = delegate?.getChannelState(trackNumber){
            existingState.pan = pan
        }
    }
    @objc func audioFXChanged(){
        let effectIndex = audioFXPopup.indexOfSelectedItem
        let effects = getListOfEffects()
        let effect = effects[effectIndex]
        instrumentSelectionDelegate?.select(effect: effect, channel: self.trackNumber)
    }
    ////////////////////////////////////////////////////////
    // Instruments
    /////////////////////////////////////////////////////////
    private func reloadInstruments() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let s = self else { return }
            if let instruments = s.instrumentSelectionDelegate?.getListOfInstruments(){
                s.instrumentsFlat = instruments
                  DispatchQueue.main.async {
                      s.fillInstrumentPopup()
                  }
            }
        }
    }
    private func fillInstrumentPopup(){
        instrumentPopup.removeAllItems()
        for instrument in instrumentsFlat{
            let string = instrument.manufacturerName + "-" + instrument.name
            instrumentPopup.addItem(withTitle: string)
        }
        instrumentPopup.addItem(withTitle: "")
        instrumentPopup.selectItem(at: instrumentPopup.numberOfItems - 1)
    }
    var instrumentsByManufacturer: [(String, [AVAudioUnitComponent])] = []
    var instrumentsFlat : [AVAudioUnitComponent] = []
    var instrumentSelectionDelegate : InstrumentSelectionDelegate?
    @objc func instrumentChanged(){
        let selection = instrumentPopup.indexOfSelectedItem
        let component = instrumentsFlat[selection]
        instrumentSelectionDelegate?.selectInstrument(component, channel: trackNumber)
    }
    /////////////////////////////////////////////////////////////////
    // Effects
    /////////////////////////////////////////////////////////////////
    func getListOfEffects() -> [AVAudioUnitComponent]{
        var desc = AudioComponentDescription()
        desc.componentType = kAudioUnitType_Effect
        desc.componentSubType = 0
        desc.componentManufacturer = 0
        desc.componentFlags = 0
        desc.componentFlagsMask = 0
        return AVAudioUnitComponentManager.shared().components(matching: desc)
    }
    func fillEffectsPopup(){
        let effects = getListOfEffects()
        audioFXPopup.removeAllItems()
        for effect in effects {
            let longName = effect.manufacturerName + "-" + effect.name
            audioFXPopup.addItem(withTitle: longName)
        }
        audioFXPopup.addItem(withTitle: "")
        audioFXPopup.selectItem(at: audioFXPopup.numberOfItems - 1)

    }
}

enum ChannelViewType {
    case master
    case midiInstrument
    case bus
    case labels
}
