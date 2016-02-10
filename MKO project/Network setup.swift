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
        if !serv.isEmpty {
            runCommand(command: "\(askpass) sudo -Ak networksetup -setsecurewebproxy \"\(serv)\" 127.0.0.1 8118")
            runCommand(command: "\(askpass) sudo -Ak networksetup -setwebproxy \"\(serv)\" 127.0.0.1 8118")
            runCommand(command: "\(askpass) sudo -Ak networksetup -setsocksfirewallproxy \"\(serv)\" 127.0.0.1 9050")
        }
    }
}

func createLocation() {
    runCommand(command: "\(askpass) sudo -Ak networksetup -createlocation \"Secret Location\" populate")
    runCommand(command: "\(askpass) sudo -Ak networksetup -switchtolocation \"Secret Location\"")
}

func initNetwork() {
    getPassword()
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
        createLocation()
        configureProxy()
    })
    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
        if !isTorInstalled() || !isPrivoxyInstalled() {
            initBrew()
        }
    })
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        initPrivoxy()
        initTor()
    })
    
}

func deinitNetwork() {
    runCommand(command: "\(askpass) sudo -Ak networksetup -switchtolocation \"Main\"", waitForCompletion: true)
    print("Switched location")
    runCommand(command: "\(askpass) sudo -Ak networksetup -deletelocation \"Secret Location\"", waitForCompletion: false)
    print("Deleted location")
    
}