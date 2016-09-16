//
//  SettingsViewController.swift
//  MKO project
//
//  Created by Roman Nikitin on 12.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    @IBOutlet weak var torListeningPort: NSTextField!
    @IBOutlet weak var torPortField: NSTextField!
    @IBOutlet weak var webProxyPortField: NSTextField!
    @IBOutlet weak var torPossibleValue: NSTextField!
    @IBOutlet weak var torListeningValue: NSTextField!
    @IBOutlet weak var webPossibleValue: NSTextField!
    @IBOutlet weak var useInLANCheckBox: NSButton!
    
    let storage = NSUserDefaults.standardUserDefaults()
    
    @IBAction func setDefaultValues(sender: NSButton) {
        useInLANCheckBox.state = 0
        torListeningPort.integerValue = 9050
        torPortField.integerValue = 9052
        webProxyPortField.integerValue = 8118
    }
    
    @IBAction func saveSettings(sender: AnyObject) {
        let torListenPort = torListeningPort.integerValue
        let torControlPort = torPortField.integerValue
        let proxyPort = webProxyPortField.integerValue
        let useOnOther = (useInLANCheckBox.state == 1)
        if 9050...9252 ~= torControlPort && 8100...8200 ~= proxyPort && 9000...9050 ~= torListenPort {
            setTorControlPort(newPort: torControlPort)
            setWebProxyPort(newPort: proxyPort)
            setTorListeningPort(newPort: torListenPort)
            setLANAccess(newBool: useOnOther)
            self.dismissViewController(self)
        }
        else {
            NSSound(named: "Basso")?.play()
            if !(9000...9050 ~= torListenPort) {
                torListeningPort.integerValue = 9050
                torListeningPort.becomeFirstResponder()
            }
            if !(9050...9252 ~= torControlPort) {
                torPortField.integerValue = 9052
                torPortField.becomeFirstResponder()
            }
            if !(8100...8200 ~= proxyPort) {
                webProxyPortField.integerValue = 8118
                webProxyPortField.becomeFirstResponder()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let torPort = storage.integerForKey("TorControlPort")
        if torPort != 0 {
            torPortField.integerValue = torPort
        }
        else {
            torPortField.integerValue = 9052
            setTorControlPort(newPort: 9052)
        }
        
        let proxyPort = storage.integerForKey("WebProxyPort")
        if proxyPort != 0 {
            webProxyPortField.integerValue = proxyPort
        }
        else {
            webProxyPortField.integerValue = 8118
            setWebProxyPort(newPort: 8118)
        }
        
        let torListenPort = storage.integerForKey("TorListeningPort")
        if torListenPort != 0 {
            torListeningPort.integerValue = torListenPort
        }
        else {
            torListeningPort.integerValue = 9050
            setTorControlPort(newPort: 9050)
        }
    }
    
    @IBAction func helpButtonPressed(sender: AnyObject?) {
        torListeningValue.hidden = false
        torPossibleValue.hidden = false
        webPossibleValue.hidden = false
    }
    
    func setTorControlPort(newPort port : Int) {
        storage.setInteger(port, forKey: "TorControlPort")
        print("Tor control port set to \(port)")
    }
    
    func setWebProxyPort(newPort port : Int) {
        storage.setInteger(port, forKey: "WebProxyPort")
        print("Web proxy port set to \(port)")
    }
    
    func setTorListeningPort(newPort port : Int) {
        storage.setInteger(port, forKey: "TorListeningPort")
        print("Tor listening port set to \(port)")
    }
    
    func setLANAccess(newBool value : Bool) {
        storage.setBool(value, forKey: "LANAccess")
        print("LANAccess set to \(value)")
    }
    
}
