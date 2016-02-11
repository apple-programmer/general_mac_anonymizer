//
//  ViewController.swift
//  MKO project
//
//  Created by Roman Nikitin on 06.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

class CustomView: NSView {
    
    var ignoresUser : Bool = false
    
    
    override func hitTest(aPoint: NSPoint) -> NSView? {
        if self.ignoresUser {
            return nil
        }
        return super.hitTest(aPoint)
    }
}

class ViewController: NSViewController {
    
    @IBOutlet weak var customView: CustomView!
    
    var progressIndicatior = NSProgressIndicator()

    @IBOutlet var textView: NSTextView!
    
    @IBOutlet weak var newIdentityButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customView.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
        
        progressIndicatior = NSProgressIndicator(frame: NSRect(x: self.view.frame.width / 2 - 25, y: self.view.frame.height / 2 - 25, width: 50, height: 50))
        progressIndicatior.style = .SpinningStyle
        progressIndicatior.hidden = true
        self.view.addSubview(progressIndicatior)
    }
    
    @IBAction func newIdentityButtonClicked(sender: AnyObject) {
        let conn = Connection(host: "127.0.0.1", port: 9052)
        conn.requestIdentity()
    }
    
    @IBAction func configureAllButtonClicked(sender: NSButton) {
        progressIndicatior.hidden = false
        progressIndicatior.startAnimation(self)
        customView.ignoresUser = true
        if sender.title == "Start network" {
            sender.title = "Stop network"
            initNetwork()
            newIdentityButton.hidden = false
        }
        else {
            sender.title = "Start network"
            deinitNetwork()
            newIdentityButton.hidden = true
        }
        progressIndicatior.stopAnimation(self)
        progressIndicatior.hidden = true
        customView.ignoresUser = false
    }
    override func viewDidAppear() {
        super.viewDidAppear()
            NSNotificationCenter.defaultCenter().addObserverForName("NewConsoleOuput", object: nil, queue: nil, usingBlock: {
            notification -> Void in
                if let info = notification.userInfo {
                    if let output = info["output"] as? String {
                        let array = output.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                        for line in array {
                            self.textView.string! += "\(line)\n"
                        }
                    }
                }
        })
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

