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
            printToGUI("Configured proxy on service \(serv)")
        }
    }
}

func getCurrentLocation() {
    let output = runCommand(command: "\(askpass) sudo -Ak networksetup -getcurrentlocation").componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).first
    if output == "Automatic" || output == "Авто" {
        createLocation(locationName: "Main Location")
        switchToLocation(locationName: "Main Location")
        runCommand(command: "\(askpass) sudo -Ak -deletelocation \"\(output)\"")
        NSUserDefaults.standardUserDefaults().setObject("Main Location", forKey: "OldLocation")
    }
    else {
        NSUserDefaults.standardUserDefaults().setObject(output, forKey: "OldLocation")
    }
}

func createLocation(locationName name : String = "Secret Location") {
    runCommand(command: "\(askpass) sudo -Ak networksetup -createlocation \"\(name)\" populate")
    print("Location created")
    printToGUI("Created location \(name)")
}

func switchToLocation(locationName name : String = "Secret Location") {
    var name = name
    let result = runCommand(command: "\(askpass) sudo -Ak networksetup -switchtolocation \"\(name)\"")
    if result.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).contains("** Error: The parameters were not valid.") {
        printToGUI("Could not find old location")
        createLocation(locationName: "Main Location")
        switchToLocation(locationName: "Main Location")
        name = "Main Location"
    }
    print("Switched to location \(name)")
    printToGUI("Switched to location \(name)")
}

func initNetwork() {
    getPassword()
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
        getCurrentLocation()
        createLocation()
        switchToLocation()
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
    var location = NSUserDefaults.standardUserDefaults().objectForKey("OldLocation") as! String
    if location == "Secret Location" {
        location = "Main Location"
    }
    switchToLocation(locationName: location)
    runCommand(command: "\(askpass) sudo -Ak networksetup -deletelocation \"Secret Location\"")
    print("Deleted location")
    printToGUI("Deleted location \"Secret Location\"")
    isTorLaunched = false
    runCommand(command: "killall tor")
    runCommand(command: "killall privoxy")
    printToGUI("Killed Privoxy")
    
}