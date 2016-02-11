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

    func applicationWillFinishLaunching(notification: NSNotification) {
        runCommand(command: "killall tor ; killall privoxy ; killall brew")
        let user = runCommand(command: "whoami").componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).first!
        print("I am \(user)")
        NSUserDefaults.standardUserDefaults().setObject(user, forKey: "username")
    }
    
    func applicationTerminates() {
        
        deinitNetwork()
        print("network deinitiated")
        
        NSApplication.sharedApplication().replyToApplicationShouldTerminate(true)
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            () -> Void in
                self.applicationTerminates()
            })
        return NSApplicationTerminateReply.TerminateLater
    }
    
}



let askpass = "export SUDO_ASKPASS=.pw.sh ; SUDO_ASKPASS=.pw.sh ;"
var isTorLaunched = false


