//
//  StemViewController.swift
//  AudioFramework
//
//  Created by Admin on 9/25/20.
//  Copyright © 2020 UltraMusician. All rights reserved.
//

import Cocoa

public class StemViewController: NSViewController {
    public var delegate : StemViewDelegate!
    public override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBOutlet weak var gridView: NSView!
    
}
