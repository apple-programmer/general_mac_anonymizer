//
//  Classes and extensions.swift
//  MKO project
//
//  Created by Roman Nikitin on 06.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Cocoa
import Foundation
import CoreData

func runCommand(command cmd : String) -> String {
    var result = ""
    
    let task = NSTask()
    task.launchPath = "/bin/bash"
    task.arguments = (["-c", cmd])
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.standardError = pipe
    let handle = pipe.fileHandleForReading
    task.launch()
    
    let data = NSMutableData()
    
    while task.running {
        data.appendData(handle.availableData)
    }
    result = String(data: data, encoding: NSUTF8StringEncoding)!
    
    if !result.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).isEmpty {
        print("Output for \(cmd) : \(result)")
    }
    
    return result
}

func getPassword() -> String {
    var check = false
    var pass = "", mess = "Enter password"
    while (!check) {
        
        let alert = NSAlert()
        alert.messageText = mess
        alert.informativeText = "Your password is required for some functions"
        alert.addButtonWithTitle("Confirm")
        alert.addButtonWithTitle("Cancel (quit)")
        
        let textField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = textField
        
        let response = alert.runModal()
        if response == NSAlertFirstButtonReturn {
            print("User agreed")
            pass = textField.stringValue
            runCommand(command: "echo $'#!/bin/bash\necho \(pass)' > .pw.sh")
            runCommand(command: "chmod 755 .pw.sh")
            let result = runCommand(command: "\(askpass) sudo -Ak true")
            if (!result.isEmpty) {
                mess = "Password incorrect"
                print("User entered incorrect password")
            }
            else {
                check = true
            }
        }
        else {
            print("User refused to provide password. Exiting")
            exit(0);
        }
    }
    
    print("Password confirmed")
    
    return pass;
}

func fileExists(pathToFile path : String) -> Bool {
    return NSFileManager.defaultManager().fileExistsAtPath(path)
}

func randomString() -> String {
    
    let len = random() % 30 + 15
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i=0; i < len; i++){
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return randomString as String
}

func printToGUI(content : String) {
    dispatch_async(dispatch_get_main_queue(), {
        () -> Void in
        NSNotificationCenter.defaultCenter().postNotificationName("NewConsoleOuput", object: nil, userInfo: ["output" : content])
    })
}
