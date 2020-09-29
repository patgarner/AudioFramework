//
//  StemItem.swift
//  AudioFramework
//
//  Created by Admin on 9/24/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Cocoa

class StemItem: NSCollectionViewItem {
    
    @IBOutlet weak var checkbox: NSButton!
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        checkbox.contentTintColor = NSColor.red
        checkbox.isTransparent = true
    }
    
}
