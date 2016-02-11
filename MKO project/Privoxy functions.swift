//
//  Privoxy functions.swift
//  MKO project
//
//  Created by Roman Nikitin on 08.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Foundation
import Cocoa

func launchPrivoxy() -> String {
    return runCommand(command: "/usr/local/sbin/privoxy /usr/local/etc/privoxy/config")
}

func configurePrivoxy() {
    let configPath = "/usr/local/etc/privoxy/config"
    let newConfigPath = NSBundle.mainBundle().pathForResource("privoxyConfig", ofType: "txt")
    runCommand(command: "\(askpass) sudo -Ak rm \(configPath)")
    do {
        let content = try String(contentsOfFile: newConfigPath!, encoding: NSUTF8StringEncoding)
        try content.writeToFile(configPath, atomically: true, encoding: NSUTF8StringEncoding)
        print("configuration done")
    }
    catch {
        print("Error \(error as NSError) while configuring Privoxy")
    }
    
}

func isPrivoxyInstalled() -> Bool {
    return fileExists(pathToFile: "/usr/local/sbin/privoxy")
}

func installPrivoxy() {
    if fileExists(pathToFile: "\(NSFileManager.defaultManager().currentDirectoryPath)//.pw.sh") {
        print("Installing Privoxy")
        runCommand(command: "\(askpass) sudo -Ak brew install privoxy")
    }
    else {
        getPassword()
        installPrivoxy()
    }
}

func initPrivoxy() {
    if !isPrivoxyInstalled() {
        installPrivoxy()
    }
    configurePrivoxy()
    print("Launching Privoxy")
    printToGUI("Launching Privoxy")
    launchPrivoxy()
    printToGUI("Launched Privoxy")
}