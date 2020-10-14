//
//  ViewController.swift
//  AudioFrameworkDemo
//
//  Created by Admin on 9/21/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Cocoa
import AudioFramework

class ViewController: NSViewController, KeyDelegate {
    func keyDown(_ number: Int) {
        if number == 48 { //Tab
            //visualizeAudioGraph()
            print("")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as? KeyView{
            view.delegate = self
        }

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

