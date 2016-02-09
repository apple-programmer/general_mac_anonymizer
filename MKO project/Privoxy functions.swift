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
    return runCommand(command: "/usr/local/sbin/privoxy --user \(NSUserDefaults.standardUserDefaults().objectForKey("username") as! String) /usr/local/etc/privoxy/config")
}

func configurePrivoxy() {
    let path = "/usr/local/etc/privoxy/config"
    runCommand(command: "\(askpass) sudo -Ak rm \(path)")
    let delegate = NSApplication.sharedApplication().delegate as! AppDelegate
    let context = delegate.managedObjectContext
    
    let fetch = NSFetchRequest(entityName: "Privoxy")
    
    do {
        let result = try context.executeFetchRequest(fetch)
        let contents = result as! [NSManagedObject]

        var configFileContent = ""
        
        for obj in contents {
            if let _string = obj.valueForKey("configContent") as? String {
                configFileContent = _string
                print(_string)
            }
        }
        print(configFileContent)
        try configFileContent.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
    }
    catch {
        print("Error while reading core data and writing to file : \(error)")
    }
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
    if !fileExists(pathToFile: "/usr/local/sbin/privoxy") {
        installPrivoxy()
    }
    configurePrivoxy()
    print("Launched privoxy : \(launchPrivoxy())")
}