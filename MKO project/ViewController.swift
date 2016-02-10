//
//  ViewController.swift
//  MKO project
//
//  Created by Roman Nikitin on 06.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

class ViewController: NSViewController {
    
    var progressIndicatior = NSProgressIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()
        progressIndicatior = NSProgressIndicator(frame: NSRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 25, width: 50, height: 50))
        progressIndicatior.style = .SpinningStyle
        progressIndicatior.hidden = true
        self.view.addSubview(progressIndicatior)
    }
    
    @IBAction func configureAllButtonClicked(sender: NSButton) {
        sender.state = NSOffState
        progressIndicatior.hidden = false
        progressIndicatior.startAnimation(self)
        self.view.acceptsTouchEvents = false
        initNetwork()
        progressIndicatior.stopAnimation(self)
        progressIndicatior.hidden = true
    }
    override func viewDidAppear() {
        super.viewDidAppear()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

