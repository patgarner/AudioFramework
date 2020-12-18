//
//  AudioFormatViewController.swift
//  AudioFramework
//
//  Created by Admin on 12/17/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Cocoa

class AudioFormatViewController: NSViewController {
    var delegate : AudioFormatViewControllerDelegate?
    var audioFormatId : String = ""
    
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var pcmRadioButton: NSButton!
    @IBOutlet weak var mp3RadioButton: NSButton!
    @IBOutlet weak var sampleRatePopup: NSPopUpButton!
    @IBOutlet weak var bitRatePopup: NSPopUpButton!
    @IBOutlet weak var constantBitRatePopup: NSPopUpButton!
    @IBOutlet weak var mp3BitRatePopup: NSPopUpButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        let bundle = Bundle(for: AudioFormatViewController.self)

        super.init(nibName: nil, bundle: bundle)
    }
    private func initialize(){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func radioButtonClicked(_ sender: Any) {}
    
    func set(audioFormat: AudioFormat){
        nameField.stringValue = audioFormat.name
        if audioFormat.type == .wav { pcmRadioButton.state = .on }
        if audioFormat.type == .mp3 { mp3RadioButton.state = .on }
        sampleRatePopup.selectItem(withTag: audioFormat.sampleRate)
        bitRatePopup.selectItem(withTag: audioFormat.bitRate)
        if audioFormat.constantBitRate {
            constantBitRatePopup.selectItem(withTag: 1)
        } else {
            constantBitRatePopup.selectItem(withTag: 0)
        }
        mp3BitRatePopup.selectItem(withTag: audioFormat.mp3BitRate)
        audioFormatId = audioFormat.id
    }
    @IBAction func okPressed(_ sender: Any) {
        let newAudioFormat = AudioFormat()
        newAudioFormat.name = nameField.stringValue
        if pcmRadioButton.state == .on {
            newAudioFormat.type = .wav
        } else if mp3RadioButton.state == .on {
            newAudioFormat.type = .mp3
        }
        newAudioFormat.sampleRate = sampleRatePopup.selectedTag()
        newAudioFormat.bitRate = bitRatePopup.selectedTag()
        newAudioFormat.constantBitRate = (constantBitRatePopup.selectedTag() == 1)
        newAudioFormat.mp3BitRate = mp3BitRatePopup.selectedTag()
        delegate?.updateValuesFor(audioFormatId: audioFormatId, newAudioFormat: newAudioFormat)
        
        DispatchQueue.main.async {
            self.view.window?.close()
        }
    }
    @IBAction func cancelPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.view.window?.close()
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        delegate?.deleteAudioFormatWith(id: audioFormatId)
        DispatchQueue.main.async {
            self.view.window?.close()
        }
    }
    

    
}
