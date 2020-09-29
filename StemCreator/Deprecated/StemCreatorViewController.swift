//
//  StemCreatorViewController.swift
//  AudioFramework
//
//  Created by Admin on 9/24/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Cocoa

class StemCreatorViewController: NSViewController, NSTableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    func numberOfRows(in: NSTableView) -> Int{
        return 1
    }
   
func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return 99
    }
    
}
