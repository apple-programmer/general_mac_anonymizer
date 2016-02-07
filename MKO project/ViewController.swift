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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let arr = runCommand(command: "command -v /usr/local/bin/brew")
        let isBrewInstalled = !arr.isEmpty
        if (!isBrewInstalled) {
            let alert = NSAlert()
            alert.messageText = "You have not installed HomeBrew!"
            alert.informativeText = "Home brew is needed to install tor and privoxy"
            alert.addButtonWithTitle("OK, install")
            alert.addButtonWithTitle("Cancel")
            let response = alert.runModal()
            
            if response == NSAlertFirstButtonReturn {
                print("User agreed")
                runCommand(command: "/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"")
                runCommand(command: "\(askpass) sudo -Ak brew install tor")
                runCommand(command: "\(askpass) sudo -Ak brew install privoxy")
            }
            else {
                print("User refused")
                exit(0);
            }
            
        }
    }
    

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

