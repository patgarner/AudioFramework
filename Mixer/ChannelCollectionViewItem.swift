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
    @IBOutlet weak var mixerFillView: MixerFillView!
    @IBOutlet weak var inputPopup: NSPopUpButton!
    @IBOutlet weak var audioFXPopup: NSPopUpButton!
    @IBOutlet weak var audioFXPopup2: NSPopUpButton!
    @IBOutlet weak var sendPopup1: NSPopUpButton!
    @IBOutlet weak var sendLevelKnob1: NSSlider!
    @IBOutlet weak var sendPopup2: NSPopUpButton!
    @IBOutlet weak var sendLevelKnob2: NSSlider!
    @IBOutlet weak var panKnob: NSSlider!
    @IBOutlet weak var volumeValueTextField: NSTextField!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var soloButton: NSButton!
    @IBOutlet weak var muteButton: NSButton!
    @IBOutlet weak var trackNameField: NSTextField!
    @IBOutlet weak var labelView: MixerFillView!
    @IBOutlet weak var labelViewTrailingConstraint: NSLayoutConstraint!
    var pluginSelectionDelegate : PluginSelectionDelegate!
    var channelViewDelegate : ChannelViewDelegate!
    var channelNumber = -1
    var type = ChannelType.midiInstrument
    //var selected = false
    private var instrumentsByManufacturer: [(String, [AVAudioUnitComponent])] = []
    private var instrumentsFlat : [AVAudioUnitComponent] = []
    
    @IBOutlet weak var vuMeterView: VUMeterView!
    override public func viewDidLoad() {
        super.viewDidLoad()
        inputPopup.target = self
        inputPopup.action = #selector(inputChanged)
        audioFXPopup.target = self
        audioFXPopup.action = #selector(audioEffectChanged)
        audioFXPopup2.target = self
        audioFXPopup2.action = #selector(audioEffectChanged)
        for sendPopup in sendPopups{
            sendPopup.target = self
            sendPopup.action = #selector(sendDestinationChanged)
            sendPopup.font = NSFont(name: "Helvetica", size: 12)
        }
        for sendLevelKnob in sendLevelKnobs{
            sendLevelKnob.target = self
            sendLevelKnob.action = #selector(sendLevelChanged)
        }
        panKnob.target = self
        panKnob.action = #selector(panChanged)        
        volumeValueTextField.target = self
        volumeValueTextField.action = #selector(volumeTextChanged)
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
        trackNameField.stringValue = channelViewDelegate.trackName
        if channelViewDelegate.mute{
            muteButton.state = .on
        } else {
            muteButton.state = .off
        }
        if channelViewDelegate.solo{
            soloButton.state = .on
        } else {
            soloButton.state = .off
        }
        volumeSlider.floatValue = channelViewDelegate.volume
        volumeValueTextField.floatValue = volumeSlider.floatValue
        let panValue = channelViewDelegate.pan
        set(popupButton: panKnob, value: panValue, blackoutRegion: 0.2, minValue: -1.0, maxValue: 1.0)
        labelView.isHidden = true
        if type == .master {
            self.trackNameField.stringValue = "Master"
            self.trackNameField.isEditable = false
            inputPopup.isHidden = true
            self.soloButton.isHidden = true
        }  else if type == .aux {
            labelView.color = NSColor(calibratedRed: 0.68, green: 0.75, blue: 0.85, alpha: 1.0)
            self.trackNameField.stringValue = "Aux " + String(channelNumber + 1)
            self.trackNameField.isEditable = false
            reloadInstruments()
        } else if type == .midiInstrument{
            reloadInstruments()
            let instrumentSelection = channelViewDelegate.getPluginSelection(pluginType: .instrument, pluginNumber: channelNumber)
            select(popup: inputPopup, list: instrumentsFlat, pluginSelection: instrumentSelection)
        }
        fillSendPopups()
        for i in 0..<sendLevelKnobs.count{
            guard let sendData = channelViewDelegate.getSendData(sendNumber: i) else { continue }
            let sendLevelKnob = sendLevelKnobs[i]
            self.set(popupButton: sendLevelKnob, value: sendData.level, blackoutRegion: 0.2, minValue: 0, maxValue: 1)

        }
        fillEffectsPopup()
        let effectsPopups = [audioFXPopup!, audioFXPopup2!]
        for i in 0..<effectsPopups.count{
            let pluginSelection = channelViewDelegate.getPluginSelection(pluginType: .effect, pluginNumber: i)
            let popup = effectsPopups[i]
            let effectList = getAudioComponentList(type: .effect)
            select(popup: popup, list: effectList, pluginSelection: pluginSelection)
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
        if let virtualInstrument = channelViewDelegate.getPluginSelection(pluginType: .instrument, pluginNumber: -1), component.manufacturerName == virtualInstrument.manufacturer,
            component.name == virtualInstrument.name {
            pluginSelectionDelegate.displayInstrumentInterface(channel: channelNumber)
            return
        } else {
            pluginSelectionDelegate.selectInstrument(component, channel: channelNumber, type: type)
            return
        }
    }
    private func audioInputChanged(){
        let index = inputPopup.indexOfSelectedItem
        channelViewDelegate.selectInput(busNumber: index)
    }
    @objc func audioEffectChanged(sender: Any){
        guard let popupButton = sender as? NSPopUpButton else { return }
        let number = popupButton.tag
        let index = popupButton.indexOfSelectedItem
        let effects = getAudioComponentList(type: .effect)
        if index >= effects.count {
            channelViewDelegate.deselectEffect(number: number)
            return
        }
        let effect = effects[index]
        if let previousEffect = channelViewDelegate.getPluginSelection(pluginType: .effect, pluginNumber: number), previousEffect.manufacturer == effect.manufacturerName, previousEffect.name == effect.name {
            pluginSelectionDelegate.displayEffectInterface(channel: channelNumber, number: number, type: type)
        } else {
            pluginSelectionDelegate.select(effect: effect, channel: channelNumber, number: number, type: type)
        }
    }
    @objc private func sendDestinationChanged(sender: Any){
        guard let popup = sender as? NSPopUpButton else { return }
        let index = popup.indexOfSelectedItem
        let sendNumber = popup.tag
        channelViewDelegate.select(sendNumber: sendNumber, busNumber: index, channel: channelNumber, channelType: type)
    }
    @objc func sendLevelChanged(sender: Any){
        guard let sendLevelKnob = sender as? NSSlider else { return }
        let value = getKnobLevel(blackoutRegion: 0.2, popupButton: sendLevelKnob, minValue: 0.0, maxValue: 1.0)
        let number = sendLevelKnob.tag
        channelViewDelegate.setSend(volume: value, sendNumber: number)
    }
    @objc func volumeTextChanged(){
        let volume = volumeValueTextField.floatValue
        volumeSlider.floatValue = volume
    }
    @objc func volumeSliderMoved(){
        let sliderValue = volumeSlider.floatValue
        volumeValueTextField.floatValue = sliderValue
        volumeValueTextField.needsDisplay = true
        channelViewDelegate.volume = sliderValue
    }
    @objc func trackNameChanged(){
        let trackName = trackNameField.stringValue
        channelViewDelegate.trackName = trackName
    }

    @objc func muteChanged(){
        let mute = muteButton.state
        channelViewDelegate.mute = (mute == .on)
    }
    @objc func soloChanged(){
        let solo = soloButton.state
        channelViewDelegate.solo = (solo == .on)
    }

    ////////////////////////////////////////////////////////
    // Instruments
    /////////////////////////////////////////////////////////
    private func reloadInstruments() {
        instrumentsFlat = getAudioComponentList(type: .instrument)
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
        if let busNumber = channelViewDelegate.getBusInputNumber(){
            inputPopup.selectItem(at: busNumber)
        } else {
            inputPopup.selectItem(at: inputPopup.numberOfItems - 1)
        }
    }


    /////////////////////////////////////////////////////////////////
    // Effects
    /////////////////////////////////////////////////////////////////
    public func getAudioComponentList(type: PluginType) -> [AVAudioUnitComponent]{
        var desc = AudioComponentDescription()
        if type == .effect { desc.componentType = kAudioUnitType_Effect }
        if type == .instrument { desc.componentType = kAudioUnitType_MusicDevice}
        return AVAudioUnitComponentManager.shared().components(matching: desc)
    }
    func fillEffectsPopup(){
        let effects = getAudioComponentList(type: .effect)
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
    var sendPopups : [NSPopUpButton]{
        return [sendPopup1, sendPopup2]
    }
    var sendLevelKnobs : [NSSlider]{
        return [sendLevelKnob1, sendLevelKnob2]
    }
    private func fillSendPopups(){
        for i in 0..<sendPopups.count{
            let sendPopup = sendPopups[i]
            sendPopup.removeAllItems()
            let busList = getBusList()
            sendPopup.addItems(withTitles: busList)
            if let busNumber = channelViewDelegate.getSendOutput(sendNumber: i){
                sendPopup.selectItem(at: busNumber)
            } else {
                sendPopup.selectItem(at: sendPopup1.numberOfItems - 1)
            }
        }
    }
    func getBusList() -> [String]{
        let numBusses = pluginSelectionDelegate.numBusses()
        var busList : [String] = []
        for i in 0..<numBusses{
            let title = "Bus " + String(i+1)
            busList.append(title)
        }
        busList.append("")
        return busList
    }

    @objc func panChanged(){
        let value = getKnobLevel(blackoutRegion: 0.2, popupButton: panKnob, minValue: -1.0, maxValue: 1.0)
        channelViewDelegate.pan = value
    }
    @objc func getKnobLevel(blackoutRegion: Float, popupButton: NSSlider, minValue: Float, maxValue: Float) -> Float{
        let blackoutRegion = 0.2
        let upperLim = 0.5 + (blackoutRegion * 0.5)
        let lowerLim = 0.5 - (blackoutRegion * 0.5)
        var rawValue = popupButton.doubleValue
        if rawValue >= 0.5, rawValue < upperLim{
            rawValue = upperLim
            popupButton.doubleValue = rawValue
        } else if rawValue < 0.5, rawValue > lowerLim{
            rawValue = lowerLim
            popupButton.doubleValue = rawValue
        } 
        let rotatedValue = (rawValue + 0.5).truncatingRemainder(dividingBy: 1.0)
        //Now we have a value between lowerLim and UpperLim
        let whiteoutRegion = 1.0 - blackoutRegion
       
        var completeness = (rotatedValue - blackoutRegion * 0.5) / whiteoutRegion
        if completeness < 0.000001 { completeness = 0 }
        let finalValue = (maxValue - minValue) * Float(completeness) + minValue
        return finalValue
    }
    func set(popupButton: NSSlider, value: Float, blackoutRegion: Float, minValue: Float, maxValue: Float){
        let inputValueSpread = maxValue - minValue
        let completeness = (value - minValue) / inputValueSpread
        let whiteoutRegion = 1.0 - blackoutRegion
        let newPosition = (blackoutRegion / 2) + completeness * whiteoutRegion
        let newPositionRotated = (newPosition + 0.5).truncatingRemainder(dividingBy: 1.0)
        popupButton.floatValue = newPositionRotated
        popupButton.needsDisplay = true
    }
    func updateVUMeter(level: Float) {
        guard let view = vuMeterView else { return }
        view.level = level
        DispatchQueue.main.async {
            view.needsDisplay = true
        }
    }
    override public func mouseDown(with event: NSEvent) {
        if event.modifierFlags.contains(NSEvent.ModifierFlags.command){
            //Toggle selection on this channel. Ignore other channels
            isSelected = !isSelected
        } else if event.modifierFlags.contains(NSEvent.ModifierFlags.shift){
            //Ignore this case for now
        } else {
            //Toggle selection on this channel. Deselect other channels
            let newValue = !isSelected
            channelViewDelegate.didSelect(channel: channelNumber)
            isSelected = newValue
        }

    }
    public override var isSelected: Bool {
        didSet{
            if isSelected{
                self.view.layer?.borderWidth = 2.0
                self.view.layer?.borderColor = NSColor.green.cgColor
            } else {
                self.view.layer?.borderColor = CGColor.clear
            }
        }
    }
}

public enum ChannelType {
    case master
    case midiInstrument
    case aux
    case labels
}
