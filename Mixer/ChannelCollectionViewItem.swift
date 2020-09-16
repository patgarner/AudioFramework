//
//  ChannelCollectionViewItem.swift
//  
/*
 Copyright 2020 David Mann Music LLC
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Cocoa
import AVFoundation

public class ChannelCollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var inputPopup: NSPopUpButton!
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
    var delegate : ChannelViewDelegate! 
    var trackNumber = -1
    var type = ChannelType.midiInstrument
    var instrumentsByManufacturer: [(String, [AVAudioUnitComponent])] = []
    var instrumentsFlat : [AVAudioUnitComponent] = []
    var pluginSelectionDelegate : PluginSelectionDelegate!
    override public func viewDidLoad() {
        super.viewDidLoad()
        inputPopup.target = self
        inputPopup.action = #selector(inputChanged)
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
        sendPopup.target = self
        sendPopup.action = #selector(sendChanged)
        sendLevelKnob.target = self
        sendLevelKnob.action = #selector(sendLevelChanged)
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
        guard let state = delegate?.getChannelState(trackNumber, type: type) else { return }
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
            inputPopup.isHidden = true
        }  else if type == .aux {
            labelView.color = NSColor(calibratedRed: 0.68, green: 0.75, blue: 0.85, alpha: 1.0)
            self.trackNameField.stringValue = "Aux " + String(trackNumber + 1)
            self.trackNameField.isEditable = false
            reloadInstruments()
        } else if type == .midiInstrument{
            reloadInstruments()
            let instrumentSelection = pluginSelectionDelegate.getPluginSelection(channel: trackNumber, channelType: type, pluginType: .instrument, pluginNumber: 0)
            select(popup: inputPopup, list: instrumentsFlat, pluginSelection: instrumentSelection)
        }

        fillSendPopup()
        
        fillEffectsPopup()
        let effectsPopups = [audioFXPopup!, audioFXPopup2!]
        for i in 0..<effectsPopups.count{
            let pluginSelection = pluginSelectionDelegate.getPluginSelection(channel: trackNumber, channelType: type, pluginType: .effect, pluginNumber: i)
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
    @objc private func sendChanged(){
        let index = sendPopup.indexOfSelectedItem
        pluginSelectionDelegate.select(sendNumber: 0, bus: index, channel: trackNumber, channelType: type)
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
        if let existingState = delegate?.getChannelState(trackNumber, type: type){
            volumeValueTextField.integerValue = sliderValue
            existingState.volume = sliderValue
        }
    }
    @objc func trackNameChanged(){
        let trackName = trackNameField.stringValue
        if let existingState = delegate?.getChannelState(trackNumber, type: type){
            existingState.trackName = trackName
        }
        
    }
    @objc func volumeTextChanged(){
        let volumeString = volumeValueTextField.stringValue
        guard let volume = Int(volumeString) else {
            volumeSliderMoved()
            return
        }
        if let existingState = delegate?.getChannelState(trackNumber, type: type){
            existingState.volume = volume
            volumeSlider.integerValue = volume
        }
    }
    @objc func muteChanged(){
        let mute = muteButton.state
        if let existingState = delegate?.getChannelState(trackNumber, type: type){
            existingState.mute = (mute == .on) 
        }
    }
    @objc func soloChanged(){
        let solo = soloButton.state
        if let existingState = delegate?.getChannelState(trackNumber, type: type){
            existingState.solo = (solo == .on) 
        }
    }
    @objc func panChanged(){
        let pan = (panKnob.integerValue + 64) % 127
        if let existingState = delegate?.getChannelState(trackNumber, type: type){
            existingState.pan = pan
        }
    }
    @objc func audioEffectChanged(sender: Any){
        guard let popupButton = sender as? NSPopUpButton else { return }
        let number = popupButton.tag
        let index = popupButton.indexOfSelectedItem
        let effects = getListOfEffects()
        if index >= effects.count {
            pluginSelectionDelegate.deselectEffect(channel: trackNumber, number: number, type: type)
            return
        }
        let effect = effects[index]
        if let previousEffect = pluginSelectionDelegate.getPluginSelection(channel: trackNumber, channelType: type, pluginType: .effect, pluginNumber: number), previousEffect.manufacturer == effect.manufacturerName, previousEffect.name == effect.name {
            pluginSelectionDelegate.displayEffectInterface(channel: trackNumber, number: number, type: type)
        } else {
            pluginSelectionDelegate.select(effect: effect, channel: trackNumber, number: number, type: type)
        }
    }
    ////////////////////////////////////////////////////////
    // Instruments
    /////////////////////////////////////////////////////////
    private func reloadInstruments() {
        let instruments = pluginSelectionDelegate.getListOfInstruments()
        instrumentsFlat = instruments
        fillInputPopup()
    }
    private func fillInputPopup(){
        if type == .midiInstrument {
            fillInstruments()
        } else if type == .aux{
            fillBusInputs()
        }
    }
    private func fillInstruments(){
        inputPopup.removeAllItems()
        for instrument in instrumentsFlat{
            let string = instrument.manufacturerName + "-" + instrument.name

            inputPopup.addItem(withTitle: string)
        }
        inputPopup.addItem(withTitle: "")
        inputPopup.selectItem(at: inputPopup.numberOfItems - 1)
    }
    private func fillBusInputs(){
        inputPopup.removeAllItems()
        for title in getBusList(){
            inputPopup.addItem(withTitle: title)
        }
    }

    @objc func inputChanged(){
        if type == .aux {
            audioInputChanged() 
        } else if type == .midiInstrument{
            inputInstrumentChanged()
        }
    }
    private func inputInstrumentChanged(){
        let index = inputPopup.indexOfSelectedItem
        let component = instrumentsFlat[index]
        if let virtualInstrument = pluginSelectionDelegate.getPluginSelection(channel: trackNumber, channelType: type, pluginType: .instrument, pluginNumber: -1), component.manufacturerName == virtualInstrument.manufacturer,
            component.name == virtualInstrument.name {
            pluginSelectionDelegate.displayInstrumentInterface(channel: trackNumber)
            return
        } else {
            pluginSelectionDelegate.selectInstrument(component, channel: trackNumber, type: type)
            return
        }
    }
    private func audioInputChanged(){
        let index = inputPopup.indexOfSelectedItem
        pluginSelectionDelegate.selectInputBus(number: index, channel: trackNumber, channelType: type)
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
    ///////////////////////////////////////////////////
    //
    ///////////////////////////////////////////////////
    func fillSendPopup(){
        sendPopup.removeAllItems()
        for title in getBusList(){
            sendPopup.addItem(withTitle: title)
        }
    }
    func getBusList() -> [String]{
        let numBusses = pluginSelectionDelegate.numBusses()
        var busList : [String] = [""]
        for i in 0..<numBusses{
            let title = "Bus " + String(i+1)
            busList.append(title)
        }
        return busList
    }
    @objc func sendLevelChanged(){
        let blackoutRegion = 0.2
        let upperLim = 0.5 + (blackoutRegion * 0.5)
        let lowerLim = 0.5 - (blackoutRegion * 0.5)
        var rawValue = sendLevelKnob.doubleValue
        if rawValue >= 0.5, rawValue < upperLim{
            rawValue = upperLim
            sendLevelKnob.doubleValue = rawValue
        } else if rawValue < 0.5, rawValue > lowerLim{
            rawValue = lowerLim
            sendLevelKnob.doubleValue = rawValue
        } 
        let rotatedValue = (rawValue + 0.5).truncatingRemainder(dividingBy: 1.0)
        let nonBlackoutRegion = 1.0 - blackoutRegion
        var calibratedValue = (rotatedValue - blackoutRegion * 0.5) / nonBlackoutRegion
        if calibratedValue < 0.000001 { calibratedValue = 0 }
        pluginSelectionDelegate.setSend(volume: calibratedValue, sendNumber: 0, channelNumber: trackNumber, channelType: type)
    }
}

public enum ChannelType {
    case master
    case midiInstrument
    case aux
    case labels
}
