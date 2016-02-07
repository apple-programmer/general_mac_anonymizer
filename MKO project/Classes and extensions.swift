//
//  Classes and extensions.swift
//  MKO project
//
//  Created by Roman Nikitin on 06.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Cocoa
import Foundation

func runCommand(command cmd : String) -> Array<String> {
    var result : Array<String> = []
    
    let task = NSTask()
    task.launchPath = "/bin/bash"
    task.arguments = (["-c", cmd])
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    let handle = pipe.fileHandleForReading
    handle.waitForDataInBackgroundAndNotify()
    
    let errPipe = NSPipe()
    task.standardError = errPipe
    let errHandle = errPipe.fileHandleForReading
    errHandle.waitForDataInBackgroundAndNotify()
    
    var startObserver : NSObjectProtocol!
    startObserver = NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: nil, queue: nil) { notification -> Void in
        let data = handle.availableData
        if data.length > 0 {
            if let output = String(data: data, encoding: NSUTF8StringEncoding) {
                print("Output : \(output)")
                result.append(output)
            }
        }
        else {
            print("EOF on stdout")
            NSNotificationCenter.defaultCenter().removeObserver(startObserver)
        }
    }
    
    var endObserver : NSObjectProtocol!
    endObserver = NSNotificationCenter.defaultCenter().addObserverForName(NSTaskDidTerminateNotification, object: nil, queue: nil) {
        notification -> Void in
        print("Task terminated with code \(task.terminationStatus)")
        NSNotificationCenter.defaultCenter().removeObserver(endObserver)
    }
    
    var errObserver : NSObjectProtocol!
    errObserver = NSNotificationCenter.defaultCenter().addObserverForName(NSTaskDidTerminateNotification, object: nil, queue: nil) {
        notification -> Void in
        let data = errHandle.availableData
        if (data.length > 0) {
            if let output = String(data: data, encoding: NSUTF8StringEncoding) {
                print("Error : \(output)")
                result.append(output)
            
                NSNotificationCenter.defaultCenter().removeObserver(errObserver)
            }
        }
    }
    
    task.launch()
    task.waitUntilExit()
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
            }
            else {
                check = true
                NSUserDefaults.standardUserDefaults().setObject(pass, forKey: "UserPassword")
            }
        }
        else {
            print("User refused")
            exit(0);
        }
    }
    return pass;
}