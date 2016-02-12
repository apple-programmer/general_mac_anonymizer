//
//  SettingsViewController.swift
//  MKO project
//
//  Created by Roman Nikitin on 12.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    @IBOutlet weak var torPortField: NSTextField!
    @IBOutlet weak var webProxyPortField: NSTextField!
    @IBOutlet weak var torPossibleValue: NSTextField!
    @IBOutlet weak var webPossibleValue: NSTextField!

    @IBAction func webProxyEntered(sender: NSTextField) {
        let value = sender.stringValue
        if Int(value) > 9050 && Int(value) <= 9252 {
            torPossibleValue.hidden = true
            setTorControlPort(newPort: Int(value)!)
        }
        else {
            torPossibleValue.hidden = false
        }
    }
    
    @IBAction func torControlPortEntered(sender: NSTextField) {
        let value = sender.stringValue
        if Int(value) > 9050 && Int(value) <= 9252 {
            torPossibleValue.hidden = true
            setTorControlPort(newPort: Int(value)!)
        }
        else {
            torPossibleValue.hidden = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setTorControlPort(newPort port : Int) {
        NSUserDefaults.standardUserDefaults().setInteger(port, forKey: "TorControlPort")
        print("Tor port set to \(port)")
    }
    
    func setWebProxyPort(newPort port : Int) {
        NSUserDefaults.standardUserDefaults().setInteger(port, forKey: "WebProxyPort")
        print("Web proxy port set to \(port)")
    }
    
}
