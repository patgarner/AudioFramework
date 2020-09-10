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
    @IBOutlet weak var audioFXPopup2: NSPopUpButton!
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
        audioFXPopup.action = #selector(audioEffectChanged)
        audioFXPopup2.target = self
        audioFXPopup2.action = #selector(audioEffectChanged)
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
        labelView.isHidden = true
        if type == .master {
            self.trackNameField.stringValue = "Master"
            self.trackNameField.isEditable = false
            instrumentPopup.isHidden = true
        }  
        
        reloadInstruments()
        select(popup: instrumentPopup, list: instrumentsFlat, pluginSelection: state.virtualInstrument)
        
        fillEffectsPopup()
        let effectsPopups = [audioFXPopup!, audioFXPopup2!]
        for i in 0..<effectsPopups.count{
            let pluginSelection = state.getEffect(number: i)
            let popup = effectsPopups[i]
            select(popup: popup, list: getListOfEffects(), pluginSelection: pluginSelection)
        }
    }
    private func select(popup: NSPopUpButton, list: [AVAudioUnitComponent], pluginSelection: PluginSelection?){
        guard let pluginSelection = pluginSelection else { return }
        for i in 0..<list.count{
            let item = list[i]
            let manufacturer = item.manufacturerName
            let name = item.name
            if manufacturer == pluginSelection.manufacturer,
            name == pluginSelection.name{
                popup.selectItem(at: i)
                break
            }
        }
    }
    @objc func volumeSliderMoved(){
        let sliderValue = volumeSlider.integerValue
        volumeValueTextField.integerValue = sliderValue
        volumeValueTextField.needsDisplay = true
        if type == .master{
            let volumeFloat = Float(sliderValue) / 128.0
            delegate?.setMasterVolume(volumeFloat)
            return 
        } else if type == .midiInstrument{
            delegate?.set(volume: sliderValue, channel: trackNumber)
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
        if let existingState = delegate?.getChannelState(trackNumber){
            existingState.pan = pan
        }
    }
    @objc func audioEffectChanged(sender: Any){
        guard let popupButton = sender as? NSPopUpButton else { return }
        guard let channelState = delegate?.getChannelState(trackNumber) else { return }
        let number = popupButton.tag
        let index = popupButton.indexOfSelectedItem
        let effects = getListOfEffects()
        let effect = effects[index]
        let effectSelection = PluginSelection(manufacturer: effect.manufacturerName, name: effect.name)
        if let channelEffect = channelState.getEffect(number: number), channelEffect.manufacturer == effect.manufacturerName, channelEffect.name == effect.name {
            //If its already there, and it matches current selection, simply show interface
            instrumentSelectionDelegate?.displayEffectInterface(channel: trackNumber, number: number)
        } else {
            channelState.set(effect: effectSelection, number: number)
            instrumentSelectionDelegate?.select(effect: effect, channel: trackNumber, number: number)
        }
    }
    ////////////////////////////////////////////////////////
    // Instruments
    /////////////////////////////////////////////////////////
    private func reloadInstruments() {
        if let instruments = instrumentSelectionDelegate?.getListOfInstruments(){
            instrumentsFlat = instruments
            fillInstrumentPopup()
        }
    }
    private func fillInstrumentPopup(){
        instrumentPopup.removeAllItems()
        for instrument in instrumentsFlat{
            let string = getMenuTitleFrom(instrument: instrument)
            instrumentPopup.addItem(withTitle: string)
        }
        instrumentPopup.addItem(withTitle: "")
        instrumentPopup.selectItem(at: instrumentPopup.numberOfItems - 1)
    }
    private func getMenuTitleFrom(instrument: AVAudioUnitComponent) -> String{
        let string = instrument.manufacturerName + "-" + instrument.name
        return string
    }
    var instrumentsByManufacturer: [(String, [AVAudioUnitComponent])] = []
    var instrumentsFlat : [AVAudioUnitComponent] = []
    var instrumentSelectionDelegate : InstrumentSelectionDelegate?
    @objc func instrumentChanged(){
        guard let channelState = delegate?.getChannelState(trackNumber) else { return }
        let index = instrumentPopup.indexOfSelectedItem
        let component = instrumentsFlat[index]
        if component.manufacturerName == channelState.virtualInstrument.manufacturer,
            component.name == channelState.virtualInstrument.name {
            instrumentSelectionDelegate?.displayInstrumentInterface(channel: trackNumber)
            return
        } else {
            channelState.virtualInstrument.manufacturer = component.manufacturerName
            channelState.virtualInstrument.name = component.name
            instrumentSelectionDelegate?.selectInstrument(component, channel: trackNumber)
            return
        }
    }
    /////////////////////////////////////////////////////////////////
    // Effects
    /////////////////////////////////////////////////////////////////
    func getListOfEffects() -> [AVAudioUnitComponent]{ //TODO: It shouldn't have this much information in here
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
        let popups = [audioFXPopup!, audioFXPopup2!]
        for popup in popups{
            popup.removeAllItems()
            for effect in effects {
                let longName = effect.manufacturerName + "-" + effect.name
                popup.addItem(withTitle: longName)
            }
            popup.addItem(withTitle: "")
            popup.selectItem(at: audioFXPopup.numberOfItems - 1)
        }
    }
}

enum ChannelViewType {
    case master
    case midiInstrument
    case aux
    case labels
}
