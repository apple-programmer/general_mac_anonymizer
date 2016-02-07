//
//  AppDelegate.swift
//  MKO project
//
//  Created by Roman Nikitin on 06.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        getPassword()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        runCommand(command: "rm .pw.sh")
        NSUserDefaults.standardUserDefaults().setNilValueForKey("UserPassword")
    }


}

let askpass = "export SUDO_ASKPASS=.pw.sh ; SUDO_ASKPASS=.pw.sh ;"

