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
                result += "\(output)\n"
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
                result += "\(output)\n"
            
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
            }
        }
        else {
            print("User refused")
            exit(0);
        }
    }
    return pass;
}

func setStringToCoreData(content cont : String, entityName ent : String, attributeName attr : String) {
    let delegate = NSApplication.sharedApplication().delegate as! AppDelegate
    let context = delegate.managedObjectContext
    
    if let entity = NSEntityDescription.entityForName(ent, inManagedObjectContext: context) {
        let object = NSManagedObject(entity: entity, insertIntoManagedObjectContext: context)
        object.setValue(cont, forKey: attr)
        do {
            try context.save()
        }
        catch {
            print("Error \"\(error as NSError)\" while saving attribute \(attr) to entity \(ent)")
        }
    }
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