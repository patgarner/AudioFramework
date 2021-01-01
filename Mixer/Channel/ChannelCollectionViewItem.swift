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
    @IBOutlet weak var outputPopup: NSPopUpButton!
    @IBOutlet weak var panKnob: NSSlider!
    @IBOutlet weak var volumeValueTextField: NSTextField!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var soloButton: DraggableButton!
    @IBOutlet weak var muteButton: NSButton!
    @IBOutlet weak var trackNameField: NSTextField!
    @IBOutlet weak var labelView: MixerFillView!
    @IBOutlet weak var labelViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var soloPanGestureRecognizer: AFPanGestureRecognizer!
    var channelViewDelegate : ChannelViewDelegate!
    var channelNumber = -1
    var type = ChannelType.midiInstrument
    private var instrumentsByManufacturer: [(String, [AVAudioUnitComponent])] = []
    
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
        outputPopup.target = self
        outputPopup.action = #selector(outputChanged)
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
        soloPanGestureRecognizer.delegate = self
        soloPanGestureRecognizer.target = self
        soloPanGestureRecognizer.action = #selector(soloPanGestureReceived)
        refresh()
        
        soloButton.type = .solo
        soloPanGestureRecognizer.mouseDownEvent = { [self] in
            soloButton.state = soloButton.state == .on ? .off : .on
            soloButton.isHighlighted = (soloButton.state == .on)
            soloChanged()
        }
    }
    @objc func soloPanGestureReceived(sender: Any){
        guard let mainButton = soloPanGestureRecognizer.view as? DraggableButton else { return }

        let translation = soloPanGestureRecognizer.translation(in: self.view)
        let start = min(mainButton.frame.maxX, mainButton.frame.maxX + translation.x)
        let end = max(mainButton.frame.maxX, mainButton.frame.maxX + translation.x)
        
        var newCapturedViews = [DraggableButton]()
        guard let oldCapturedViews = soloPanGestureRecognizer.capturedViews as? [DraggableButton] else { return }
        
        var state = mainButton.state
        
        DraggableButton.buttons.forEach { button in
            guard button != mainButton
                    && button.type == mainButton.type else { return }
            
            let frame = button.convert(button.frame,
                                       to: self.view)
            
            guard frame.minX > start
                    && frame.minX < end else { return }

            newCapturedViews.append(button)

            guard button.state != state else { return }

            button.state = state
            button.isHighlighted = state == .on
            _ = button.target?.perform(button.action)
        }
        
        state = state == .on ? .off : .on
        Set(oldCapturedViews).subtracting(newCapturedViews).forEach { button in
            guard button != mainButton else { return }
            button.state = state
            button.isHighlighted = state == .on
            _ = button.target?.perform(button.action)
        }
        
        soloPanGestureRecognizer.capturedViews = newCapturedViews
    }
    public func refresh(){
        if type == .labels{
            labelView.color = NSColor.systemGray
            labelViewTrailingConstraint.constant = 0
            labelView.isHidden = false
            labelView.needsLayout = true
            
            inputPopup.isEnabled = false
            audioFXPopup.isEnabled = false
            audioFXPopup2.isEnabled = false
            for send in sendPopups{
                send.isEnabled = false
            }
            for send in sendLevelKnobs{
                send.isEnabled = false
            }
            panKnob.isEnabled = false
            volumeValueTextField.isEnabled = false
            volumeSlider.isEnabled = false
            soloButton.isEnabled = false
            muteButton.isEnabled = false
            trackNameField.isEnabled = false            
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
            mixerFillView.color = NSColor(calibratedRed: 0.7, green: 0.75, blue: 0.8, alpha: 1)
            self.trackNameField.stringValue = "Main"
            self.trackNameField.isEditable = false
            inputPopup.isHidden = true
            self.soloButton.isHidden = true
            outputPopup.isEnabled = false
        }  else if type == .aux {
            mixerFillView.color = NSColor(calibratedRed: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            reloadInstruments()
            self.soloButton.isHidden = true
        } else if type == .midiInstrument{
            reloadInstruments()
            let instrumentSelection = channelViewDelegate.getPluginSelection(pluginType: .instrument, pluginNumber: channelNumber)
            let instruments = getAudioComponentList(type: .instrument)
            select(popup: inputPopup, list: instruments, pluginSelection: instrumentSelection)
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
        fillOutputPopup()
    }
    private func fillOutputPopup(){
        outputPopup.removeAllItems()
        outputPopup.addItem(withTitle: "Main")
        for i in 0..<channelViewDelegate.numBusses{
            let outputName = "Bus \(i+1)"
            outputPopup.addItem(withTitle: outputName)
        }
        outputPopup.addItem(withTitle: "")
        let outputDestination = channelViewDelegate.getDestination(type: .output, number: 0)
        if outputDestination.type == .master {
            outputPopup.selectItem(at: 0)
        } else if outputDestination.type == .bus{
            outputPopup.selectItem(at: outputDestination.number+1)
        } else {
            outputPopup.selectItem(at: outputPopup.numberOfItems - 1)
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
        let instruments = getAudioComponentList(type: .instrument)
        if index < 0 || index >= instruments.count {
            channelViewDelegate.deselectInstrument()
            return
        }
        let component = instruments[index]
        if let virtualInstrument = channelViewDelegate.getPluginSelection(pluginType: .instrument, pluginNumber: -1), component.manufacturerName == virtualInstrument.manufacturer,
            component.name == virtualInstrument.name {
            channelViewDelegate.displayInterface(type: .instrument, number: 0)
            return
        } else {
            channelViewDelegate.select(description: component.audioComponentDescription, type: .instrument, number: 0)
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
        let newEffect = effects[index]
        if let previousEffect = channelViewDelegate.getPluginSelection(pluginType: .effect, pluginNumber: number), previousEffect.manufacturer == newEffect.manufacturerName, previousEffect.name == newEffect.name {
            channelViewDelegate.displayInterface(type: .effect, number: number)
        } else {
            channelViewDelegate.select(description: newEffect.audioComponentDescription, type: .effect, number: number)
        }
    }
    @objc private func sendDestinationChanged(sender: Any){
        let popup = sender as! NSPopUpButton
        let index = popup.indexOfSelectedItem
        let sendNumber = popup.tag
        channelViewDelegate.connect(sourceType: .send, sourceNumber: sendNumber, destinationType: .bus, destinationNumber: index)
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
    @objc func trackNameChanged(sender: Any){
        let trackName = trackNameField.stringValue
        channelViewDelegate.trackName = trackName
        DispatchQueue.main.async {
            self.trackNameField.window?.makeFirstResponder(nil)
        }
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
        let instruments = getAudioComponentList(type: .instrument)
        for instrument in instruments{
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
        let list = channelViewDelegate.getAudioComponentList(type: type)
        return list
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
            let busInfo = channelViewDelegate.getDestination(type: .send, number: i)
            if busInfo.type == .bus {
                sendPopup.selectItem(at: busInfo.number)
            } else {
                sendPopup.selectItem(at: sendPopup1.numberOfItems - 1)
            }
            
        }
    }
    func getBusList() -> [String]{
        let numBusses = channelViewDelegate.numBusses
        var busList : [String] = []
        for i in 0..<numBusses{
            let title = "Bus " + String(i+1)
            busList.append(title)
        }
        busList.append("")
        return busList
    }
    @objc func outputChanged(){
        let index = outputPopup.indexOfSelectedItem
        if index == 0 {
            channelViewDelegate.connect(sourceType: .output, sourceNumber: 0, destinationType: .master, destinationNumber: 0)
        } else if index > channelViewDelegate.numBusses {
            channelViewDelegate.connect(sourceType: .output, sourceNumber: 0, destinationType: .none, destinationNumber: -1)
        } else {
            let busNumber = index - 1
            channelViewDelegate.connect(sourceType: .output, sourceNumber: 0, destinationType: .bus, destinationNumber: busNumber)
        }
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
        if type == .labels { return }
        if event.modifierFlags.contains(NSEvent.ModifierFlags.command){
            //Toggle selection on this channel. Ignore other channels
            isSelected = !isSelected
        } else if event.modifierFlags.contains(NSEvent.ModifierFlags.shift){
            //Ignore this case for now
        } else {
            //Toggle selection on this channel. Deselect other channels
            let newValue = !isSelected
            channelViewDelegate.didSelectChannel()
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

extension ChannelCollectionViewItem : NSGestureRecognizerDelegate{
    
}

public enum ChannelType {
    case master
    case midiInstrument
    case aux
    case labels
}
