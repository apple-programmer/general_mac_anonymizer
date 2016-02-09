//
//  Network setup.swift
//  MKO project
//
//  Created by Roman Nikitin on 08.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Foundation
import Cocoa

func configureProxy() {
    let services = runCommand(command: "networksetup -listallnetworkservices | grep -vw \"An asterisk\"").componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    for serv in services {
        runCommand(command: "\(askpass) sudo -Ak networksetup -setsecurewebproxy \"\(serv)\" 127.0.0.1 8118")
        runCommand(command: "\(askpass) sudo -Ak networksetup -setwebproxy \"\(serv)\" 127.0.0.1 8118")
        runCommand(command: "\(askpass) sudo -Ak networksetup -setsocksfirewallproxy \"\(serv)\" 127.0.0.1 9050")
    }
}

func createLocation() {
    runCommand(command: "\(askpass) sudo -Ak networksetup -createlocation \"Secret Location\" populate")
    runCommand(command: "\(askpass) sudo -Ak networksetup -switchtolocation \"Secret Location\"")
}

func initNetwork() {
    getPassword()
    createLocation()
    configureProxy()
    initBrew()
    initTor()
    initPrivoxy()
}

func deinitNetwork() {
    runCommand(command: "\(askpass) sudo -Ak networksetup -deletelocation \"Secret Location\"")
    runCommand(command: "\(askpass) sudo -Ak networksetup -switchtolocation \"Main\"")
}