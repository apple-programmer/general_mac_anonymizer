//
//  AppDelegate.swift
//  MKO project
//
//  Created by Roman Nikitin on 06.02.16.
//  Copyright © 2016 NikRom. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var isTerminating = false

    func applicationWillFinishLaunching(notification: NSNotification) {
        runCommand(command: "killall tor ; killall privoxy ; killall brew")
        let user = runCommand(command: "whoami").componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).first!
        print("I am \(user)")
        NSUserDefaults.standardUserDefaults().setObject(user, forKey: "username")
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSNotificationCenter.defaultCenter().addObserverForName("Termination", object: nil, queue: NSOperationQueue.currentQueue(), usingBlock: {
            notification -> Void in
            if !self.isTerminating {
                self.applicationTerminates()
            }
        })
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
    }
    
    func applicationWillHide(notification: NSNotification) {
        print("Is HIDING!")
    }
    
    func applicationTerminates() {
//        isTerminating = true
//
        deinitNetwork()
//
        print("network deinitiated")
//
//        while isTorLaunched {
//            
//        }
//        
////        // Will be caught in launchTor() func
        NSNotificationCenter.defaultCenter().postNotificationName("AppTerminates", object: nil)
        print("so what?")
        while isTorLaunched {
            
        }
        
        print("So cloooose")
        
        NSApplication.sharedApplication().replyToApplicationShouldTerminate(true)
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            () -> Void in
                self.applicationTerminates()
            })
        return NSApplicationTerminateReply.TerminateLater
    }
    
}



let askpass = "export SUDO_ASKPASS=.pw.sh ; SUDO_ASKPASS=.pw.sh ;"
var isTorLaunched = false


