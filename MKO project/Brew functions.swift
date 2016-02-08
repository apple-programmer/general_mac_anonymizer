//
//  Brew functions.swift
//  MKO project
//
//  Created by Roman Nikitin on 08.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Foundation
import Cocoa

func isBrewInstalled() -> Bool {
    let arr = runCommand(command: "command -v /usr/local/bin/brew")
    return !arr.isEmpty
}

func installBrew() {
    runCommand(command: "/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"")
}

func initBrew() {
    if !isBrewInstalled() {
        
        let alert = NSAlert()
        alert.messageText = "You have not installed HomeBrew!"
        alert.informativeText = "Home brew is needed to install tor and privoxy"
        alert.addButtonWithTitle("OK, install")
        alert.addButtonWithTitle("Cancel")
        let response = alert.runModal()
        
        if response == NSAlertFirstButtonReturn {
            print("User agreed")
            installBrew()
        }
        else {
            print("User refused to install HomeBrew")
            exit(0);
        }
    }
}


